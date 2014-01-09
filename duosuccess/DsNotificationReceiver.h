//
//  DsNotificationReceiver.h
//  duosuccess
//
//  Created by Rick Li on 12/22/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DsListViewController.h"

@interface DsNotificationReceiver : NSObject

+ (id)sharedInstance;

@property NSDictionary *pendingNotification;

-(void)receiveNotifiaction: (NSDictionary*)notificationPayload forListCtrl: (DsListViewController*)listCtrl;

@end
