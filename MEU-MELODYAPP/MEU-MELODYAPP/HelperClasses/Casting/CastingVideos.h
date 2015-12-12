//
//  CastingVideos.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 18/03/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ConnectSDK/ConnectSDK.h>
#import <ConnectSDK/AirPlayService.h>
#import "AppDelegate.h"

@interface CastingVideos : NSObject <DevicePickerDelegate, ConnectableDeviceDelegate>
{
    DiscoveryManager *_discoveryManager;
    ConnectableDevice *_device;
    LaunchSession *_launchSession;
    id<MediaControl> _mediaControl;
    float            fDeviceVolume;
    AppDelegate*     appDelegate;
    NSTimer*           timerUpdateSeek;
    
    NSTimer*           timerStop;
    LaunchSession *_youtubeSession;
}

@property (weak, nonatomic) UIView*                 viewDevices;
@property (strong, nonatomic) NSString*             strVideoUrl;
@property (strong, nonatomic) NSString*             strVideoName;
@property (strong, nonatomic) NSString*             strDeviceName;
@property (strong, nonatomic) NSString*             strYoutubeVideoUrl;
@property (assign, nonatomic) NSTimeInterval        videoStartingTime;
@property (strong, nonatomic) NSTimer*              timerUpdateSeek;
@property (strong, nonatomic) NSTimer*              timerUpdateSeekFromCastDevice;
@property (strong, nonatomic) NSTimer*              timerStop;
@property (assign, nonatomic) NSTimeInterval        videoPosition;
@property (assign, nonatomic) NSTimeInterval        videoTotalDuration;

- (void)discoverDevice;
- (void)connectToDevice;
- (void)disconnectDevice;

- (void)stopVideo;
- (void)playVideoAfterStop;
- (void)seekForward:(NSTimeInterval)currentPlayBackTime;
- (void)seekBackword:(NSTimeInterval)currentPlayBackTime;
- (void)getPositionCastingDeviceVideo;
- (NSInteger)fetchCastingDevicesCount;

@end
