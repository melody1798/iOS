//
//  PlayerOverlay.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/03/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "PlayerOverlay.h"
#import "CommonFunctions.h"

@implementation PlayerOverlay

@synthesize isPlaying;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)customView
{    
    PlayerOverlay *customView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

        customView = [[[NSBundle mainBundle] loadNibNamed:@"PlayerOverlay~iPhone" owner:nil options:nil] lastObject];
    else
        customView = [[[NSBundle mainBundle] loadNibNamed:@"PlayerOverlay" owner:nil options:nil] lastObject];

    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[PlayerOverlay class]])
        return customView;
    else
        return nil;
}

- (void)updateSliderWithCastingVideo:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"UpdateSliderWithCastingVideo"])
    {
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"position"];
        sliderSeekVideo.value = [total floatValue];
        [self sliderValueChanged];
    }
}

- (void)addSlider:(NSTimeInterval)currentValue maximumValue:(NSTimeInterval)maximumValue
{
    //Notification to update slider value same as casting device value.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateSliderWithCastingVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSliderWithCastingVideo:) name:@"UpdateSliderWithCastingVideo" object:nil];
    
    //Notification to remove overlay when intrupt from other device.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemovePlayerOverlay" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePlayerOverlay) name:@"RemovePlayerOverlay" object:nil];
    
    
    [activityIndicator startAnimating];
    
    UIDeviceOrientation interfaceOrientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self setFrame:CGRectMake(0, 0, 1024, 768)];
    }
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self setFrame:CGRectMake(0, 0, 568, 320)];
        if (iPhone4WithIOS7)
            [self setFrame:CGRectMake(0, 0, 480, 320)];
    }
    
    [sliderSeekVideo addTarget:self
                  action:@selector(sliderDidEndSliding:)
        forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [sliderSeekVideo addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    sliderSeekVideo.continuous = YES;
    sliderSeekVideo.minimumValue = 0;
    sliderSeekVideo.maximumValue = maximumValue;
    sliderSeekVideo.value = currentValue;

    //Show current polaying value
    NSTimeInterval timeInterval = sliderSeekVideo.value;
    long seconds = lroundf(timeInterval);
    int hour = (int) seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    if (hour > 0)
        lblCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins, secs];
    else
        lblCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
    
    //Calculate remaining time
    NSTimeInterval timeIntervalTotalTime = sliderSeekVideo.maximumValue-timeInterval;
    long secondsMax = lroundf(timeIntervalTotalTime);
    
    int hourMax = (int)secondsMax / 3600;
    int minsMax = (secondsMax % 3600) / 60;
    int secsMax = secondsMax % 60;
    
    if (hourMax > 0)
        lblFinishTime.text = [NSString stringWithFormat:@"-%02d:%02d:%02d", hourMax, minsMax, secsMax];
    else
        lblFinishTime.text = [NSString stringWithFormat:@"-%02d:%02d", minsMax, secsMax];
}

- (void)sliderValueChanged
{
    //Show value change on slider
    NSTimeInterval timeInterval = sliderSeekVideo.value;
    long seconds = lroundf(timeInterval);
    int hour = (int) seconds / 3600;
    int mins = (int) (seconds % 3600) / 60;
    int secs = (int) seconds % 60;
    lblCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
    
    if (hour > 0)
        lblCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins, secs];
    else
        lblCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
    
    //Show value change on slider
    NSTimeInterval timeIntervalTotalTime = sliderSeekVideo.maximumValue-timeInterval;
    long secondsMax = lroundf(timeIntervalTotalTime);
    int hourMax = (int)secondsMax / 3600;
    int minsMax = (secondsMax % 3600) / 60;
    int secsMax = secondsMax % 60;
    
    if (hourMax > 0)
        lblFinishTime.text = [NSString stringWithFormat:@"-%02d:%02d:%02d", hourMax, minsMax, secsMax];
    else
        lblFinishTime.text = [NSString stringWithFormat:@"-%02d:%02d", minsMax, secsMax];
}

- (void)sliderDidEndSliding:(NSNotification *)notification {
    
    NSNumber *myNumber = [NSNumber numberWithFloat:sliderSeekVideo.value];
    
    if ([_delegatePlayPause respondsToSelector:@selector(sliderSeekValue:)]) {
        [_delegatePlayPause performSelector:@selector(sliderSeekValue:) withObject:myNumber];
    }
}

- (void)hideActivityIndicator
{
    activityIndicator.hidden = YES;
    lblConnectionStatus.text = @"Playing on chrome cast";
}

- (IBAction)btnPlayPausePressed:(id)sender
{
    if (isPlaying) {
        [btnPlayPause setImage:[UIImage imageNamed:@"icon_play_cast"] forState:UIControlStateNormal];
        isPlaying = NO;
    }
    else{
        [btnPlayPause setImage:[UIImage imageNamed:@"icon_pause_cast"] forState:UIControlStateNormal];
        isPlaying = YES;
    }
    
    if ([_delegatePlayPause respondsToSelector:@selector(callPlayPause)])
        [_delegatePlayPause performSelector:@selector(callPlayPause) withObject:nil];
}

- (void)btncastAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateSliderWithCastingVideo" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemovePlayerOverlay" object:nil];

    if ([_delegatePlayPause respondsToSelector:@selector(castBtnAction)]) {
        [_delegatePlayPause performSelector:@selector(castBtnAction) withObject:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removePlayerOverlay
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateSliderWithCastingVideo" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemovePlayerOverlay" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([_delegatePlayPause respondsToSelector:@selector(castBtnAction)]) {
        [_delegatePlayPause performSelector:@selector(castBtnAction) withObject:nil];
    }
}

- (void)sliderSeekValue:(NSNumber*)sliderValue
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end