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
    [[NSNotificationCenter defaultCenter] addObserverForName:ARTICLE_UPDATED object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self loadArticle:lctrl];
    }];
    
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
    if(!self.inited){
        self.ctrl = lctrl;
        [self init:lctrl];
    }
    
    NSArray *categories = [[DsDataStore sharedInstance] queryCategories];
    
    if([categories count] <1 ){
        NSLog(@"No categoriy, nothing to render.");
        return;
    }
    

    NSDictionary *category = [categories objectAtIndex:0];
    
    NSArray *introData = [[DsDataStore sharedInstance] queryArticlesByCategory:[category valueForKey:@"objectId"]];
    
    //header
    [self createIntroContrainer: introData];
    
    //table
    self.ctrl.tableArticles = [[DsDataStore sharedInstance] queryArticlesByCategory: [selectedCategory valueForKey:@"objectId" ]];
    
    
    [self.ctrl.tableView reloadData];
    
}

-(void) createIntroContrainer:(NSArray*) introData{
    
    if(self.ctrl.introCtrl != nil){
        [self.ctrl.introCtrl removeFromSuperview];
    }
    
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"Example 1" description:@"Hi, my name is Dmitry" image:@"phone"];
    
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"Example 2" description:@"Several sample texts in Old, Middle, Early Modern, and Modern English are provided here " image:@"tea"];
    
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"Example 3" description:@"The Tempest is the first play in the First Folio edition (see the signature) even though it." image:@"cloth"];
    
    self.ctrl.introCtrl = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.ctrl.view.frame.size.width, 190.0f) pages:@[model1, model2, model3]];
    [self.ctrl.introContainer addSubview:self.ctrl.introCtrl];
}

@end
