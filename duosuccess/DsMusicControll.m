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
@synthesize slider;
@synthesize elapsed;
@synthesize remains;
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

- (IBAction)onTapPlayButton:(id)sender {

    if(isPlaying){
        [self.playBtn setImage:[UIImage imageNamed:@"Stop" ] forState:(UIControlStateNormal)];
    }else{
        [self.playBtn setImage:[UIImage imageNamed:@"play" ] forState:(UIControlStateNormal)];
    }
    isPlaying = !isPlaying;
    [self.delegate onTapPlayButon:self];
}
@end
