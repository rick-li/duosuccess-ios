//
//  DsLangProtocol.h
//  duosuccess
//
//  Created by Rick Li on 12/22/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DsLangProtocol <NSObject>


@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSNumber *order;


@end
