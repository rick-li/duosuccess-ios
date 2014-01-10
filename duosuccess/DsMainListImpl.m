//
//  DsMainListImpl.m
//  duosuccess
//
//  Created by Rick Li on 12/24/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsMainListImpl.h"
#import "DsConst.h"
#import "DsDataStore.h"

@interface DsMainListImpl()

@end


@implementation DsMainListImpl


NSString *title;

-(void) init: (DsListViewController*) lctrl{
    self.ctrl = lctrl;
    
    title = NSLocalizedString(@"mainTitle", @"Main Page by default");
    self.inited = true;
    
    
}

-(void) setCategory: (NSDictionary*) lcategory{
    self.category = lcategory;
}

-(NSString*) getTitle{
    return title;
}

-(void) loadArticle: (DsListViewController*) lctrl{
    DsDataStore *store = [DsDataStore sharedInstance];
    if(!self.inited){
        self.ctrl = lctrl;
        [self init:lctrl];
    }
    
    NSArray *categories = [store queryCategories];
    
    if([categories count] <1 ){
        NSLog(@"No categoriy, nothing to render.");
        return;
    }
    
    
    NSDictionary *firstCategory = [categories objectAtIndex:0];
    
    NSArray *introData = [store queryArticlesByCategory:[firstCategory valueForKey:@"objectId"] :true :0 :5];
    
    NSLog(@"intro data count %ul.", [introData count]);
    //header for first category
    //main page is displaying first category
    [self.ctrl createIntroContrainer: introData];
    
    NSArray *articles = [store queryArticlesByCategory: [firstCategory valueForKey:@"objectId"] :false :0 : 50];
    self.ctrl.tableArticles = articles;
    
    [self.ctrl.tableView reloadData];
    
    lctrl.title = title;
    
}

@end
