//
//  DsMainListImpl.h
//  duosuccess
//
//  Created by Rick Li on 12/24/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DsListViewController.h"

@interface DsMainListImpl : NSObject<DsListDelegate>

@property (nonatomic, retain) DsListViewController *ctrl;

@property Boolean inited;

@end
