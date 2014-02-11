//
//  DsMusicControll.m
//  duosuccess
//
//  Created by Rick Li on 12/12/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsMusicControll.h"

@implementation DsMusicControll

@synthesize delegate;
@synthesize elapsedRemains;
@synthesize playBtn;

@synthesize isPlaying;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isPlaying = false;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)changeToStop{
    if(isPlaying){
        [self.playBtn setImage:[UIImage imageNamed:@"player-play" ] forState:(UIControlStateNormal)];
        elapsedRemains.text = @"";
        
    }
}

bool isTapPlay = false;
- (IBAction)onTapPlayButton:(id)sender {
    NSLog(@"OnTapPlayButton %d", isPlaying);
    if(isPlaying){
        [self.playBtn setImage:[UIImage imageNamed:@"player-play" ] forState:(UIControlStateNormal)];
        elapsedRemains.text = @"";
        
    }else{
        
        [self.playBtn setImage:[UIImage imageNamed:@"player-stop" ] forState:(UIControlStateNormal)];
        
    }
    isPlaying = !isPlaying;
    [self.delegate onTapPlayButon:self];


}
@end
