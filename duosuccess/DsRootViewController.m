//
//  DsRootViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsRootViewController.h"
#import "DsMenuViewController.h"
#import "DsDataStore.h"

@interface DsRootViewController ()

@end

@implementation DsRootViewController



- (void)awakeFromNib{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.backgroundImage = [UIImage imageNamed:@"StarsBj"];
    self.delegate = (DsMenuViewController *)self.menuViewController;
    if(![[DsDataStore sharedInstance] isCensorMode]){
        self.panGestureEnabled = false;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
