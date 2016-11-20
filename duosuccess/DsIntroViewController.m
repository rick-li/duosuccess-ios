//
//  DsMusicViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsIntroViewController.h"

#import "SAMWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "DsMusicPlayer.h"
#import "DsMusicControll.h"

NSString *const DsSkipMusicIntro = @"DsSkipMusicIntro";
NSString *const DsSkipPaperIntro = @"DsSkipPaperIntro";

@interface DsIntroViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>


@property UIScrollView *instructionContainer;
@property UIPageControl *instructionPageCtrl;
@property DsInstConfirm *confirmView;

@end

@implementation DsIntroViewController
@synthesize confirmView;
@synthesize skipIntroKey;
@synthesize instructPages;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: YES animated:NO];
    
    //display instructin by default.
    [self displayInstruction];
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setToolbarHidden:true];
    
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
    NSArray *pages = instructPages;
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
        self.confirmView.label.text=NSLocalizedString(@"dontShowAgain", "");
    self.confirmView.confirmBtn.titleLabel.text=NSLocalizedString(@"start", "");
        
        [self.confirmView.switchCtrl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

        self.confirmView.frame = CGRectMake(0, self.view.frame.size.height - self.confirmView.frame.size.height, self.confirmView.frame.size.width, self.confirmView.frame.size.height);
        self.confirmView.delegate = self;
        [self.view addSubview:self.confirmView];
        
    }else{
        
        [self.confirmView removeFromSuperview];
    }
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES] forKey:skipIntroKey];
    }else {
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO] forKey:skipIntroKey];
    }
}

- (void)start: (DsInstConfirm *)dsInstConfirm{
    NSLog(@"Start pressed");
    UINavigationController *navController = self.navigationController;
    
    
    DsWebViewController *webViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewCtrl.displayWebViewByDefault = true;
    [webViewCtrl.webView loadURLString:@"http://69.195.73.224"];
    
    [navController setNavigationBarHidden: NO animated:NO];
    [navController popViewControllerAnimated:NO];
    
    [navController pushViewController:webViewCtrl animated:TRUE];
}

@end
