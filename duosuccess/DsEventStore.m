//
//  DsEventStore.m
//  duosuccess
//
//  Created by Rick Li on 1/1/14.
//  Copyright (c) 2014 Rick Li. All rights reserved.
//

#import "DsEventStore.h"

@implementation DsEventStore
@synthesize paperPrefKey;
@synthesize paperEventKey;
@synthesize paperDateKey;

+ (id)sharedInstance {
    static DsEventStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id) init{
    self = [super init];
    paperPrefKey = @"paperPrefKey";
    paperEventKey = @"paperEventKey";
    paperDateKey = @"paperDateKey";
    return self;
}

-(void) clearPaparReminders{
//    EKEventStore *store = [[EKEventStore alloc] init];
//    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        NSLog(@"Event access granted - %d.", granted);
//        EKCalendar *defaultCalendar = [store defaultCalendarForNewEvents];
//        NSArray *calendarArray = [NSArray arrayWithObject:defaultCalendar];
//        NSDate *startDate = [NSDate date];
//        NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow: 60*60*24*3];
//        NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
//        NSArray *events = [store eventsMatchingPredicate:predicate];
//        
//        for(EKEvent *event in events){
//            NSString *strUrl = [event.URL absoluteString];
//            
//            if ([strUrl rangeOfString:@"https://www.duosuccess.com"].location != NSNotFound) {
//                NSLog(@"Delete legacy paper reminder - %@.", event.title);
//                NSError *error;
//                [store removeEvent:event span:EKSpanThisEvent commit:true error:&error];
//            }
//        }
//    }];
}

-(void) savePaperReminder{
//    EKEventStore *store = [[EKEventStore alloc] init];
//    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        NSLog(@"Event access granted - %d.", granted);
//        
//        [self removePaperReminder];
//        
//        EKEvent *newPaperEvent = [EKEvent eventWithEventStore:store];
//        
//        NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow: 60*60*24*3];
//        NSDate *endDate = [startDate dateByAddingTimeInterval:10*60];
//        [newPaperEvent setTitle: NSLocalizedString(@"energyPaperExpired", "")];
//
//        NSString *duoUrl = @"https://www.duosuccess.com/tcm/001new01c.htm";
//        [newPaperEvent setURL:[[NSURL alloc] initWithString : duoUrl]];
//        [newPaperEvent setStartDate: startDate];
//        [newPaperEvent setEndDate: endDate];
//        EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:[startDate dateByAddingTimeInterval:-10]];
//        [newPaperEvent setAlarms:@[alarm]];
//        EKCalendar *calendar = [store defaultCalendarForNewEvents];
//        [newPaperEvent setCalendar: calendar];
//        
//        [store saveEvent:newPaperEvent span:EKSpanThisEvent commit:true error:&error];
//        if(error){
//            NSLog(@"Unable to save paper event. %@", error.description);
//        }
//        NSMutableDictionary *paperData = [[NSMutableDictionary alloc]init];
//        [paperData setValue:newPaperEvent.eventIdentifier forKey:paperEventKey];
//        [paperData setValue:startDate forKey:paperDateKey];
//        
//        [[NSUserDefaults standardUserDefaults] setValue:paperData forKey:paperPrefKey];
//        
//    }];
}


-(void)removePaperReminder{
    //remove current event if exists
//    EKEventStore *store = [[EKEventStore alloc] init];
//
//    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        NSLog(@"Event access granted - %d.", granted);
//        if(!granted){
//            NSLog(@"Event access cannot be granted.");
//            return;
//        }
//        
//        
//        NSMutableDictionary *paperData = [[NSUserDefaults standardUserDefaults] valueForKey:paperPrefKey];
//        
//        if(paperData && [paperData valueForKey:paperEventKey]){
//            NSString *currentEventId = [paperData valueForKey:paperEventKey];
//            EKEvent *currentEvent  = (EKEvent*)[store eventWithIdentifier:currentEventId];
//            
//            
//            NSError *error;
//            [store removeEvent:currentEvent span:EKSpanThisEvent commit:true error:&error];
//            
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:paperPrefKey];
//            
//            if(error){
//                NSLog(@"Remove current reminder failed %@", error.description);
//            }
//        }
//        
//    }];
}
@end
