//
//
//  duosuccess
//
//  Created by Rick Li on 12/24/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsCategoryListImpl.h"
#import "DsListViewController.h"
#import "DsDataStore.h"
#import "DsConst.h"

@implementation DsCategoryListImpl

@synthesize ctrl;

NSString *title;

-(void) init: (DsListViewController*) lctrl{
    self.ctrl = lctrl;
    
    self.inited = true;
    
}
-(NSString*) getTitle{
    return title;
}

-(void) loadArticle: (DsListViewController*) lctrl{
    if(!self.inited){
        [self init:lctrl];
    }
    self.ctrl = lctrl;
    
    NSArray *stickyArticles = [[DsDataStore sharedInstance] queryArticlesByCategory:[self.category valueForKey:@"objectId"] :true :0 :5];
    
    NSArray *articles = [[DsDataStore sharedInstance] queryArticlesByCategory:[self.category valueForKey:@"objectId"] :false :0 :50];
    
    
    NSArray *introData = stickyArticles;
    [self.ctrl createIntroContrainer: introData];
    
    self.ctrl.tableArticles = articles;
    
    [self.ctrl.tableView reloadData];
    title = [self.category valueForKey:@"name"];
    ctrl.title = title;
}

@end
