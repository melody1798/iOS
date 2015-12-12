//
//  CastingVideos.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 18/03/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "CastingVideos.h"

@implementation CastingVideos

@synthesize viewDevices;
@synthesize strVideoUrl, strVideoName, strDeviceName, strYoutubeVideoUrl;
@synthesize videoStartingTime;
@synthesize timerUpdateSeek;
@synthesize videoTotalDuration;
@synthesize timerStop, timerUpdateSeekFromCastDevice;

- (void)discoverDevice
{
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    NSArray *webAppCapabilities = @[
                                    kWebAppLauncherLaunch,
                                    kWebAppLauncherMessageSend,
                                    kWebAppLauncherMessageReceive,
                                    kWebAppLauncherClose
                                    ];
    CapabilityFilter *webAppCapabilityFilter = [CapabilityFilter filterWithCapabilities:webAppCapabilities];
    [AirPlayService setAirPlayServiceMode:AirPlayServiceModeWebApp];
    [_discoveryManager setCapabilityFilters:@[webAppCapabilityFilter]];
    
    _discoveryManager = [DiscoveryManager sharedManager];
    [_discoveryManager startDiscovery];
}

- (void)connectToDevice
{
    _discoveryManager.devicePicker.delegate = self;
    [_discoveryManager.devicePicker showPicker:viewDevices];
}

- (void)devicePicker:(DevicePicker *)picker didSelectDevice:(ConnectableDevice *)device
{
    strDeviceName = [device serviceDescription].manufacturer;
    
   // [self createAndDisplayMPVolumeView];
    appDelegate.isConnectedToDevice = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopVideoWhileCasting" object:nil];
    UIButton *btnCast = (UIButton*) viewDevices;
    [btnCast setImage:[UIImage imageNamed:@"cast_icon_connect"] forState:UIControlStateNormal];
    
    _device = device;
    _device.delegate = self;
    [_device connect];
}

#pragma mark - Cast video Method

- (void)bufferYoutubeVideo {
    if (_youtubeSession)
    {
        [_youtubeSession closeWithSuccess:^(id responseObject)
         {
         } failure:^(NSError *error)
         {
         }];
        
        _youtubeSession = nil;
    }
    else
    {
        [_device.launcher launchYouTube:@"ix88zSJ1JVU" success:^(LaunchSession *launchSession)
         {
             if ([_device hasCapability:kLauncherAppClose])
             {
                 _youtubeSession = launchSession;
             }
         } failure:^(NSError *error)
         {
         }];
    }
}

- (void)beamWebVideo
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceVolumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    
    //M3u8
    if ([strVideoUrl rangeOfString:@".m3u8" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [self castM3U8Video];
    }
    else if (strDeviceName!=nil && [strDeviceName rangeOfString:@"samsung" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        if ([strYoutubeVideoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
            NSRange range = [strYoutubeVideoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [strYoutubeVideoUrl length])];
            NSString *videoID = [strYoutubeVideoUrl substringFromIndex:range.location+1];
            
            [_device.launcher launchYouTube:videoID startTime:appDelegate.videoStartTime success:^(LaunchSession *launchSession) {
                
            } failure:^(NSError *error) {
            }];
        }
    }
    //youtube
    else if ([strVideoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound){
        
        NSRange range = [strVideoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [strVideoUrl length])];
        [self castYoutubeVideo:[strVideoUrl substringFromIndex:range.location+1]];
    }
    else if ([strVideoUrl rangeOfString:@"brightcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];

        [self castBcoveVideo];
    }
    //M3u8
    else
    {
        [self castBcoveVideo];
    }
}

- (void)castYoutubeVideo:(NSString*)videoId
{
    [_device.launcher launchYouTube:videoId startTime:appDelegate.videoStartTime success:^(LaunchSession *launchSession) {
        
        
    } failure:^(NSError *error) {
    }];
}

- (void)castBcoveVideo
{
    [_device.mediaPlayer playMedia:[NSURL URLWithString:strVideoUrl] iconURL:[NSURL URLWithString:@""] title:strVideoName description:@"" mimeType:@"video/mp4" shouldLoop:YES success:^(LaunchSession *lSession, id<MediaControl> mediaControl){
        _launchSession = lSession;
        _mediaControl = mediaControl;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicatorAfterConnection" object:nil];
        
        self.timerUpdateSeek = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(updateSeek)
                                                           userInfo:nil
                                                            repeats:YES];
        }
                           failure:^(NSError *error){
                           }];
}

- (void)updateSeek
{
    [_mediaControl getPlayStateWithSuccess:^(MediaControlPlayState playState) {
        
        [self seekForward:appDelegate.videoStartTime];
        
    } failure:^(NSError *error) {
    }];
}

- (void)fetchCastingDeviceVideoTime
{
    [_mediaControl getPositionWithSuccess:^(NSTimeInterval position) {
        
        NSDictionary* userInfo = @{@"position": @(position)};

        if (position == appDelegate.videoTotalTime) {
            
            //Video Finish
            [self.timerUpdateSeekFromCastDevice invalidate];
            self.timerUpdateSeekFromCastDevice = nil;
            
            [self beamWebVideo];
        }
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSliderWithCastingVideo" object:self userInfo:userInfo];
        
    } failure:^(NSError *error) {
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Chrome Cast Over written" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [self.timerUpdateSeekFromCastDevice invalidate];
        self.timerUpdateSeekFromCastDevice = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePlayerOverlay" object:nil];
        
        [self getPositionCastingDeviceVideo];

        [self disconnectDevice];
    }];
}

- (void)stopVideo
{
    [_device.mediaControl pauseWithSuccess:nil
                                   failure:nil];
}

- (void)playVideoAfterStop
{
    [_device.mediaControl playWithSuccess:^(id responseObject) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)seekForward:(NSTimeInterval)currentPlayBackTime
{
    [self.timerUpdateSeekFromCastDevice invalidate];
    self.timerUpdateSeekFromCastDevice = nil;
    
    [_mediaControl seek:currentPlayBackTime success:^(id responseObject) {
        
        [self playVideoAfterStop];
        [timerUpdateSeek invalidate];
        timerUpdateSeek = nil;
        
        self.timerUpdateSeekFromCastDevice = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(fetchCastingDeviceVideoTime)
                                                              userInfo:nil
                                                               repeats:YES];
    } failure:^(NSError *error) {
        
        [self.timerUpdateSeekFromCastDevice invalidate];
        self.timerUpdateSeekFromCastDevice = nil;
    }];
}

- (void)getPositionCastingDeviceVideo
{
    [_mediaControl getPositionWithSuccess:^(NSTimeInterval position) {
            appDelegate.videoStartTime = position;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];
        
    } failure:^(NSError *error) {
    }];
}

- (void)seekBackword:(NSTimeInterval)currentPlayBackTime
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];

    [_mediaControl seek:currentPlayBackTime success:nil failure:nil];
    [self playVideoAfterStop];
}

- (void)castM3U8Video
{
    [_device.mediaPlayer playMedia:[NSURL URLWithString:strVideoUrl] iconURL:[NSURL URLWithString:@""] title:@"Melody" description:@"" mimeType:@"video/m3u8" shouldLoop:NO success:^(LaunchSession *lSession, id<MediaControl> mediaControl){
        
//        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Success" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
    }
                           failure:^(NSError *error){
//                               UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Failure" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                               [alert show];
                           }];
}

- (void)connectableDeviceReady:(ConnectableDevice*)device
{
    NSArray *videoCapabilities = @[
                                   kMediaPlayerPlayVideo,
                                   kMediaControlAny,
                                   kVolumeControlVolumeUpDown, kMediaControlSeek, kMediaPlayerPlayVideo
                                   ];
    
    NSArray *imageCapabilities = @[
                                   kMediaPlayerDisplayImage
                                   ];
    
    CapabilityFilter *videoFilter = [CapabilityFilter filterWithCapabilities:videoCapabilities];
    CapabilityFilter *imageFilter = [CapabilityFilter filterWithCapabilities:imageCapabilities];
    
    [[DiscoveryManager sharedManager] setCapabilityFilters:@[videoFilter, imageFilter]];
    
    //Beam/cast video
    [self beamWebVideo];
}

- (void)connectableDeviceDisconnected:(ConnectableDevice*)device withError:(NSError*)error
{
  //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Disconnected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //[alert show];
}

- (void)disconnectDevice
{
    appDelegate.isConnectedToDevice = NO;
    [self getPositionCastingDeviceVideo];

    [_device.mediaPlayer closeMedia:_launchSession success:nil failure:nil];
    [_device disconnect];
    
    [self.timerUpdateSeekFromCastDevice invalidate];
    self.timerUpdateSeekFromCastDevice = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)deviceVolumeChanged:(NSNotification *)notification
{
    fDeviceVolume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    
    float vol = fDeviceVolume;
    
    [_device.volumeControl setVolume:vol success:^(id responseObject)
     {
     } failure:^(NSError *setVolumeError)
     {
         // For devices which don't support setVolume, we'll disable
         // slider and should encourage volume up/down instead
         
         [_device.volumeControl getVolumeWithSuccess:^(float volume)
          {
          } failure:^(NSError *getVolumeError)
          {
          }];
     }];
}

- (NSInteger)fetchCastingDevicesCount
{
    return [[_discoveryManager allDevices] count];
}

@end