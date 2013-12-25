//
//  DsNotificationReceiver.m
//  duosuccess
//
//  Created by Rick Li on 12/22/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsNotificationReceiver.h"

@implementation DsNotificationReceiver

+ (id)sharedInstance {
    static DsNotificationReceiver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)receiveNotifiaction: (NSDictionary*) notificationPayload{
    if(notificationPayload != nil){
        //TODO query datasource for article and display it.
        NSLog(@"notification received objectId is %@.", [notificationPayload valueForKey:@"objectId"]);
        
    }
}


@end
