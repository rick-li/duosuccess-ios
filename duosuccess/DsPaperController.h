//
//  DsPaperController.h
//  duosuccess
//
//  Created by Rick Li on 12/13/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsWebViewController.h"

@interface DsPaperController : DsWebViewController<UIAlertViewDelegate>

    @property(nonatomic, retain) IBOutlet UIImageView *paperView;
    @property(nonatomic, retain) IBOutlet UILabel *remainLabel;
    @property(nonatomic, retain) IBOutlet UIView *remainContainer;
@end
