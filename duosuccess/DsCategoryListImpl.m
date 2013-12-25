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

-(void) init: (DsListViewController*) lctrl{
    self.ctrl = lctrl;
    [[NSNotificationCenter defaultCenter] addObserverForName:ARTICLE_UPDATED object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self loadArticle: lctrl];
    }];
    self.inited = true;
    
}


-(void) loadArticle: (DsListViewController*) lctrl{
    if(!self.inited){
        [self init:lctrl];
    }
    self.ctrl = lctrl;
    self.ctrl.tableArticles = [[DsDataStore sharedInstance] queryArticlesByCategory:[self.category valueForKey:@"objectId"]];
    [self.ctrl.tableView reloadData];
    self.ctrl.title = [self.category valueForKey:@"name"];
}
@end
