//
//  DsMusicViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsMusicViewController.h"
#import "DsMusicBrowserView.h"

@interface DsMusicViewController ()

@property UIScrollView *instructionContainer;
@property UIPageControl *instructionPageCtrl;
@property DsInstConfirm *confirmView;
@property DsMusicBrowserView *musicBrowserView;
@end

@implementation DsMusicViewController
@synthesize confirmView;
@synthesize musicBrowserView;

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
    //display the page controller
    [self displayInstruction];
}


- (void)displayInstruction{
    NSArray *pages = @[@"musicInst1", @"musicInst2", @"musicInst3"];
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
        
//        UIButton *okBtn = [[UIButton alloc] init];
//
//        [okBtn setFrame:CGRectMake(173, 269, 130, 44)];
//        [okBtn setTitle:@"I Understand." forState:UIControlStateNormal];
//        [okBtn setCenter: CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height-100)];
//        [self.view addSubview: okBtn];
        
      

        [self.instructionContainer addSubview:slide];
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self.instructionPageCtrl setCurrentPage:page];
    if(page == 2){

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
    for (UIView *aView in [self.view subviews]){
        
        [aView removeFromSuperview];
        
    }
     self.musicBrowserView = [[[NSBundle mainBundle] loadNibNamed:@"DsMusicBrowser" owner:self options:nil] objectAtIndex:0];
    
    [self.view addSubview:self.musicBrowserView];
    NSURL *url =[NSURL URLWithString:@"https://www.duosuccess.com"];

    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.musicBrowserView.webView loadRequest:request];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
