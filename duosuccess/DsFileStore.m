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


-(id)init{
    self = [super init];
    tmpDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"/File"];
    
    imageFileUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"/paperScreenshot.png"];
    return self;
}

-(void) createMusicDir{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSLog(@"Temp dir is created");
}

-(void) clearMusicCache{
    NSError *error = nil;
    NSLog(@"temp dir is %@", tmpDir);
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:tmpDir];
    
    
    if(folderExists){
        NSURL *url = [NSURL fileURLWithPath:tmpDir];
        NSLog(@"URL: %@", url);
        BOOL isRemoved = [[NSFileManager defaultManager] removeItemAtURL:url error: &error];
        
        NSLog (@"Temp Dir removed: %@", isRemoved ? @"YES" : @"NO");
    }
    
    [self createMusicDir];
}

-(NSString*) tmpDir{
    return tmpDir;
}

-(bool) isPaperImageExists{
    return [[NSFileManager defaultManager] isReadableFileAtPath:[NSURL fileURLWithPath:imageFileUrl]];
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
