//
//  DsMask.m
//  duosuccess
//
//  Created by Rick Li on 1/9/14.
//  Copyright (c) 2014 Rick Li. All rights reserved.
//

#import "DsMask.h"
#import "MBProgressHUD.h"

@implementation DsMask
MBProgressHUD *hud;
Float32 timeoutSeconds;

NSTimer *timer;
+ (id)sharedInstance {
    static DsMask *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        timeoutSeconds = 90.0;
    });
    return sharedInstance;
}


-(void) startMask: (NSString*)msg forView: (UIView*)view{
    if(!hud || hud.isHidden ){
        if(!msg){
            msg = NSLocalizedString(@"loading", "");
        }
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.labelText = msg;
        timer = [NSTimer scheduledTimerWithTimeInterval:timeoutSeconds target:self selector:@selector(maskTimeout) userInfo:nil repeats:false] ;
        
    }else{
        NSLog(@"A mask exists, unable to start mask.");
    }
}

-(void)maskTimeout{
    NSLog(@"No response within %f, remove mask.", timeoutSeconds);
    timer = nil;
    [self removeMask];
}

-(void) removeMask{
    if(hud){
        [hud hide:true];
        hud = nil;
    }
}

@end
