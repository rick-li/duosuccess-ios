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

@interface DsMusicViewController : UIViewController<UIScrollViewDelegate, DsInstConfirmDelegate, SAMWebViewDelegate>

@property (nonatomic, assign) BOOL toolbarHidden;
@property (nonatomic, readonly) SAMWebView *webView;
@property (nonatomic, readonly) NSURL *currentURL;

@end
