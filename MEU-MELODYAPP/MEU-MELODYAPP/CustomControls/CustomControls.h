//
//  CustomControls.h
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 15/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// To create custom controls like navigation bar buttons, Casting buttons etc.

#import <Foundation/Foundation.h>
#import "CastingVideos.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlayerOverlay.h"

@interface CustomControls : NSObject <HandlePlayPauseDelegate>
{
    CastingVideos*              objCastingVideo;
    UIView*                     viewOverlayforCastingFunc;
    BOOL                        isPlaying;
    UIButton*                   btnPlayStop;
    PlayerOverlay*              objPlayerOverlay;
    UISlider *slider;
    UIButton *btnCasting;
}

@property (strong, nonatomic) NSString*              strVideoUrl;
@property (strong, nonatomic) NSString*              strVideoName;
@property (strong, nonatomic) NSString*              strYoutubeVideoUrl;
@property (assign, nonatomic) NSTimeInterval         startingTime;
@property (assign, nonatomic) NSTimeInterval         totalVideoDuration;
@property (strong, nonatomic) PlayerOverlay*         objPlayerOverlay;

+ (UIBarButtonItem*)setNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler;
+ (UIBarButtonItem*)setWatchLisNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler;
+ (UIBarButtonItem*)setWatchListEditNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler;
+ (UIBarButtonItem*)setWatchListDoneNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler;
+ (UIButton*)melodyIconButton:(id)targetController selector:(SEL)eventHandler;
- (UIButton*)castingIconButton:(id)sender moviePlayerViewController:(MPMoviePlayerViewController*)objMPMoviePlayerViewController;


//Casting actions
- (void)disconnectDevice;
//- (UIView*)createAndDisplayMPVolumeView;
- (UIView*)adddOverlayOnMPMoviplayerWhileCasting:(MPMoviePlayerViewController*)objMPMoviePlayerViewController;

- (void)hideCastButton;
- (void)unHideCastButton;
- (void)removeNotifications;
- (NSInteger)castingDevicesCount;

@end
