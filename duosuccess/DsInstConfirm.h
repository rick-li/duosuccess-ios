//
//  DsInstConfirm.h
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DsInstConfirm;

@protocol DsInstConfirmDelegate <NSObject>

- (void)start: (DsInstConfirm *)sender;

@end


@interface DsInstConfirm : UIView

@property(nonatomic, retain) IBOutlet  UILabel *label;
@property(nonatomic, retain) IBOutlet  UIButton *confirmBtn;
@property(nonatomic, retain) IBOutlet  UISwitch *switchCtrl;

@property (nonatomic, weak) id <DsInstConfirmDelegate> delegate;

- (IBAction)doStart:(id)sender;

@end


