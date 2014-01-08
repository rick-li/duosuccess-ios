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
@property(nonatomic, retain) IBOutlet  UILabel *titleView;
@property(nonatomic, retain) IBOutlet  UILabel *dateView;

@property(nonatomic, retain) IBOutlet  UIButton *moreBtn;

- (IBAction)onClickViewMore:(id)sender;


@property NSString *imageUrl;
@property NSString *content;
@property NSString *titleTxt;
@property NSString *dateTxt;
@property NSString *viewMoreLink;
@end
