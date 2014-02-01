//
//  DsAppDelegate.m
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsAppDelegate.h"
#import "DsDataStore.h"
#import "DsNotificationReceiver.h"
#import "DsRootViewController.h"
#import "DsMenuViewController.h"
#import "UIImage+iPhone5.h"
#import "UIColor+Hex.h"
#import "Utils.h"
#import "DsEventStore.h"
#import <Parse/Parse.h>

@implementation DsAppDelegate

@synthesize listCtrl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"==didFinishLaunchingWithOptions==");
    
    [[DsDataStore sharedInstance] syncData];
    
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (idiom == UIUserInterfaceIdiomPad)
    {
        //        [self customizeiPadTheme];
        
        //        [self iPadInit];
    }
    else
    {
        [self customizeiPhoneTheme];
    }
    
    
    
    
    if([[DsDataStore sharedInstance] isCensorMode]){
        //only do push notification during censor period
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
    
    //if app is started by notification swipe
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if(notificationPayload){
        NSLog(@"Application started with Notification swipe.");
        [self clearBadge];
    }
    
    [[DsNotificationReceiver sharedInstance] receiveNotifiaction: notificationPayload forListCtrl:self.listCtrl];
    
    //    [[DsNotificationReceiver sharedInstance] receiveNotifiaction:[NSDictionary dictionaryWithObject:@"TUUYBtlywF" forKey:@"oid"] forListCtrl:self.listCtrl];
    
    //set first run flag.
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"] == nil){
        //first run
        NSLog(@"App is running for first time.");
        [[NSUserDefaults standardUserDefaults] setObject:false forKey:@"FirstRun"];
        //Delete paper events left by previous installation.
        [[DsEventStore sharedInstance] clearPaparReminders];
    }
    
    //Display launch image longer
    [NSThread sleepForTimeInterval:1.0];
    return YES;
}


- (void)application:didFailToRegisterForRemoteNotificationsWithError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message: @"无法接收推送" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"aaNotification registered with device %@", newDeviceToken] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    //    [alert show];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken.... ");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    NSString *lang = [[[DsDataStore sharedInstance] defaultLang] valueForKey:@"code"];
    [currentInstallation addUniqueObject:lang forKey:@"channels"];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(succeeded){
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Installation saved successfully" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            //            [alert show];
            NSLog(@"Installation saved successfully.");
        }else{
            NSLog(@"Error %@", error.description);
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            //            [alert show];
        }
    }];
}


NSDictionary *notificationWhileRunning;

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)notificationPayload {
    notificationWhileRunning = notificationPayload;
    //check if user is playing music
    
    [self clearBadge];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NotificationReceived","") message:NSLocalizedString(@"OpenItNow", "") delegate:self cancelButtonTitle:NSLocalizedString(@"NoThanks", "") otherButtonTitles:NSLocalizedString(@"ok", ""), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button idx is %d.", buttonIndex);
    if (buttonIndex == 1)
    {
        
        [[DsNotificationReceiver sharedInstance] receiveNotifiaction:notificationWhileRunning forListCtrl:listCtrl];
        notificationWhileRunning = nil;
    }
}

-(void) clearBadge{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}


-(void)customizeiPhoneTheme
{
    if([Utils isVersion6AndBelow]){
        [[UIApplication sharedApplication]
         setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }else{
        [[UIApplication sharedApplication]
         setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        
    }
    
    UIImage *navBarImage = [[UIImage tallImageNamed:@"dmenubar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
    if(![Utils isVersion6AndBelow]){
        navBarImage = [[UIImage tallImageNamed:@"dmenubar-7.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
        
        [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    }
    
    
    
    
    UIImage *barButton = [[UIImage tallImageNamed:@"menubar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    //        if(![Utils isVersion6AndBelow])
    //        barButton = [[UIImage tallImageNamed:@"menubar-button-7.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    //
    if([Utils isVersion6AndBelow]){
        [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        
    }
    
    //customize the font title for ios7 only
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithHex:0x0190b9 alpha:1], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    UIImage *backButton = [[UIImage tallImageNamed:@"back6.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    if(![Utils isVersion6AndBelow])
        backButton = nil;
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    UIImage *toolbarBg = [UIImage tallImageNamed:@"dtabbar.png"];
    
    [[UIToolbar appearance] setBackgroundImage:toolbarBg forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    
    
    //    UIImage *minImage = [UIImage tallImageNamed:@"ipad-slider-fill"];
    //    UIImage *maxImage = [UIImage tallImageNamed:@"ipad-slider-track.png"];
    //    UIImage *thumbImage = [UIImage tallImageNamed:@"ipad-slider-handle.png"];
    //
    //    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    //    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    //    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    //    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    //
    //    UIImage* tabBarBackground = [UIImage tallImageNamed:@"tabbar.png"];
    //    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    //
    //
    //    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage tallImageNamed:@"tabbar-active.png"]];
    //
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"begin background task");
    //    UIBackgroundTaskIdentifier bgTask = nil;
    //    UIApplication  *app = [UIApplication sharedApplication];
    //    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    //        [app endBackgroundTask:(bgTask)];
    //        //bgTask = UIBackgroundTaskInvalid;
    //    }];
    //
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
    //
    //    [app endBackgroundTask:bgTask];
    //    bgTask = UIBackgroundTaskInvalid;
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //clear badge for app.
    [self clearBadge];
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[DsDataStore sharedInstance] saveContext];
}

@end
