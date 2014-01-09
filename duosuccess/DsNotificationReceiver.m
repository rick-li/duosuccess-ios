//
//  DsNotificationReceiver.m
//  duosuccess
//
//  Created by Rick Li on 12/22/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsNotificationReceiver.h"
#import "DsDataStore.h"
#import "DsArticleHelper.h"
#import "DsArticleViewController.h"
#import "DsRootViewController.h"
#import "DsMenuViewController.h"
#import "DsMask.h"
#import <Parse/Parse.h>

@implementation DsNotificationReceiver

@synthesize pendingNotification;

+ (id)sharedInstance {
    static DsNotificationReceiver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)receiveNotifiaction: (NSDictionary*)notificationPayload forListCtrl: (DsListViewController*)listCtrl{
    
    if(notificationPayload != nil){
        NSString *objectId = [notificationPayload valueForKey:@"oid"];
        NSLog(@"notification received objectId is %@.", objectId);
        
        PFQuery *query = [PFQuery queryWithClassName:@"Article"];
        [query whereKey:@"status" notEqualTo:@"deleted"];
        [query includeKey:@"image"];
        
        if(listCtrl == nil){
            NSLog(@"UI not initialized yet, save to pending item.");
            self.pendingNotification = notificationPayload;
            return;
        }
        
        UINavigationController *navCtrl =(UINavigationController *)listCtrl.navigationController;
        [[DsMask sharedInstance] startMask:nil forView: navCtrl.visibleViewController.view];
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *article, NSError *error) {
            PFObject *image = (PFObject *)article[@"image"];
            NSString *imageUrl = nil;
            [image fetchIfNeeded];
            if(image != nil){
                PFFile *imageFile = image[@"image"];
                imageUrl = imageFile.url;
            }
            
            NSMutableDictionary *dArticle = [[NSMutableDictionary alloc] initWithCapacity:5];
            
            NSString *title = article[@"title"];
            NSString *content = article[@"content"];
            NSDate *updatedAt = article.updatedAt;
            [dArticle setObject:title forKey:@"title"];
            [dArticle setObject:content forKey:@"content"];
            [dArticle setObject:imageUrl forKey:@"imageUrl"];
            [dArticle setObject:updatedAt forKey:@"updatedAt"];
            
            [[DsMask sharedInstance] removeMask];
            pendingNotification = nil;
            NSArray *viewCtrls = navCtrl.viewControllers;
            if([[viewCtrls objectAtIndex:(viewCtrls.count-1)] isKindOfClass:DsArticleViewController.class]){
                [navCtrl popViewControllerAnimated:false];
            }
            
            [[DsArticleHelper sharedInstance] openArticle:dArticle withNavCtrl:navCtrl];
            [[DsDataStore sharedInstance] syncData];
            
        }];
    }
}


@end
