//
//  DsMusicControll.h
//  duosuccess
//
//  Created by Rick Li on 12/12/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DsMusicControll;

@protocol DsMusicControlDelegate <NSObject>

- (void)onTapPlayButon: (DsMusicControll *)sender;

@end

@interface DsMusicControll : UIView

@property (weak, nonatomic) IBOutlet UILabel *elapsedRemains;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;


@property bool isPlaying;

@property id <DsMusicControlDelegate> delegate;

- (IBAction)onTapPlayButton:(id)sender;

-(void)changeToStop;

@end
