//
//  DsNotificationReceiver.h
//  duosuccess
//
//  Created by Rick Li on 12/22/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DsNotificationReceiver : NSObject

+ (id)sharedInstance;

-(void)receiveNotifiaction: (NSDictionary*) notificationPayload;

@end
