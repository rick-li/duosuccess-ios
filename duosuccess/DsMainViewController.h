//
//  DsMainViewController.h
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroControll.h"
#import "RESideMenu.h"

#if USES_IASK_STATIC_LIBRARY
#import "InAppSettingsKit/IASKAppSettingsViewController.h"
#else
#import "IASKAppSettingsViewController.h"
#endif

@interface DsMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


@property IntroControll *introCtrl;
@property NSArray *articles;
@property NSString *selectedCategory;


@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *introContainer;

-(IBAction)showMenu;

-(IBAction)musicAction;

-(IBAction)browserAction;

-(IBAction)paperAction;

-(IBAction)configAction;

-(void)changeCategory:(NSString *) categoryId;

@end
