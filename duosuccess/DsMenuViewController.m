//
//  DsMenuViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsMenuViewController.h"
#import "DsDataStore.h"

#import "DsConst.h"
#import "DsMainListImpl.h"
#import "DsCategoryListImpl.h"

@interface DsMenuViewController ()

@property NSMutableArray *categories;
@property DsListViewController *listCtrl;
@property DsMainListImpl *mainList;
@property DsCategoryListImpl *cateList;

@end

@implementation DsMenuViewController
@synthesize categories;

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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CATEGORY_UPDATED object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self loadCategories];
    }];
    
    [self loadCategories];
}


- (void)loadCategories
{
    
    if(self.tableView != nil){
        [self.tableView removeFromSuperview];
    }
    NSArray *categoriesFromDB = [[DsDataStore sharedInstance] queryCategories];
    if([categoriesFromDB count] <= 0){
        return;
    }
    self.categories = [[NSMutableArray alloc] init];
    
    [self.categories addObject:[NSDictionary dictionaryWithObjects:@[@"", NSLocalizedString(@"mainTitle", @"duosuccess")] forKeys:@[@"objectId",@"name"]]];
    [self.categories addObjectsFromArray:categoriesFromDB];
    
    

    
    int count = self.categories.count;
        NSLog(@"categories count %ul.", count);
	self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * count) / 2.0f, self.view.frame.size.width, 54 * count) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainIphone" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
    
    
    NSDictionary *category = [self.categories objectAtIndex:indexPath.row];
    
    if(self.mainList == nil){
        self.mainList = [[DsMainListImpl alloc]init];
    }
    
    if(self.cateList == nil){
        self.cateList = [[DsCategoryListImpl alloc] init];
    }
    
    if(self.listCtrl == nil){
        if([[navigationController.viewControllers objectAtIndex:0] isKindOfClass:DsListViewController.class]){
            self.listCtrl = [navigationController.viewControllers objectAtIndex:0];
        }else{
            self.listCtrl = [sb instantiateViewControllerWithIdentifier:@"listController"];
        }
    }

    if([@"main" isEqualToString: [category valueForKey:@"name"]]){
        self.listCtrl.listDelegate = self.mainList;
        [self.mainList loadArticle:self.listCtrl];
    }else{
        self.listCtrl.listDelegate = self.cateList;
        self.cateList.category = category;
        [self.cateList loadArticle:self.listCtrl];
    }
    navigationController.viewControllers = @[self.listCtrl];
    
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    
    return self.categories.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSManagedObject *category = [self.categories objectAtIndex:indexPath.row];
    NSLog(@"name is %@", [category valueForKey:@"name"]);
    cell.textLabel.text = [category valueForKey:@"name"];
    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController");
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController");
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController");
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController");
}


@end
