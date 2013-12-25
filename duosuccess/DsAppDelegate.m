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
#import "UIImage+iPhone5.h"
#import "Utils.h"
#import <Parse/Parse.h>

@implementation DsAppDelegate

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
        
//        [self configureiPhoneTabBar];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    [[DsNotificationReceiver sharedInstance] receiveNotifiaction:notificationPayload];
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken.... ");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    NSString *lang = [[[DsDataStore sharedInstance] defaultLang] valueForKey:@"code"];
    [currentInstallation addUniqueObject:lang forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)notificationPayload {
    //if the app is already running.
    [[DsNotificationReceiver sharedInstance] receiveNotifiaction:notificationPayload];
    //handle user's
    //[PFPush handlePush:userInfo];
}


-(void)customizeiPhoneTheme
{
    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    UIImage *navBarImage = [[UIImage tallImageNamed:@"menubar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
    if(![Utils isVersion6AndBelow])
        navBarImage = [[UIImage tallImageNamed:@"menubar-7.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    
    UIImage *barButton = [[UIImage tallImageNamed:@"menubar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
//    if(![Utils isVersion6AndBelow])
//        barButton = [[UIImage tallImageNamed:@"menubar-button-7.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
//
    if([Utils isVersion6AndBelow]){
        [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        
    }
    
    UIImage *backButton = [[UIImage tallImageNamed:@"back6.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    if(![Utils isVersion6AndBelow])
        backButton = nil;
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    UIImage *toolbarBg = [UIImage tallImageNamed:@"tabbar.png"];
    
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //clear badge for app.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[DsDataStore sharedInstance] saveContext];
}

@end
