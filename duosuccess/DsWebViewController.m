//
//  DsWebViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/13/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsWebViewController.h"
#import "DsMusicPlayer.h"
#import "DsMusicControll.h"
#import "DsFileStore.h"
#import "DsEventStore.h"
#import "DsPaperController.h"
#import <MessageUI/MessageUI.h>
#import <EventKit/EventKit.h>

@interface DsWebViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, readonly) UIImageView *bgView;


@property UIScrollView *instructionContainer;
@property UIPageControl *instructionPageCtrl;
@property DsMusicControll *musicCtrl;
@property DsMusicPlayer *musicPlayer;


@property UIBarButtonItem *screenshotButtonItem;

@end

@implementation DsWebViewController

@synthesize displayWebViewByDefault;
@synthesize webView = _webView;
@synthesize bgView = _bgView;
@synthesize toolbarHidden = _toolbarHidden;
@synthesize currentURL;
@synthesize indicatorView = _indicatorView;
@synthesize backBarButtonItem = _backBarButtonItem;
@synthesize forwardBarButtonItem = _forwardBarButtonItem;
@synthesize musicCtrl;
@synthesize musicPlayer;

DsFileStore *fileStore;

- (id)init
{
    self = [super init];
    self.displayWebViewByDefault = false;
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    fileStore = [DsFileStore sharedInstance];
    
    if(self.displayWebViewByDefault){
        [self displayWebView];
    }
    
    [self clearCache];
    
}



#pragma mark - Actions

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)flashCompleted:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    
}

-(void)flashScreen {
    [CATransaction begin];
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    NSArray *animationValues = @[ @0.9f, @0.0f ];
    NSArray *animationTimes = @[ @0.5f, @1.0f ];
    id timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    NSArray *animationTimingFunctions = @[ timingFunction, timingFunction ];
    [opacityAnimation setValues:animationValues];
    [opacityAnimation setKeyTimes:animationTimes];
    [opacityAnimation setTimingFunctions:animationTimingFunctions];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.duration = 0.6;
    [CATransaction setCompletionBlock:^{
        NSLocalizedString(@"energyPaperDownloaded", @"Energy paper is downloaded");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"西格瑪能紙已下載" message:@"請於我的能紙處查看" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"check", "Check")];
        [alert show];
        
    }];
    
    [self.webView.layer addAnimation:opacityAnimation forKey:@"animation"];
    [CATransaction commit];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"button index is %d", buttonIndex);
    if(buttonIndex == 1){
        //check the paper
        DsPaperController *pCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"paperController"];
        
        //replace current view controller
//        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:pCtrl animated:TRUE];

    }
}

- (void)takeScreenshot:(id)sender {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.webView.bounds.size);
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    
    [fileStore savePaperImage:data];
    [[DsEventStore sharedInstance] savePaperReminder];
    [self flashScreen];
    
}

#pragma mark - Private

- (void)updateBrowserUI {
	self.backBarButtonItem.enabled = [self.webView canGoBack];
	self.forwardBarButtonItem.enabled = [self.webView canGoForward];
    
	UIBarButtonItem *reloadButton = nil;
	
	if ([self.webView isLoadingPage]) {
		[self.indicatorView startAnimating];
		reloadButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"SAMWebView-stop-button"]
                        landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-stop-button-mini"]
                        style:UIBarButtonItemStylePlain
                        target:self.webView
                        action:@selector(stopLoading)];
	} else {
		[self.indicatorView stopAnimating];
		reloadButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"SAMWebView-reload-button"]
                        landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-reload-button-mini"]
                        style:UIBarButtonItemStylePlain
                        target:self.webView
                        action:@selector(reload)];
	}
    [reloadButton setTintColor: [UIColor whiteColor]];
	
	NSMutableArray *items = [self.toolbarItems mutableCopy];
	[items replaceObjectAtIndex:5 withObject:reloadButton];
	self.toolbarItems = items;
}


#pragma mark - SAMWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        if([url.scheme isEqualToString:@"http"] && [url.host isEqualToString:@"www.duosuccess.com"]){
            NSString *strUrl = [url absoluteString];
            NSString *newUrl = [strUrl stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
            [self.webView loadURL:[NSURL URLWithString:newUrl]];
            NSLog(@"override http -> https %@.", newUrl);
            return false;
        }
    }
    return true;
}


- (void)webViewDidStartLoadingPage:(SAMWebView *)webView {
    NSURL *URL = self.currentURL;
	self.title = URL.absoluteString;
	[self updateBrowserUI];
    
	if (!self.toolbarHidden) {
		[self.navigationController setToolbarHidden:[URL isFileURL] animated:YES];
	}
}

- (void)webViewDidFinishLoadingPage:(SAMWebView *)webView {
	[self updateBrowserUI];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([title length] > 0) {
        self.title = title;
    }
    NSString *lowerCaseTitle = [title lowercaseString];
    if([lowerCaseTitle rangeOfString:@"paper"].location!=NSNotFound || [lowerCaseTitle rangeOfString:@"calendar"].location!=NSNotFound){
        [_screenshotButtonItem setEnabled:true];
    }else{
        [_screenshotButtonItem setEnabled:false];
    }
    
    if(self.musicCtrl){
        [self musicStop:nil];
        [self.musicCtrl removeFromSuperview];
        self.musicCtrl = nil;
    }
    [self playMusic:webView];
    NSLog(@"webview finished loading...");
}


- (UIActivityIndicatorView *)indicatorView {
	if (!_indicatorView) {
		_indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
		_indicatorView.hidesWhenStopped = YES;
	}
	return _indicatorView;
}


- (UIBarButtonItem *)backBarButtonItem {
	if (!_backBarButtonItem) {
		_backBarButtonItem = [[UIBarButtonItem alloc]
                              initWithImage:[UIImage imageNamed:@"SAMWebView-back-button"]
                              landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-back-button-mini"]
                              style:UIBarButtonItemStylePlain
                              target:self.webView
                              action:@selector(goBack)];
        [_backBarButtonItem setTintColor: [UIColor whiteColor]];
	}
	return _backBarButtonItem;
}


- (UIBarButtonItem *)forwardBarButtonItem {
	if (!_forwardBarButtonItem) {
		_forwardBarButtonItem = [[UIBarButtonItem alloc]
								 initWithImage:[UIImage imageNamed:@"SAMWebView-forward-button"]
								 landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-forward-button-mini"]
								 style:UIBarButtonItemStylePlain
								 target:self.webView
								 action:@selector(goForward)];
        [_forwardBarButtonItem setTintColor: [UIColor whiteColor]];
	}
	return _forwardBarButtonItem;
}

-(void) displayWebView{
    //display toolbar
    if (!self.toolbarHidden && ![self.currentURL isFileURL]) {
        [self.navigationController setToolbarHidden:NO animated:true];
    }
    
    // Loading indicator
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
	
    UIColor *white = [UIColor whiteColor];
    
    // Toolbar buttons
	UIBarButtonItem *reloadBarButtonItem = [[UIBarButtonItem alloc]
											initWithImage:[UIImage imageNamed:@"SAMWebView-reload-button"]
											landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-reload-button-mini"]
											style:UIBarButtonItemStylePlain
											target:self.webView
											action:@selector(reload)];
    
    
	_screenshotButtonItem = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"camera"]
                             landscapeImagePhone:[UIImage imageNamed:@"camera"]
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(takeScreenshot:)];
    
    //	UIBarButtonItem *actionSheetBarButtonItem = [[UIBarButtonItem alloc]
    //												 initWithImage:[UIImage imageNamed:@"SAMWebView-action-button"]
    //												 landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-action-button-mini"]
    //												 style:UIBarButtonItemStylePlain
    //												 target:self
    //												 action:@selector(openActionSheet:)];
    
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
									  target:nil action:nil];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								   target:nil action:nil];
    fixedSpace.width = 10.0;
    
    
    [reloadBarButtonItem setTintColor: white];
    //    [actionSheetBarButtonItem  setTintColor: white];
    [_screenshotButtonItem setTintColor:white];
    [_backBarButtonItem setTintColor: white];
    [_forwardBarButtonItem setTintColor: white];
    
	self.toolbarItems = @[fixedSpace, self.backBarButtonItem, flexibleSpace, self.forwardBarButtonItem, flexibleSpace,
                          reloadBarButtonItem, flexibleSpace, _screenshotButtonItem];
	
    // Close button
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
	}
    
    // Web view
    if(!self.bgView){
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listBg"]];
        _bgView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.webView.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0.0];
    }
    self.bgView.frame = self.view.bounds;
	self.webView.frame = self.view.bounds;

    [self.view addSubview:self.bgView];
	[self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    NSLog(@"webview will disappear..");
    [self.musicPlayer stopMedia];
    if (!self.toolbarHidden) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - URL Loading

- (NSURL *)currentURL {
    return [self.webView.lastRequest mainDocumentURL];
}


#pragma mark - Accessors

- (SAMWebView *)webView {
    if (_webView == nil) {
        _webView = [[SAMWebView alloc] init];
        _webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.opaque = FALSE;
    }
    return _webView;
}



//start music part
- (void)onTapPlayButon: (DsMusicControll *)sender{
    if(musicPlayer.isPlaying){
        [self clearCache];
        [self.musicPlayer stopMedia];
    }else{
        [self.webView reload];
    }
}

- (void)tick: (long)elapsed remains:(long)remains{
    NSLog(@"elapsed %ld, remains %ld.",elapsed, remains );
    long elapsedMins = elapsed/60;
    long elapsedSecs = elapsed-(elapsedMins*60);
    NSString *elapsedDisplay = [NSString stringWithFormat:@"%lu:%02lu", elapsedMins, elapsedSecs];
    
    long remainsMins = remains/60;
    long remainsSecs = remains-(remainsMins*60);
    NSString *remainsDisplay = [NSString stringWithFormat:@"%lu:%02lu", remainsMins, remainsSecs];
    
    self.musicCtrl.elapsed.text = elapsedDisplay;
    self.musicCtrl.remains.text = remainsDisplay;
    [self.musicCtrl.slider setValue:elapsed];
    
}

- (void)clearCache{
    
    [fileStore clearMusicCache];
}

-(void)musicStop:(DsMusicPlayer *)sender{
    [musicCtrl onTapPlayButton:nil];
}

-(void)playMusic:(SAMWebView *)webView {
    NSString *strjs = @"document.querySelector('embed').src";
    NSString *midUrl = [webView stringByEvaluatingJavaScriptFromString:strjs];
    
    //remove mask
    NSLog(@"mid Url is %@", midUrl);
    
    if(!midUrl || [midUrl length]==0){
        NSLog(@"no midi in this page, don't play music");
        return;
    }
    
    
    //download midi
    NSURL *url = [NSURL URLWithString:
                  midUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSString *tmpDir = [fileStore tmpDir];
    if(data)
    {
        NSString *midPath = [tmpDir stringByAppendingPathComponent:[url lastPathComponent]];
        [data writeToFile:midPath atomically:YES];
        NSLog(@"midi file path is %@", midPath);
        self.musicPlayer = [DsMusicPlayer sharedInstance];
        [musicPlayer playMedia:midPath];
        musicPlayer.isPlaying = true;
        
        musicPlayer.delegate = self;
        
        self.musicCtrl = [[[NSBundle mainBundle] loadNibNamed:@"DsMusicControl" owner:self options:nil] objectAtIndex:0];
        self.musicCtrl.slider.minimumValue = 0;
        self.musicCtrl.slider.maximumValue = 3600;
        musicCtrl.delegate = self ;
        int musicCtrlHeight = self.musicCtrl.frame.size.height;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            //compensate the edge for ios7.
            musicCtrlHeight -= self.navigationController.toolbar.frame.size.height;
        }
        [self.musicCtrl setCenter: CGPointMake(self.view.frame.size.width/2.0, self.webView.frame.size.height-musicCtrlHeight)];
        [self.view addSubview:self.musicCtrl];
        
    }
}




@end
