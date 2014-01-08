//
//  DsListViewController.m
//  duosuccess
//
//  Created by Rick Li on 12/24/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsListViewController.h"
#import "DsArticleViewController.h"
#import "DsPaperController.h"
#import "DsWebViewController.h"
#import "DsTableCell.h"
#import "DsDataStore.h"
#import "DsFileStore.h"
#import "DsMainListImpl.h"

#import "DsConst.h"

#ifdef USES_IASK_STATIC_LIBRARY
#import "InAppSettingsKit/IASKSettingsReader.h"
#else
#import "IASKSettingsReader.h"
#endif

@implementation DsListViewController

@synthesize listDelegate;

@synthesize tableArticles;
@synthesize introArticles;

@synthesize pageContainer;
@synthesize tableView;
@synthesize introCtrl;
@synthesize introContainer;
@synthesize tableCtrl;
@synthesize refreshCtrl;
@synthesize articleCtrl;
@synthesize appSettingsViewController;


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

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.listDelegate = [[DsMainListImpl alloc]init];
    
    if(self.tableCtrl == nil){
        self.tableCtrl = [[UITableViewController alloc] init];
        self.refreshCtrl = [[UIRefreshControl alloc] init];
        [self.refreshCtrl addTarget:self action:@selector(refreshTable) forControlEvents: UIControlEventValueChanged];
        
        self.tableCtrl.refreshControl = self.refreshCtrl;
        self.tableCtrl.tableView = self.tableView;
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ARTICLE_UPDATED object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self loadArticles];
    }];
    
    [self loadArticles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:false];
    
    self.title = [listDelegate getTitle];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadArticles{
    [self.listDelegate loadArticle:self];
}


-(void) createIntroContrainer:(NSArray*) lintroArticles{
    introArticles = lintroArticles;
    
    if(self.introCtrl != nil){
        [self.introCtrl removeFromSuperview];
    }
    
    if([introArticles count] <= 0){
        return;
    }
    
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    for(NSManagedObject *obj in introArticles){
        IntroModel *model = [[IntroModel alloc] initWithTitle:[obj valueForKey:@"title"] description:[obj valueForKey:@"intro"] imageUrl:[obj valueForKey:@"imageUrl"]];
        [pages addObject:model];
    }
    
    
    self.introCtrl = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 190.0f) pages:pages];
    [self.introContainer addSubview:self.introCtrl];
}

- (IBAction) showMenu{
    [self.sideMenuViewController presentMenuViewController];
}

-(IBAction)musicAction{
    if([[DsDataStore sharedInstance] isCensorMode]){
        [self startWebBrowser:@"https://www.duosuccess.com/tcm/001a01080301b01aj.htm"];
    }else{
        UIViewController *musicCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"musicController"];
        [self.navigationController pushViewController:musicCtrl animated:true];

    }
}

-(IBAction)browserAction{
    DsWebViewController *webViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewCtrl.displayWebViewByDefault = true;
    [webViewCtrl.webView loadURLString:@"https://www.duosuccess.com"];
    [self.navigationController pushViewController:webViewCtrl animated:true];
    
}

-(IBAction)paperAction{
    
    NSString *cancelStr = NSLocalizedString(@"cancel", @"Cancel");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelStr
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil, nil];
    if([[DsFileStore sharedInstance] isPaperImageExists]){
        [actionSheet addButtonWithTitle: NSLocalizedString(@"checkMyPaper", @"Check my paper")];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"downloadPaper", @"Download new paper")];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet setTag:1];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    
}

-(void)startWebBrowser:(NSString *)pUrl{
    NSString *url = @"https://www.duosuccess.com";
    if(pUrl){
        url = pUrl;
    }
    DsWebViewController *webViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewCtrl.displayWebViewByDefault = true;
    [webViewCtrl.webView loadURLString:url];
    [self.navigationController pushViewController:webViewCtrl animated:true];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([actionSheet tag] == 1){
        
        //music
        if (buttonIndex == 1) {
            NSLog(@"number of action buttons is %d.", actionSheet.numberOfButtons);
            if(actionSheet.numberOfButtons==3){
                DsPaperController *pCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"paperController"];
                
                [self.navigationController pushViewController:pCtrl animated:true];
            }else{
                [self startWebBrowser:nil];
            }
            
        }
        else if (buttonIndex == 2) {
            [self startWebBrowser:nil];
        }
    }
}


-(IBAction)configAction{
    if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
		appSettingsViewController.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
	}
    [self.navigationController pushViewController:appSettingsViewController animated:true];
}


- (IBAction)onTapIntro:(id)sender{
    NSLog(@"tapping intro container.");
    NSManagedObject *article = [introArticles objectAtIndex: self.introCtrl.currentPhotoNum];
    [self openArticle:article];
}

#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    NSLog(@"Notification changed: %@", notification.userInfo);
    //TODO respond to notification changes.
}



- (void)refreshTable{
    NSLog(@"refreshing");
    
    [[DsDataStore sharedInstance] syncData];
    [self.refreshCtrl endRefreshing];
}


-(void) openArticle:(NSManagedObject*) article{
    articleCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"articleController"];
    
    NSString *title =[article valueForKey:@"title"];
    NSString *content =[article valueForKey:@"content"];
    NSString *imageUrl = [article valueForKey:@"imageUrl"];
    NSDate *date = [article valueForKey:@"updatedAt"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle= kCFDateFormatterMediumStyle;
    formatter.timeStyle = kCFDateFormatterMediumStyle;
    
    
    
    articleCtrl.titleTxt = title;
    articleCtrl.dateTxt = [formatter stringFromDate:date];
    articleCtrl.content = content;
    articleCtrl.imageUrl = imageUrl;
    
    
    [self.navigationController pushViewController:self.articleCtrl animated:true];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSManagedObject *article = [tableArticles objectAtIndex:indexPath.row];
    [self openArticle:article];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    
    return self.tableArticles.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DsTableCell";
    
    DsTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DsTableCell" owner:self options:nil];//加载自定义cell的xib文件
        cell = [array objectAtIndex:0];
        
        
    }
    NSManagedObject *article = [self.tableArticles objectAtIndex:indexPath.row];
    cell.title.text = [article valueForKey:@"title"];
    cell.intro.text = [article valueForKey:@"intro"];
    cell.intro.numberOfLines = 0;
    
    //make table transparent withoiut impacting the text and images
    cell.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0.0];
    return cell;
}

@end
