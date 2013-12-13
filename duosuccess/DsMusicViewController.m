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


@property UIScrollView *instructionContainer;
@property UIPageControl *instructionPageCtrl;
@property DsInstConfirm *confirmView;
@property DsMusicControll *musicCtrl;
@property DsMusicPlayer *musicPlayer;

@end

@implementation DsMusicViewController
@synthesize confirmView;

@synthesize musicCtrl;
@synthesize musicPlayer;

NSString *tmpDir;



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

-(void)playMusic:(SAMWebView *)webView {
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

- (void)webViewDidFinishLoadingPage:(SAMWebView *)webView {
	[super webViewDidFinishLoadingPage:webView];
    NSLog(@"webview finished in music controller");
    [self playMusic:webView];
   
}

- (void)onTapPlayButon: (DsMusicControll *)sender{
    [self clearCache];
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
    [super displayWebView];
    [super.webView loadURLString:@"https://www.duosuccess.com"];
    
}


@end
