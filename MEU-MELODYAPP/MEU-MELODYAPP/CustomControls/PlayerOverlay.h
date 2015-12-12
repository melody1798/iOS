//
//  PlayerOverlay.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/03/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//
//Player overlay for casting videos on casting devices. Chrome cast/LG TV/ Roku/Samsung Tv etc.

#import <UIKit/UIKit.h>
#import "CastingVideos.h"

@protocol HandlePlayPauseDelegate;

@interface PlayerOverlay : UIView
{
    IBOutlet UIButton*    btnPlayPause;
    IBOutlet UISlider*    sliderSeekVideo;
    IBOutlet UILabel*     lblFinishTime;
    IBOutlet UILabel*     lblCurrentTime;
    IBOutlet UILabel*     lblConnectionStatus;
    IBOutlet UIActivityIndicatorView*   activityIndicator;
}

@property (weak, nonatomic) id <HandlePlayPauseDelegate> delegatePlayPause;
@property (assign, nonatomic) BOOL  isPlaying;

+ (id)customView;
- (IBAction)btnPlayPausePressed:(id)sender;
- (void)sliderSeekValue:(NSNumber*)sliderValue;
- (void)addSlider:(NSTimeInterval)currentValue maximumValue:(NSTimeInterval)maximumValue;
- (IBAction)btncastAction:(id)sender;
- (void)hideActivityIndicator;

@end

@protocol HandlePlayPauseDelegate <NSObject>
@optional
- (void)callPlayPause;
- (void)seekToValue:(NSTimeInterval)time;
- (void)castBtnAction;

@end
