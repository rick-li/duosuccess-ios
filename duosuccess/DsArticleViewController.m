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

@interface DsArticleViewController ()

@end

@implementation DsArticleViewController

@synthesize imageView;
@synthesize contentView;

@synthesize imageUrl;
@synthesize content;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:true];
    self.navigationController.navigationBar.topItem.title = @"   ";
    
}

@end
