//
//  DsArticle.h
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DsArticle : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * langId;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * updatedAt;

@end
