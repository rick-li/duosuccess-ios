//
//  DsMusicViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsMusicViewController.h"

#import "SAMWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "DsMusicPlayer.h"
#import "DsMusicControll.h"

@interface DsMusicViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *forwardBarButtonItem;

@property UIScrollView *instructionContainer;
@property UIPageControl *instructionPageCtrl;
@property DsInstConfirm *confirmView;
@property DsMusicControll *musicCtrl;
@property DsMusicPlayer *musicPlayer;

@end

@implementation DsMusicViewController
@synthesize confirmView;



@synthesize webView = _webView;
@synthesize toolbarHidden = _toolbarHidden;
@synthesize indicatorView = _indicatorView;
@synthesize backBarButtonItem = _backBarButtonItem;
@synthesize forwardBarButtonItem = _forwardBarButtonItem;
@synthesize musicCtrl;
@synthesize musicPlayer;

NSString *tmpDir;

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
	}
	return _forwardBarButtonItem;
}



#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

    tmpDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"/File"];
    [self clearCache];
    
    //display instructin by default.
    [self displayInstruction];
    
   
}

- (void)clearCache{
    NSError *error = nil;

    
    NSLog(@"temp dir is %@", tmpDir);
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:tmpDir];
    
    
    if(folderExists){
        NSURL *url = [NSURL URLWithString:tmpDir];
        NSLog(@"URL: %@", url);
        BOOL isRemoved = [[NSFileManager defaultManager] removeItemAtURL:url error: &error];
        
        NSLog (@"Temp Dir removed: %@", isRemoved ? @"YES" : @"NO");
    }
    
}

-(void) displayWebView{
    //display toolbar
    if (!self.toolbarHidden && ![self.currentURL isFileURL]) {
        [self.navigationController setToolbarHidden:NO animated:true];
    }
    
    // Loading indicator
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
	
    // Toolbar buttons
	UIBarButtonItem *reloadBarButtonItem = [[UIBarButtonItem alloc]
											initWithImage:[UIImage imageNamed:@"SAMWebView-reload-button"]
											landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-reload-button-mini"]
											style:UIBarButtonItemStylePlain
											target:self.webView
											action:@selector(reload)];
    
	UIBarButtonItem *safariBarButtonItem = [[UIBarButtonItem alloc]
											initWithImage:[UIImage imageNamed:@"SAMWebView-safari-button"]
											landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-safari-button-mini"]
											style:UIBarButtonItemStylePlain
											target:self
											action:@selector(openSafari:)];
    
	UIBarButtonItem *actionSheetBarButtonItem = [[UIBarButtonItem alloc]
												 initWithImage:[UIImage imageNamed:@"SAMWebView-action-button"]
												 landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-action-button-mini"]
												 style:UIBarButtonItemStylePlain
												 target:self
												 action:@selector(openActionSheet:)];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
									  target:nil action:nil];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								   target:nil action:nil];
    fixedSpace.width = 10.0;
    
	self.toolbarItems = @[fixedSpace, self.backBarButtonItem, flexibleSpace, self.forwardBarButtonItem, flexibleSpace,
                          reloadBarButtonItem, flexibleSpace, safariBarButtonItem, flexibleSpace, actionSheetBarButtonItem, fixedSpace];
	
    // Close button
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
	}
    
    // Web view
	self.webView.frame = self.view.bounds;
	[self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
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
    }
    return _webView;
}


#pragma mark - Actions

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)openSafari:(id)sender {
	[[UIApplication sharedApplication] openURL:self.currentURL];
}


- (void)openActionSheet:(id)sender {
	UIActionSheet *actionSheet = nil;
	
	if (![MFMailComposeViewController canSendMail]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy URL", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy URL", @"Email URL", nil];
	}
    
	if (self.navigationController) {
		actionSheet.actionSheetStyle = (UIActionSheetStyle)self.navigationController.navigationBar.barStyle;
	}
	
	[actionSheet showInView:self.navigationController.view];
}


- (void)copyURL:(id)sender {
	[[UIPasteboard generalPasteboard] setURL:self.currentURL];
}


- (void)emailURL:(id)sender {
	if (![MFMailComposeViewController canSendMail]) {
		return;
	}
	
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.subject = self.title;
	controller.mailComposeDelegate = self;
	[controller setMessageBody:self.webView.lastRequest.mainDocumentURL.absoluteString isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil];
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
	
	NSMutableArray *items = [self.toolbarItems mutableCopy];
	[items replaceObjectAtIndex:5 withObject:reloadButton];
	self.toolbarItems = items;
}


#pragma mark - SAMWebViewDelegate

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
    
    NSLog(@"webview finished loading...");
    
    NSString *strjs = @"document.querySelector('embed').src";
    NSString *midUrl = [webView stringByEvaluatingJavaScriptFromString:strjs];
    
    //remove mask
    NSLog(@"mid Url is %@", midUrl);
    
    if(!midUrl || [midUrl length]==0){
        NSLog(@"no midi in this page, don't play music");
        return;
    }
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDir])
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:&error];
    
    //download midi
    NSURL *url = [NSURL URLWithString:
                  midUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if(data)
    {
        NSString *midPath = [tmpDir stringByAppendingPathComponent:[url lastPathComponent]];
        [data writeToFile:midPath atomically:YES];
        NSLog(@"midi file path is %@", midPath);
        self.musicPlayer = [DsMusicPlayer sharedInstance];
        [musicPlayer playMedia:midPath];
        
        musicPlayer.delegate = self;
        
        self.musicCtrl = [[[NSBundle mainBundle] loadNibNamed:@"DsMusicControl" owner:self options:nil] objectAtIndex:0];
        self.musicCtrl.slider.minimumValue = 0;
        self.musicCtrl.slider.maximumValue = 3600;
        musicCtrl.delegate = self ;
        int musicCtrlHeight = self.musicCtrl.frame.size.height;
        [self.musicCtrl setCenter: CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height-musicCtrlHeight)];
        [self.view addSubview:self.musicCtrl];
        CGRect frame = self.webView.frame;
        frame.size.height = frame.size.height - musicCtrlHeight ;
        [self.webView setFrame: frame];
    }
}

- (void)onTapPlayButon: (DsMusicControll *)sender{
    [self.musicPlayer stopMedia];
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self copyURL:actionSheet];
	}
    else if (buttonIndex == 1) {
		[self emailURL:actionSheet];
	}
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)displayInstruction{
    NSArray *pages = @[@"musicInst1", @"musicInst2"];
    //Initial ScrollView
    self.instructionContainer = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.instructionContainer.backgroundColor = [UIColor clearColor];
        self.instructionContainer.pagingEnabled = YES;
        self.instructionContainer.showsHorizontalScrollIndicator = NO;
        self.instructionContainer.showsVerticalScrollIndicator = NO;
    self.instructionContainer.delegate = self;
    [self.view addSubview:self.instructionContainer];
    
    //Initial PageView
    self.instructionPageCtrl = [[UIPageControl alloc] init];
        self.instructionPageCtrl.numberOfPages = pages.count;
    [    self.instructionPageCtrl sizeToFit];
    [    self.instructionPageCtrl setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height-50)];
    [self.view addSubview:  self.instructionPageCtrl];
    
    
    self.instructionContainer.contentSize = CGSizeMake(pages.count * self.view.frame.size.width, self.view.frame.size.height);
    self.instructionContainer.delegate = self;
    CGSize scrollViewSize = self.instructionContainer.frame.size;
    //insert TextViews into ScrollView
    for(int i = 0; i <  pages.count; i++) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed: pages[i] ]];
        CGRect slideRect = CGRectMake(scrollViewSize.width * i, 0, scrollViewSize.width, scrollViewSize.height);
        
        UIView *slide = [[UIView alloc] initWithFrame:slideRect];
        [slide setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [slide addSubview:image];

        [self.instructionContainer addSubview:slide];
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self.instructionPageCtrl setCurrentPage:page];
    if(page == 1){

            self.confirmView = [[[NSBundle mainBundle] loadNibNamed:@"DsInstConfrim" owner:self options:nil] objectAtIndex:0];
            [self.confirmView setCenter: CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height-100)];
        self.confirmView.delegate = self;
            [self.view addSubview:self.confirmView];

    }else{
        
        [self.confirmView removeFromSuperview];
    }
}

- (void)start: (DsInstConfirm *)dsInstConfirm{
    NSLog(@"Start pressed");
    //remove instructions if it has
    for (UIView *subView in [self.view subviews]){
        [subView removeFromSuperview];
    }
    [self displayWebView];
    [self.webView loadURLString:@"https://www.duosuccess.com"];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
