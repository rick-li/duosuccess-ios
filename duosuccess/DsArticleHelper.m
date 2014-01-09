//
//  DsArticleHelper.m
//  duosuccess
//
//  Created by Rick Li on 1/9/14.
//  Copyright (c) 2014 Rick Li. All rights reserved.
//

#import "DsArticleHelper.h"
#import "DsArticleViewController.h"

@implementation DsArticleHelper

+ (id)sharedInstance {
    static DsArticleHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) openArticle: (NSDictionary*) article  withNavCtrl: (UINavigationController*) navCtrl{
    DsArticleViewController *articleCtrl = [navCtrl.storyboard instantiateViewControllerWithIdentifier:@"articleController"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle= kCFDateFormatterMediumStyle;
    formatter.timeStyle = kCFDateFormatterMediumStyle;
    
    NSString *title =[article valueForKey:@"title"];
    NSString *content =[article valueForKey:@"content"];
    NSString *imageUrl = [article valueForKey:@"imageUrl"];
    NSString *url = [article valueForKey:@"url"];
    NSDate *date = [article valueForKey:@"updatedAt"];
    
    articleCtrl.titleTxt = title;
    articleCtrl.dateTxt = [formatter stringFromDate:date];
    articleCtrl.content = content;
    articleCtrl.imageUrl = imageUrl;
    articleCtrl.viewMoreLink = url;
    
    [navCtrl pushViewController:articleCtrl animated:true];

}


@end
