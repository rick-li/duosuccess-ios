//
//  DsArticleViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsArticleViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "DsWebViewController.h"

@interface DsArticleViewController ()

@end

@implementation DsArticleViewController

@synthesize imageView;
@synthesize contentView;
@synthesize containerView;
@synthesize titleView;
@synthesize dateView;
@synthesize moreBtn;


@synthesize imageUrl;
@synthesize content;
@synthesize titleTxt;
@synthesize dateTxt;
@synthesize viewMoreLink;


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
    
    if(imageUrl){
        [imageView setImageWithURL:(NSURL *)imageUrl placeholderImage:[UIImage imageNamed:@"placeholder" ] usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleWhite];
    }else{
        //set to a default image
        imageView.image = [UIImage imageNamed:@"placeholder"];
    }

    NSURL *baseUrl = [NSURL URLWithString:@"https://www.duosuccess.com"];
    [self.contentView loadHTMLString:self.content baseURL:baseUrl];
    self.contentView.scrollView.scrollEnabled = false;
    self.contentView.delegate = self;
    self.titleView.text = titleTxt;
    self.dateView.text = dateTxt;
//    self.moreBtn.titleLabel.text = NSLocalizedString(@"viewMore", @"View More");
    [self.moreBtn setTitle:NSLocalizedString(@"viewMore", @"View More") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:true];
//    self.navigationController.navigationBar.topItem.title = @"   ";
    self.containerView.scrollEnabled = true;

}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    float h;
    NSString *heightString = [contentView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    
    NSLog(@"web content is %@ high",heightString);
    h = [heightString floatValue] +12.0f;
    contentView.frame = CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.size.width, h);
    
    // get bottom of text field
    
    h = contentView.frame.origin.y + h; // extra 70 pixels for UIButton at bottom and padding.
    
    [self.containerView setContentSize:CGSizeMake(320, h)];
}

- (IBAction)onClickViewMore:(id)sender {
    NSLog(@"onc click view more");
    NSString *url = @"https://www.duosuccess.com";
    if(!self.viewMoreLink || (NSNull *)self.viewMoreLink != [NSNull null]){
        url = self.viewMoreLink;
    }
    DsWebViewController *webViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewCtrl.displayWebViewByDefault = true;
    [webViewCtrl.webView loadURLString:url];
    [self.navigationController pushViewController:webViewCtrl animated:true];
}

@end
