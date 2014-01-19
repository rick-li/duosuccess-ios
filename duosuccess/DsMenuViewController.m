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
#import "UIColor+Hex.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface DsMenuViewController ()

@property NSMutableArray *categories;

@property DsMainListImpl *mainList;
@property DsCategoryListImpl *cateList;

@end

@implementation DsMenuViewController
@synthesize categories;

int menuItemHeight = 54;

int marginLeft = 50;
int marginTop = 100;

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
    
    UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
    self.listCtrl = [navigationController.viewControllers objectAtIndex:0];
   

}


- (void)loadCategories
{
    NSLog(@"load Categories.");
    
    if(!IS_IPHONE_5){
        marginTop = 50;
        marginLeft = 55;
    }

    
    NSArray *categoriesFromDB = [[DsDataStore sharedInstance] queryCategories];
    if([categoriesFromDB count] <= 0){
        return;
    }
    self.categories = [[NSMutableArray alloc] init];
    
    [self.categories addObjectsFromArray:categoriesFromDB];
    
    NSMutableDictionary *firstCategory = [[NSMutableDictionary alloc] init];
    [firstCategory addEntriesFromDictionary: [self.categories objectAtIndex:0]];
    [firstCategory setObject: NSLocalizedString(@"mainTitle", @"duosuccess") forKey:@"name"];

    [firstCategory setValue:[NSNumber numberWithBool:true] forKey:@"isMain"];
    [self.categories replaceObjectAtIndex:0 withObject:firstCategory];
    int count = self.categories.count;
    NSLog(@"categories count %ul.", count);
    NSLog(@"Menu Container height is %f.", self.view.frame.size.height);
    if(!self.tableView){
        self.tableView = ({
            int y = (self.view.frame.size.height - menuItemHeight * count) / 2.0f;

            NSLog(@"y is %d ",y);
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(marginLeft, marginTop, self.view.frame.size.width, menuItemHeight * count) style:UITableViewStylePlain];
            
            tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.opaque = NO;
            tableView.backgroundView = nil;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.bounces = NO;
            tableView.scrollsToTop = NO;
            tableView;
        });
        [self.view addSubview:self.tableView];
    }else{

        int y = (self.view.frame.size.height - menuItemHeight * count) / 2.0f;
        int w = self.view.frame.size.width;
        NSLog(@"y is %d ",y);
        self.tableView.frame = CGRectMake(marginLeft, marginTop, w, menuItemHeight * count);

        [self.tableView reloadData];
    }
    
    
    
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
    
    if( [category valueForKey:@"isMain"]){
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
    return menuItemHeight;
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

//        cell.textLabel.textColor = [UIColor colorWithHex:0x007bd9 alpha:1];
        cell.textLabel.textColor = [UIColor colorWithHex:0x0190b9 alpha:1];
        
//        cell.textLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1];
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:22]];
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
