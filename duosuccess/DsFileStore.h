//
//  DsFileStore.h
//  duosuccess
//
//  Created by Rick Li on 12/31/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DsFileStore : NSObject

@property NSString *imageFileUrl;

+ (id)sharedInstance;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

-(NSString*) tmpDir;

-(void) createMusicDir;

-(void) clearMusicCache;

-(bool) isPaperImageExists;

-(void) savePaperImage: (NSData*) imageData;

-(void) removePaperImage;

@end
