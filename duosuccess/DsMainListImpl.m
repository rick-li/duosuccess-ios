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
@property NSDictionary *selectedCategory;
@end


@implementation DsMainListImpl

@synthesize selectedCategory;

-(void) init: (DsListViewController*) lctrl{
    self.ctrl = lctrl;
    
    if(self.selectedCategory == nil){
        self.selectedCategory = [NSDictionary dictionaryWithObjects:@[@"hb9xA3ZwjR"] forKeys:@[@"objectId"]];
    }
    
    lctrl.title = @"main page";
    self.inited = true;
    

}

-(void) setCategory: (NSDictionary*) lcategory{
    self.category = lcategory;
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
    
    NSArray *introData = [store queryArticlesByCategory:[firstCategory valueForKey:@"objectId"]];
    NSLog(@"intro data count %ul.", [introData count]);
    //header for first category
    [self.ctrl createIntroContrainer: introData];
    
    //table for rest of the categories
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    for(int i =1;i<[categories count]; i++){
        NSDictionary *category = [categories objectAtIndex:i];
        NSString *cateId = [category valueForKey:@"objectId"];
        NSArray *partialArticles = [store queryArticlesByCategory:cateId];
        [articles addObjectsFromArray: partialArticles];
    }
    self.ctrl.tableArticles = articles;

    [self.ctrl.tableView reloadData];
    
}

@end
