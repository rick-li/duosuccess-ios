//
//  DsFileStore.m
//  duosuccess
//
//  Created by Rick Li on 12/31/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsFileStore.h"
#import "DsEventStore.h"

@implementation DsFileStore

@synthesize imageFileUrl;

NSString *tmpDir;


+ (id)sharedInstance {
    static DsFileStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]){
        NSLog(@"File not exist %@ , skip.", [URL path]);
        return false;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

-(id)init{
    self = [super init];
    tmpDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"/File"];
    
    [self addSkipBackupAttributeToItemAtURL: [NSURL fileURLWithPath:tmpDir]];
    imageFileUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"/paperScreenshot.png"];
    [self addSkipBackupAttributeToItemAtURL: [NSURL fileURLWithPath:imageFileUrl]];
    return self;
}

-(void) createMusicDir{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
//    NSLog(@"Temp dir is created");
}

-(void) clearMusicCache{
    NSError *error = nil;
//    NSLog(@"temp dir is %@", tmpDir);
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:tmpDir];
    
    
    if(folderExists){
        NSURL *url = [NSURL fileURLWithPath:tmpDir];
//        NSLog(@"URL: %@", url);
        BOOL isRemoved = [[NSFileManager defaultManager] removeItemAtURL:url error: &error];
        
        NSLog (@"Temp Dir removed: %@", isRemoved ? @"YES" : @"NO");
    }
    
    [self createMusicDir];
}

-(NSString*) tmpDir{
    return tmpDir;
}

-(bool) isPaperImageExists{
//    NSURL *filePath = [NSURL fileURLWithPath:imageFileUrl];
    
    return [[NSFileManager defaultManager] isReadableFileAtPath:imageFileUrl];
}

-(void) savePaperImage: (NSData*) imageData{
    
    [imageData writeToFile:imageFileUrl atomically:YES];
    
    NSLog(@"the image has been saved");
}

-(void) removePaperImage{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath: imageFileUrl] error:&error];
    if(error){
        NSLog(@"Failed to remove %@.", error.description);
    }else{
    
        NSLog(@"the image has been removed.");
    }
}

@end
