//
//  DsInstConfirm.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsInstConfirm.h"

@implementation DsInstConfirm

@synthesize switchCtrl;
@synthesize confirmBtn;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    
    return self;
}

- (IBAction)doStart:(id)sender {
    [self.delegate start:self];
}
@end
