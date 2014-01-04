//
//  DsWebViewController.h
//  duosuccess
//
//  Created by Rick Li on 12/13/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMWebView.h"
#import "DsMusicPlayer.h"
#import "DsMusicControll.h"


@interface DsWebViewController : UIViewController<SAMWebViewDelegate,DsMusicPlayerDelegate, DsMusicControlDelegate, UIAlertViewDelegate>

@property (nonatomic, readonly) SAMWebView *webView;
@property (nonatomic, assign) BOOL toolbarHidden;
@property (nonatomic, readonly) NSURL *currentURL;

@property BOOL displayWebViewByDefault;

-(void) displayWebView;


@end
