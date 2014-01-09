//
//  DsMask.h
//  duosuccess
//
//  Created by Rick Li on 1/9/14.
//  Copyright (c) 2014 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DsMask : NSObject

+ (id)sharedInstance;



-(void) startMask: (NSString*)msg forView: (UIView*)view;

-(void) removeMask;

@end
