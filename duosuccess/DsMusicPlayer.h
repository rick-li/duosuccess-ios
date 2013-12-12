//
//  DsMusicPlayer.h
//  duosuccess
//
//  Created by Rick Li on 12/12/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/MusicPlayer.h>
#import <UIKit/UIKit.h>
@class DsMusicPlayer;

@protocol DsMusicPlayerDelegate <NSObject>

@optional
- (void)musicStart: (DsMusicPlayer *)sender;
- (void)tick: (long)elapsed remains:(long)remains;
- (void)musicStop: (DsMusicPlayer *)sender;

@end

@interface DsMusicPlayer : NSObject

+ (id)sharedInstance;

@property MusicSequence mySequence;
@property MusicPlayer player;
@property id <DsMusicPlayerDelegate> delegate;

- (void) playMedia:(NSString *)midPath;

-(void) stopMedia;

@end
