//
//  DsMusicPlayer.m
//  duosuccess
//
//  Created by Rick Li on 12/12/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "DsMusicPlayer.h"

@interface DsMusicPlayer ()

@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;
@property long elapsed;
@property long remains;

@end

@implementation DsMusicPlayer

@synthesize mySequence;
@synthesize player;
@synthesize processingGraph     = _processingGraph;
@synthesize samplerUnit         = _samplerUnit;
@synthesize ioUnit              = _ioUnit;
@synthesize delegate;
@synthesize elapsed;
@synthesize remains;

@synthesize isPlaying;

+ (id)sharedInstance {
    static DsMusicPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
        [sharedInstance initialize];
    });
    
    [sharedInstance setupAudioSession];
    [sharedInstance createAUGraph];
    [sharedInstance postInitGragh];
    
    return sharedInstance;
}

int oneHour;

NSTimer *oneHourTimer;
NSTimer *loopTimer;
NSString *midiPath;

- (void) initialize{
    oneHour = 60 * 60;
//    oneHour = 5;
    
    isPlaying = false;
}

- (void) playMedia:(NSString *)midPath isLoop:(BOOL)isLoop{
    isPlaying = true;
    if(!isLoop){
        elapsed = 0;
        remains = oneHour;
        midiPath = midPath;
    }
    [self stopMedia];
    NewMusicSequence(&mySequence);
    NSURL * midiFileURL = [NSURL fileURLWithPath:midPath];
    MusicSequenceFileLoad(mySequence, (__bridge CFURLRef)midiFileURL, 0, kMusicSequenceLoadSMF_ChannelsToTracks);
    
    MusicSequenceSetAUGraph(mySequence, _processingGraph);
    
    [self setLoop:mySequence];
    
    [self doStartMidi];
    
    if(!isLoop){
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        
        if (playingInfoCenter) {
            
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: [UIImage imageNamed:@"duoAlbumArt"]];
            
            [songInfo setObject:NSLocalizedString(@"musicTitle", "") forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:NSLocalizedString(@"drLong", "") forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:NSLocalizedString(@"album", "") forKey:MPMediaItemPropertyAlbumTitle];
            [songInfo setObject:[NSNumber numberWithLong:oneHour] forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:[NSNumber numberWithInt:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
            //https://www.duosuccess.com/tcm/001new01j.htm
            //1:06:32
            [songInfo setObject:[NSNumber numberWithInt:oneHour] forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            
        }

    }
    
    
}

// Set up the audio session for this app.
- (BOOL) setupAudioSession
{
    NSLog(@"--- setupAudioSession ---");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    [audioSession setDelegate: self];
//    [[NSNotificationCenter defaultCenter] addObserver: self
//                                             selector:  @selector(handleInterruption:)
//                                                 name:       AVAudioSessionInterruptionNotification
//                                               object:      audioSession];
//    
    //Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
    [audioSession setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting audio session category."); return NO;}
    
    
    // Activate the audio session
    [audioSession setActive: YES error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error activating the audio session."); return NO;}
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    NSLog(@"audioSessionActivated");
    return YES;
}
UIAlertView *alert;
//bool interruptBegin = false;
//-(void) handleInterruption:(NSNotification*)notification{
//    NSLog(@"Interruption detected: %d", interruptBegin);
//    NSDictionary *interuptionDict = notification.userInfo;
//    NSUInteger interuptionType = (NSUInteger)[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
//
//    NSLog(@"Interruption detected, type is %d.", interuptionType);
//    if(!interruptBegin){
//        [self stopMedia];
//        [self.delegate musicStop:self];
//        interruptBegin = !interruptBegin;
//
//    }
//    else {
//        interruptBegin = !interruptBegin;
//        if(![alert isVisible]){
//            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"interrupted","") message: NSLocalizedString(@"plsStartAgain", "") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    }
    
//}

-(void) handleOneHourTimer{
    self.elapsed++;
    self.remains--;
    if(self.remains<0){
        self.remains = 0;
    }
    if(self.elapsed >= oneHour){
        NSLog(@"1 hour arrived, calling music stop.");
        [self stopMedia];
        [loopTimer invalidate];
        [self.delegate musicStop:self];
    }else{
        [self.delegate tick:elapsed remains:remains];
    }
    
}

-(void) handleLoopTimer{
    NSLog(@"Handling loop timer.");
    [self playMedia:midiPath isLoop:true];
    
}

-(void) invalidateLoopTimer{
    if(loopTimer){
        NSLog(@"invalidate loop timer.");
        [loopTimer invalidate];
    }
}
-(void) invalidateTimer{
    NSLog(@"invalidate timer.");
    if(oneHourTimer){
        [oneHourTimer invalidate];
    }
    if(loopTimer){
        [loopTimer invalidate];
    }
}

- (void)doStartMidi{
    NSLog(@"do start midi");
    
    NewMusicPlayer(&player);
    MusicPlayerSetSequence(player, mySequence);
    MusicPlayerPreroll(player);
    MusicPlayerStart(player);
    
    [self invalidateTimer];
    oneHourTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(handleOneHourTimer)
                                                  userInfo:nil
                                                   repeats:YES];
    int trackLen = [self getTrackLen:mySequence];
    NSLog(@"Track len is %d ", trackLen);
    if(trackLen < oneHour ){
        loopTimer = [NSTimer scheduledTimerWithTimeInterval:363.5
                                                     target:self
                                                   selector:@selector(handleLoopTimer)
                                                   userInfo:nil
                                                    repeats:NO];
    }
    
}

- (int)getTrackLen:(MusicSequence)sequence{
    UInt32 tracks;
    if (MusicSequenceGetTrackCount(sequence, &tracks) != noErr)
        NSLog(@"track size is %d", (int)tracks);
    int resultTrackLen = 0;
    for (UInt32 i = 0; i < tracks; i++) {
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        MusicSequenceGetIndTrack(sequence, i, &track);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        if(trackLen > resultTrackLen){
            resultTrackLen = trackLen;
        }
    }
    return resultTrackLen;
}

- (void)setLoop:(MusicSequence)sequence {
    UInt32 tracks;
    
    if (MusicSequenceGetTrackCount(sequence, &tracks) != noErr)
        NSLog(@"track size is %d", (int)tracks);
    
    for (UInt32 i = 0; i < tracks; i++) {
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        MusicSequenceGetIndTrack(sequence, i, &track);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
//        if(trackLen >= oneHour){
            MusicTrackLoopInfo loopInfo = { trackLen, 1 };
            MusicTrackSetProperty(track, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
            
//        }else{
//            MusicTrackLoopInfo loopInfo = { trackLen, 10 };
//            MusicTrackSetProperty(track, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
        
//        }
        
        NSLog(@"track length is %f", trackLen);
    }
}

- (void) stopTracks{
        Boolean isPlayerPlaying = FALSE;
    MusicPlayerIsPlaying(player, &isPlayerPlaying);
    if(!isPlayerPlaying){
        NSLog(@"not playing music, no need to stop.");
        return;
    }
    
    OSStatus result = noErr;
    
    result = MusicPlayerStop(player);
    
    UInt32 trackCount;
    MusicSequenceGetTrackCount(mySequence, &trackCount);
    
    MusicTrack track;
    for(int i=0;i<trackCount;i++)
    {
        MusicSequenceGetIndTrack (mySequence,0,&track);
        result = MusicSequenceDisposeTrack(mySequence, track);
        
    }
    
    result = DisposeMusicPlayer(player);
    result = DisposeMusicSequence(mySequence);
}

- (void) stopMedia{
    NSLog(@"Stopping music");
    isPlaying = false;
    if(player == nil ){
        return;
    }
    [self stopTracks];
    [self invalidateTimer];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    
}



-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withPatch: (int)presetNumber {
    
    OSStatus result = noErr;
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;
    
    
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(self.samplerUnit,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    
    
    
    // check for errors
    NSCAssert (result == noErr,
               @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
               (int) result,
               (const char *)&result);
    
    return result;
}


- (BOOL) createAUGraph {
    
    // Each core audio call returns an OSStatus. This means that we
    // Can see if there have been any errors in the setup
	OSStatus result = noErr;
    
    // Create 2 audio units one sampler and one IO
	AUNode samplerNode, ioNode;
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
    // Setup the manufacturer - in this case Apple
	AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    
    // Instantiate an audio processing graph
	result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	//Specify the Sampler unit, to be used as the first node of the graph
	cd.componentType = kAudioUnitType_MusicDevice; // type - music device
	cd.componentSubType = kAudioUnitSubType_Sampler; // sub type - sampler to convert our MIDI
	
    // Add the Sampler unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Specify the Output unit, to be used as the second and final node of the graph
	cd.componentType = kAudioUnitType_Output;  // Output
	cd.componentSubType = kAudioUnitSubType_RemoteIO;  // Output to speakers
    
    // Add the Output unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Open the graph
	result = AUGraphOpen (self.processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Connect the Sampler unit to the output unit
	result = AUGraphConnectNodeInput (self.processingGraph, samplerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the Sampler unit from its node
	result = AUGraphNodeInfo (self.processingGraph, samplerNode, 0, &_samplerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the I/O unit from its node
	result = AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    //see http://developer.apple.com/library/ios/#documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Cookbook/Cookbook.html
    UInt32 maximumFramesPerSlice = 4096;
    
    AudioUnitSetProperty (
                          self.samplerUnit,
                          kAudioUnitProperty_MaximumFramesPerSlice,
                          kAudioUnitScope_Global,
                          0,                        // global scope always uses element 0
                          &maximumFramesPerSlice,
                          sizeof (maximumFramesPerSlice)
                          );
    
    return YES;
}
- (void) postInitGragh{
    OSStatus result = noErr;
    if (self.processingGraph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (self.processingGraph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    // Load the ound font from file
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:
                                                           
                                                           @"piano" ofType:@"sf2"]];
    
    
    
    // Initialise the sound font
    //#12 #13
    [self loadFromDLSOrSoundFont: (NSURL *)presetURL withPatch: (int)1];
}


@end
