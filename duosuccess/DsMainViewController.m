//
//  DsMainViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsMainViewController.h"
#import "DsArticleViewController.h"
#import "DsTableCell.h"
#import "DsDataStore.h"

@interface DsMainViewController ()
@property UITableViewController *tableCtrl;
@property UIRefreshControl *refreshCtrl;
@property DsArticleViewController *articleCtrl;
@end

@implementation DsMainViewController

@synthesize tableView;
@synthesize introCtrl;
@synthesize articles;
@synthesize introContainer;
@synthesize tableCtrl;
@synthesize refreshCtrl;
@synthesize articleCtrl;

@synthesize selectedCategory;

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
    if(self.selectedCategory == nil){
        self.selectedCategory = @"hb9xA3ZwjR";
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"Example 1" description:@"Hi, my name is Dmitry" image:@"phone"];
    
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"Example 2" description:@"Several sample texts in Old, Middle, Early Modern, and Modern English are provided here " image:@"tea"];
    
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"Example 3" description:@"The Tempest is the first play in the First Folio edition (see the signature) even though it." image:@"cloth"];
    self.introCtrl = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 190.0f) pages:@[model1, model2, model3]];
    
    if(self.tableCtrl == nil){
        self.tableCtrl = [[UITableViewController alloc] init];
    }
    
    
    self.refreshCtrl = [[UIRefreshControl alloc] init];
    [self.refreshCtrl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    self.tableCtrl.refreshControl = refreshCtrl;
    self.tableCtrl.tableView = self.tableView;

    [self.introContainer addSubview:self.introCtrl];
    
    self.articles = [[DsDataStore sharedInstance] queryArticlesByCategory:self.selectedCategory];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) showMenu{
    [self.sideMenuViewController presentMenuViewController];
}

-(IBAction)musicAction{
    UIViewController *musicCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"musicController"];

    [self.navigationController pushViewController:musicCtrl animated:true];
}

-(void)changeCategory:(NSString *) categoryId{
    self.selectedCategory = categoryId;
    self.articles = [[DsDataStore sharedInstance] queryArticlesByCategory:categoryId];
    [self.tableView reloadData];
}

- (void)refreshTable{
    NSLog(@"refreshing");
    [self.refreshCtrl endRefreshing];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    self.articleCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"articleController"];
    [self.navigationController pushViewController:self.articleCtrl animated:true];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    
    return self.articles.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DsTableCell";
    
    DsTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DsTableCell" owner:self options:nil];//加载自定义cell的xib文件
        cell = [array objectAtIndex:0];
        

    }
    NSManagedObject *article = [self.articles objectAtIndex:indexPath.row];
    cell.title.text = [article valueForKey:@"title"];
    cell.intro.text = [article valueForKey:@"intro"];
    cell.intro.numberOfLines = 0;
    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}




@end
