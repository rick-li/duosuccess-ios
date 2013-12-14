//
//  DsArticleViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsArticleViewController.h"

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
    [self.imageView setImage:[UIImage imageNamed:@"tea"]];
    self.contentView.text = content;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:true];
    
}

@end
