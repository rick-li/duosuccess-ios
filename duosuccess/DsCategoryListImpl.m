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

    self.inited = true;
    
}


-(void) loadArticle: (DsListViewController*) lctrl{
    if(!self.inited){
        [self init:lctrl];
    }
    self.ctrl = lctrl;
    
    NSArray *articles = [[DsDataStore sharedInstance] queryArticlesByCategory:[self.category valueForKey:@"objectId"]];
    
    int introCount = [articles count] >=2 ?2: [articles count];
    NSArray *introData = [articles subarrayWithRange:NSMakeRange(0, introCount)];
    [self.ctrl createIntroContrainer: introData];
    
    if([articles count] >2){
        NSArray *tableData = [articles subarrayWithRange:NSMakeRange(2,[articles count]-2)];
        self.ctrl.tableArticles = tableData;
        
    }else{
        self.ctrl.tableArticles = @[];
    }
    [self.ctrl.tableView reloadData];
    self.ctrl.title = [self.category valueForKey:@"name"];
}

@end
