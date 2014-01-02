//
//  DsArticleViewController.h
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DsArticleViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic, retain) IBOutlet  UIImageView *imageView;
@property(nonatomic, retain) IBOutlet  UIWebView *contentView;
@property(nonatomic, retain) IBOutlet  UIScrollView *containerView;

@property NSString *imageUrl;
@property NSString *content;

@end
