//
//  DsMusicViewController.h
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DsInstConfirm.h"
#import "SAMWebView.h"
#import "DsMusicPlayer.h"
#import "DsMusicControll.h"
#import "DsWebViewController.h"

@interface DsMusicViewController : DsWebViewController<UIScrollViewDelegate, DsInstConfirmDelegate, DsMusicPlayerDelegate, DsMusicControlDelegate>


@end
