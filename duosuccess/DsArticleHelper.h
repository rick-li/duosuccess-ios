//
//  DsArticleHelper.h
//  duosuccess
//
//  Created by Rick Li on 1/9/14.
//  Copyright (c) 2014 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DsArticleHelper : NSObject

+ (id)sharedInstance;

-(void) openArticle: (NSDictionary*) article  withNavCtrl: (UINavigationController*) navCtrl;

@end
