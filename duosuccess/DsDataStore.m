//
//  DsDataStore.m
//  duosuccess
//
//  Created by Rick Li on 12/10/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsDataStore.h"
#import <Parse/Parse.h>
#import "DsConst.h"

@implementation DsDataStore

+ (id)sharedInstance {
    static DsDataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(void) syncData{
    [Parse setApplicationId:@"wGmHHvHhpgMf2PSyEVIrlYDDV7Gn04bq1ZEuG5Qd"
                  clientKey:@"HcYbXZvqDS91NIazuvd2vKqoqTbLRsTu1N2DZsAf"];
    //sync lang, category, article
    [self syncData:@"DsLang" withPfType:@"Lang"];
    
    [self syncData:@"DsCategory" withPfType:@"Category"];

    
    [self syncData:@"DsArticle" withPfType:@"Article"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"articleUpdated" object:nil];
}


-(void)setLangAttrs:(NSManagedObject *)mObj fromPfObj: (PFObject *) pfObj{
    NSString *objectIdVal = pfObj.objectId;
    [mObj setValue:objectIdVal forKey:@"objectId"];
    
    NSString *nameVal = pfObj[@"name"];
    [mObj setValue:nameVal forKey:@"name"];
    
    NSString *codeVal = pfObj[@"code"];
    [mObj setValue:codeVal forKey:@"code"];
    
    NSNumber *orderVal = pfObj[@"order"];
    [mObj setValue:orderVal forKey:@"order"];
    
    NSDate *updatedAtVal = pfObj.updatedAt;
    [mObj setValue:updatedAtVal forKey:@"updatedAt"];
}


-(void)setCategoryAttrs:(NSManagedObject *)mObj fromPfObj: (PFObject *) pfObj{
    NSString *objectIdVal = pfObj.objectId;
    [mObj setValue:objectIdVal forKey:@"objectId"];
    
    NSString *nameVal = pfObj[@"name"];
    [mObj setValue:nameVal forKey:@"name"];
    
    NSNumber *orderVal = pfObj[@"order"];
    [mObj setValue:orderVal forKey:@"order"];
    
    NSDate *updatedAtVal = pfObj.updatedAt;
    [mObj setValue:updatedAtVal forKey:@"updatedAt"];
    
    NSString *langId = ((PFObject *)pfObj[@"lang"]).objectId;
    [mObj setValue:langId forKey:@"langId"];
}

-(void)setArticleAttrs:(NSManagedObject *)mObj fromPfObj: (PFObject *) pfObj{
    NSString *objectIdVal = pfObj.objectId;
    [mObj setValue:objectIdVal forKey:@"objectId"];
    
    NSString *nameVal = pfObj[@"title"];
    [mObj setValue:nameVal forKey:@"title"];
    
    NSString *introVal = pfObj[@"intro"];
    [mObj setValue:introVal forKey:@"intro"];
    
    NSString *contentVal = pfObj[@"content"];
    [mObj setValue:contentVal forKey:@"content"];
    
    NSNumber *orderVal = pfObj[@"order"];
    [mObj setValue:orderVal forKey:@"order"];
    
    NSDate *updatedAtVal = pfObj.updatedAt;
    [mObj setValue:updatedAtVal forKey:@"updatedAt"];
    
    NSString *langId = ((PFObject *)pfObj[@"lang"]).objectId;
    [mObj setValue:langId forKey:@"langId"];
    
    NSString *categoryId = ((PFObject *)pfObj[@"category"]).objectId;
    [mObj setValue:categoryId forKey:@"categoryId"];
    
    PFObject *image = (PFObject *)pfObj[@"image"];
    [image fetchIfNeeded];
    if(image != nil){
        PFFile *imageFile = image[@"image"];
        
        NSString *imageUrl = imageFile.url;
        [mObj setValue:imageUrl forKey:@"imageUrl"];
    }
    
    
}

-(NSManagedObject *) getObjectByObjectId: (NSString *)objectId withType: (NSString *)dbType{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:dbType inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    NSPredicate *objIdPredicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    [request setPredicate:objIdPredicate];
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    if(objects != nil && objects.count > 0){
        NSManagedObject *obj = [objects objectAtIndex:0];
        return obj;
    }
    return nil;
}

-(void) syncData: (NSString *)dbType withPfType: (NSString *)pfType{
    NSDate *lastSavePoint = [self getLastSaveDate:dbType];
    NSLog(@"last save point is %@.", lastSavePoint);
    
    PFQuery *query = [PFQuery queryWithClassName:pfType];
    [query whereKey:@"updatedAt" greaterThan:lastSavePoint];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error != nil){
            NSLog(@"retrieve error %@.", error);
            return;
        }
        
        for(PFObject *pfObj in objects){

            if([pfObj[@"status"] isEqualToString:@"deleted" ]){
                NSManagedObject *mObj = [self getObjectByObjectId:pfObj.objectId withType: dbType];
                if(mObj != nil){
                    [self.managedObjectContext deleteObject:mObj];
                }
            }else{
                //existing object by objectId
                NSManagedObject *mObj = [self getObjectByObjectId: pfObj.objectId withType: dbType];
                
                if(mObj == nil){
                    mObj = [NSEntityDescription insertNewObjectForEntityForName:dbType inManagedObjectContext:[self managedObjectContext]];
                }
                
                if([dbType isEqualToString:@"DsLang"]){
                    [self setLangAttrs:mObj fromPfObj:pfObj];
                }
                
                if([dbType isEqualToString:@"DsCategory"]){
                    [self setCategoryAttrs:mObj fromPfObj:pfObj];
                }
                
                if([dbType isEqualToString:@"DsArticle"]){
                    [self setArticleAttrs:mObj fromPfObj:pfObj];
                }
            }
            
            
        }
        NSError *saveError = nil;
        [self.managedObjectContext save: &saveError];
        
        if([@"Lang" isEqualToString:pfType]){
            [[NSNotificationCenter defaultCenter] postNotificationName:LANG_UPDATED object:nil];
        }
        
        if([@"Category" isEqualToString:pfType]){
            [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_UPDATED object:nil];
        }
        
        if([@"Article" isEqualToString:pfType]){
            [[NSNotificationCenter defaultCenter] postNotificationName:ARTICLE_UPDATED object:nil];
        }

    }];
    
}

-(NSDate*)getLastSaveDate: (NSString*)entityName{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    request.entity = entity;
    
    [request setResultType:NSDictionaryResultType];
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"maxDate"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (objects == nil || error != nil) {
        // Handle the error.
        NSLog(@"Error encountered for requests. %@", error);
        
    }
    else {
        if ([objects count] > 0) {
            NSDate *maxDate = [[objects objectAtIndex:0] valueForKey:@"maxDate"];
            NSLog(@"Max date: %@", maxDate);
            if(maxDate == nil){
                return [NSDate dateWithTimeIntervalSince1970:0];
            }
            return maxDate;
        }
    }
    
    return [NSDate dateWithTimeIntervalSince1970:0];;
}


//should be type of DsLang
-(NSDictionary*) defaultLang{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultLang = [defaults objectForKey:@"defaultLang"];
    
    if(defaultLang == nil || [defaultLang count] ==0){
        
        NSString *defaultLangCode = @"zh-tw";
        NSArray *langs = [self queryLang];
        for(NSManagedObject *langObj in langs){
            if([defaultLangCode isEqualToString: [langObj valueForKey:@"code"]]){
                defaultLang = [[NSMutableDictionary alloc] init];
                
                [defaults setObject:defaultLang forKey:@"defaultLang"];
                NSLog(@"set default lang to %@.", [defaultLang valueForKey:@"code"]);
            }
        }
        
    }
    
    if(defaultLang == nil || [defaultLang count] ==0){
        defaultLang = [[NSMutableDictionary alloc] init];
        
        [defaultLang setValue:@"繁體中文" forKey:@"name"];
        [defaultLang setValue:@"zh-tw" forKey:@"code"];
        [defaultLang setValue:@"We4fg0SA2e" forKey:@"objectId"];
        
        [defaults setObject:defaultLang forKey:@"defaultLang"];
        NSLog(@"set default lang to %@.", [defaultLang valueForKey:@"code"]);
    }
    return defaultLang;
}

-(NSArray*) queryLang{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DsLang" inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    return objects;
}

-(NSArray*) queryCategories{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DsCategory" inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    NSString *lang = [[self defaultLang] valueForKey:@"objectId"];
    NSPredicate *objIdPredicate = [NSPredicate predicateWithFormat:@"langId = %@", lang];
    [request setPredicate:objIdPredicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:true];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];

    NSMutableArray *results = [[NSMutableArray alloc]init];
    for(NSManagedObject *obj in objects){
        NSString *objectId = [obj valueForKey:@"objectId"];
        NSString *name = [obj valueForKey:@"name"];
        NSDictionary *category = [NSDictionary dictionaryWithObjects:@[objectId, name] forKeys:@[@"objectId", @"name"]];
        
        [results addObject:category];
    }
    return results;
}

-(NSArray*) queryArticlesByCategory: (NSString*)categoryId{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DsArticle" inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    NSString *lang = [[self defaultLang] valueForKey:@"objectId"];
    NSPredicate *objIdPredicate = [NSPredicate predicateWithFormat:@"langId = %@ AND categoryId = %@" , lang, categoryId];
    [request setPredicate:objIdPredicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:true];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    return objects;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"duosuccess" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"duosuccess.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
