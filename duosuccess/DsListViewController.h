//
//  DsListViewController.h
//  duosuccess
//
//  Created by Rick Li on 12/24/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RESideMenu.h"
#import "IntroControll.h"
#import "DsArticleViewController.h"
#import "DsIntroViewController.h"



@protocol DsListDelegate <NSObject>

-(void) init: (NSObject*) ctrl;
-(void) setCategory: (NSDictionary*) category;
-(void) loadArticle: (id) ctrl;
-(NSString*) getTitle;

@end


@interface DsListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property id <DsListDelegate> listDelegate;

@property IntroControll *introCtrl;

@property UITableViewController *tableCtrl;
@property UIRefreshControl *refreshCtrl;
@property DsArticleViewController *articleCtrl;

@property NSArray *introArticles;
@property NSArray *tableArticles;

-(void)loadArticles;

-(void) createIntroContrainer:(NSArray*) introData;

@property(nonatomic, retain) IBOutlet UIView *pageContainer;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *introContainer;


- (IBAction)sonarClockAction:(id)sender;

-(IBAction)showMenu;

-(IBAction)musicAction;

-(IBAction)browserAction;

-(IBAction)paperAction;

-(IBAction)configAction;

- (IBAction)onTapIntro:(id)sender;



@end
