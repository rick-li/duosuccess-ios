//
//  DsDataStore.h
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DsNonMgLang.h"

@interface DsDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;

-(void) syncData;

-(NSArray*) queryLang;
-(NSArray*) queryCategories;
-(NSArray*) queryArticlesByCategory: (NSString*)categoryId;
-(NSDictionary*) defaultLang;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
