//
//  DsEventStore.h
//  duosuccess
//
//  Created by Rick Li on 1/1/14.
//  Copyright (c) 2014 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface DsEventStore : NSObject

+ (id)sharedInstance;

@property NSString *paperPrefKey;
@property NSString *paperEventKey;
@property NSString *paperDateKey;

-(void) savePaperReminder;

-(void) removePaperReminder;

@end
