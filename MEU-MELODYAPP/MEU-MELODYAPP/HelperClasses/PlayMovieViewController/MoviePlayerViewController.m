//
//  MoviePlayerViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommonFunctions.h"
#import "AppDelegate.h"
#import "WatchListMovies.h"
#import <AVFoundation/AVFoundation.h>

@interface MoviePlayerViewController () <UIWebViewDelegate>
{
    MPMoviePlayerController*    moviePlayer;
    IBOutlet UIWebView*         webVw;
    IBOutlet UIButton*          btnCastVideo;
    float                       fDeviceVolume;
    
    IBOutlet UIWebView*         webVwVideoPlayer;
}

@property (strong, nonatomic) NSString*     strBoveExtendedUrl;

- (IBAction)btnDoneAction:(id)sender;
- (IBAction)btnCastAction:(id)sender;

@end

@implementation MoviePlayerViewController

@synthesize strVideoUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (iPhone4WithIOS7) {
        CGRect webVWFrame = webVw.frame;
        webVWFrame.size.width = 500;
        webVw.frame = webVWFrame;
    }
    //Enable sound play even if phone is on silent mode.
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceVolumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    
    //////
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
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.isEnableOrientation = YES;
    
    if([CommonFunctions isIphone])
        [_barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kProximaNova_Regular size:14.0],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    NSString *urlString =  [self getYouTubeEmbed:strVideoUrl embedRect:webVw.frame];
    [webVw loadHTMLString:urlString baseURL:[NSURL URLWithString:@""]];
    webVw.scrollView.scrollEnabled = NO;
    //webVw.contentMode = UIViewContentModeScaleToFill;
   // webVw.scalesPageToFit = NO;
    
    if (_strVideoId != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], _strVideoId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (IBAction)btnCastAction:(id)sender
{
    _discoveryManager.devicePicker.delegate = self;
    [_discoveryManager.devicePicker showPicker:sender];
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

- (void)createAndDisplayMPVolumeView
{
    UIView *volumeHolder = [[UIView alloc] initWithFrame: CGRectMake(btnCastVideo.frame.origin.x, btnCastVideo.frame.origin.y+btnCastVideo.frame.size.height, 260, 20)];
    [volumeHolder setBackgroundColor: [UIColor clearColor]];
    [self.view addSubview: volumeHolder];
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: volumeHolder.bounds];
    [volumeHolder addSubview: myVolumeView];
}

- (void)devicePicker:(DevicePicker *)picker didSelectDevice:(ConnectableDevice *)device
{
    [self createAndDisplayMPVolumeView];
    
    [btnCastVideo setImage:[UIImage imageNamed:@"cast_icon_connect"] forState:UIControlStateNormal];

    _device = device;
    _device.delegate = self;
    [_device connect];
}

- (void)connectableDeviceReady:(ConnectableDevice*)device
{
    NSArray *videoCapabilities = @[
                                   kMediaPlayerPlayVideo,
                                   kMediaControlAny,
                                   kVolumeControlVolumeUpDown
                                   ];
    
    NSArray *imageCapabilities = @[
                                   kMediaPlayerDisplayImage
                                   ];
    
    CapabilityFilter *videoFilter = [CapabilityFilter filterWithCapabilities:videoCapabilities];
    CapabilityFilter *imageFilter = [CapabilityFilter filterWithCapabilities:imageCapabilities];
    
    [[DiscoveryManager sharedManager] setCapabilityFilters:@[videoFilter, imageFilter]];
    
    [self beamWebVideo];
}

- (IBAction)volumeChanged:(UISlider *)sender
{
    float vol = [sender value];
    
    [_device.volumeControl setVolume:vol success:^(id responseObject)
     {
     } failure:^(NSError *setVolumeError)
     {
         // For devices which don't support setVolume, we'll disable
         // slider and should encourage volume up/down instead
         
         sender.enabled = NO;
         sender.userInteractionEnabled = NO;
         
         [_device.volumeControl getVolumeWithSuccess:^(float volume)
          {
              
              sender.value = volume;
          } failure:^(NSError *getVolumeError)
          {
          }];
     }];
}

- (void) volumeUpWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Volume up" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) volumeDownWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Volume down" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)beamWebVideo
{   
    NSString *webAppId;
    
    if ([_device serviceWithName:@"Chromecast"]){
        webAppId = @"4F6217BC";
        
        if ([strVideoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
            NSRange range = [strVideoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [strVideoUrl length])];
            webAppId = [strVideoUrl substringFromIndex:range.location+1];
        }
    }
    else if ([_device serviceWithName:@"webOS TV"])
        webAppId = @"SampleWebApp";
    else if ([_device serviceWithName:@"AirPlay"])
    {
        webAppId = @"http://www.connectsdk.com/files/9613/9656/8539/test_image.jpg";
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Airplay" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
         [_device.launcher launchYouTube:webAppId success:^(LaunchSession *lSession){
     
     UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Success" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
     [alert show];
     
     }failure:^(NSError *error){
     UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Failure" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
     [alert show];
     }];
    
    
    if ([strVideoUrl rangeOfString:@".m3u8" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [_device.mediaPlayer playMedia:[NSURL URLWithString:strVideoUrl] iconURL:[NSURL URLWithString:@""] title:@"Melody" description:@"" mimeType:@"video/m3u8" shouldLoop:NO success:^(LaunchSession *lSession, id<MediaControl> mediaControl){
            
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Success" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
                               failure:^(NSError *error){
                                   UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:@"Failure" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                   [alert show];
                               }];
    }
}

- (void)connectableDeviceDisconnected:(ConnectableDevice*)device withError:(NSError*)error
{
    
}

#pragma mark - Youtube handling
-(NSString *)getYouTubeEmbed:(NSString *)VideoPath embedRect:(CGRect)rect
{
    NSString *html = @"";
    
    if ([VideoPath rangeOfString:@"vimeo.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSString *embedHTML = [NSString stringWithFormat:@"<iframe width=\"%f\" height=\"%f\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>",rect.size.width,rect.size.height,VideoPath];
        html = [NSString stringWithFormat:@"%@",embedHTML];
    }
    else if ([VideoPath rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        webVw.allowsInlineMediaPlayback = YES;
        webVw.mediaPlaybackRequiresUserAction = NO;

        NSArray* dividedText = [VideoPath componentsSeparatedByString:@"v="];
        NSString *videoUrl;
        
        if ([dividedText count] > 1) {
            videoUrl = [dividedText objectAtIndex:1];
            
            NSString *filePath = [CommonFunctions isIphone]?[[NSBundle mainBundle] pathForResource:@"youtubeiPhone" ofType:@"html"]:[[NSBundle mainBundle] pathForResource:@"youtube" ofType:@"html"];
            
            NSError *error;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
                html = [htmlStr stringByReplacingOccurrencesOfString:@"**" withString:videoUrl];
            }
        }
    }
    else if ([VideoPath rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        //webVw.allowsInlineMediaPlayback = YES;
        //webVw.mediaPlaybackRequiresUserAction = NO;

        [CommonFunctions brightCoveExtendedUrl:VideoPath];

        if (![CommonFunctions isIphone]) {
            
            CGRect webVwFrame = webVw.frame;
            webVwFrame.origin.x = webVw.frame.origin.x-20;
            webVwFrame.origin.y = webVw.frame.origin.y-10;
            webVwFrame.size.width = 1044;
            webVwFrame.size.height = 728;
            webVw.frame = webVwFrame;
            
            webVw.allowsInlineMediaPlayback = YES;
            webVw.mediaPlaybackRequiresUserAction = NO;
            html = [NSString stringWithFormat:@"<iframe src=%@&playsinline=1&autoStart=true width=%f\" height=%f\" frameborder=0 marginwidth=0 marginheight=0 scrolling=no; border-width:0px 0px 0px 0px ; margin-bottom:0px; max-width:%f\" allowfullscreen webkit-playsinline> </iframe> <div style=margin-bottom:0px><a href=%@ target=_blank></a></strong> </div>", VideoPath, webVw.frame.size.width, webVw.frame.size.height, webVw.frame.size.width, VideoPath];
        }
        else
        {
            webVw.opaque = NO;
            
            html = [NSString stringWithFormat:@"<iframe src=%@&playsinline=1&autoStart=true width=%f\" height=%f\" frameborder=0 marginwidth=0 marginheight=0 scrolling=no; border-width:0px 0px 0px 0px ; margin-bottom:0px; max-width:%f\" allowfullscreen webkit-playsinline> </iframe> <div style=margin-bottom:0px><a href=%@ target=_blank></a></strong> </div> <style>body {background-color: transparent;}</style>", VideoPath, webVw.frame.size.width, webVw.frame.size.height, webVw.frame.size.width, VideoPath];
        }
    }
    else
    {
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:VideoPath]];
        [moviePlayer.view setFrame:webVw.frame];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayer];
        moviePlayer.controlStyle = MPMovieControlStyleDefault;
        moviePlayer.shouldAutoplay = YES;
        moviePlayer.scalingMode = MPMovieScalingModeFill;
        [moviePlayer prepareToPlay];
        [self.view addSubview:moviePlayer.view];
        moviePlayer.fullscreen = YES;
        [moviePlayer stop];
        [moviePlayer play];
    }
    return html;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}

- (IBAction)btnDoneAction:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [moviePlayer stop];
    [moviePlayer.view removeFromSuperview];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.isEnableOrientation = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resizeWebView
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight))
    {
    }
    else{
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    return YES;
}

- (NSString*)fetchBcoveUrl:(NSString*)bCoveUrl
{
    NSURL *url = [NSURL URLWithString:bCoveUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        
        if ([CommonFunctions isIphone]) {
            
            NSInteger width = [[UIScreen mainScreen] bounds].size.height;
            NSInteger height = [[UIScreen mainScreen] bounds].size.width-44;
            
            self.strBoveExtendedUrl = [NSString stringWithFormat:@"%@&autoStart=true&width=%ld&height=%ld", [response valueForKey:@"URL"], (long)width, (long)height];
        }
        else
        {
            self.strBoveExtendedUrl = [NSString stringWithFormat:@"%@&autoStart=true&width=1048&height=728", [response valueForKey:@"URL"]];
        }
        
        NSString * html = [NSString stringWithFormat:@"<iframe src=%@&playsinline=1&autoStart=true width=%f\" height=%f\" frameborder=0 marginwidth=0 marginheight=0 scrolling=no; border-width:0px 0px 0px 0px ; margin-bottom:0px; max-width:%f\" allowfullscreen webkit-playsinline> </iframe> <div style=margin-bottom:0px><a href=%@ target=_blank></a></strong> </div> <style>body {background-color: transparent;}</style>", self.strBoveExtendedUrl, webVwVideoPlayer.frame.size.width, webVwVideoPlayer.frame.size.height, webVwVideoPlayer.frame.size.width, self.strBoveExtendedUrl];
        
        
        [webVwVideoPlayer loadHTMLString:html baseURL:nil];
    }
    return self.strBoveExtendedUrl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end