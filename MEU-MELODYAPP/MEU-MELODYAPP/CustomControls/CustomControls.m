//
//  CustomControls.m
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 15/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CustomControls.h"
#import "Constant.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"

@implementation CustomControls

@synthesize objPlayerOverlay;

+ (UIBarButtonItem*)setNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler
{
    UIImage *imgNavBarItem = [UIImage imageNamed:imageName];
    UIButton *btnNavItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(![CommonFunctions isIphone])
        btnNavItem.bounds = CGRectMake(0, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    else
        btnNavItem.bounds = CGRectMake(0, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    
    [btnNavItem setImage:imgNavBarItem forState:UIControlStateNormal];
    [btnNavItem addTarget:targetController action:eventHandler forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgNavBarItem.size.width, 58.0)];
    
    UIBarButtonItem *barBtnItem;
    
    if(![CommonFunctions isIphone])
    {
        backButtonView.frame = CGRectMake(0, -160, imgNavBarItem.size.width, 100.0);
        if ([imageName isEqualToString:@"back_btn"]) {
          //  btnNavItem.backgroundColor = [UIColor yellowColor];
            backButtonView.bounds = CGRectOffset(backButtonView.bounds, -15, -32);
        }
        else
            backButtonView.bounds = CGRectOffset(backButtonView.bounds, -15, -32);
        
        barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
        
        [backButtonView addSubview:btnNavItem];
    }
    else{
        //backButtonView.frame = CGRectMake(0, 0, 80, 64.0);
        //backButtonView.backgroundColor = [UIColor yellowColor];
        
        if ([imageName isEqual:@"setting_icon~iphone"]) {
            
            btnNavItem.frame = CGRectMake(0, 0, 42, 55);
            btnNavItem.imageEdgeInsets = UIEdgeInsetsMake(-5, 0, 10, -20);
            
//            if IS_IOS7_OR_LATER
//                btnNavItem.bounds = CGRectOffset(btnNavItem.bounds, -20, -30);
//            else
//                btnNavItem.bounds = CGRectOffset(btnNavItem.bounds, -20, -17);
        }
        else
        {
            btnNavItem.frame = CGRectMake(0, 0, 47, 55);
            btnNavItem.imageEdgeInsets = UIEdgeInsetsMake(-7, -30, 10, 10);
            
            //btnNavItem.bounds = CGRectOffset(btnNavItem.bounds, -8, -20);
        }
        
        barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnNavItem];
        
    }
   // backButtonView.backgroundColor = [UIColor greenColor];
    //[backButtonView addSubview:btnNavItem];
    
//    if([CommonFunctions isIphone])
//    {
//        UIButton *btnForTapableArea = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnForTapableArea.bounds = CGRectMake( -130, -15, imgNavBarItem.size.width+15, imgNavBarItem.size.height+15);
//        [btnForTapableArea addTarget:targetController action:eventHandler forControlEvents:UIControlEventTouchUpInside];
//        // btnForTapableArea.backgroundColor = [UIColor purpleColor];
//        // [backButtonView addSubview:btnForTapableArea];
//        [backButtonView bringSubviewToFront:btnForTapableArea];
//    }
    
    return barBtnItem;
}

+ (UIBarButtonItem*)setWatchLisNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler
{
    UIImage *imgNavBarItem = [UIImage imageNamed:imageName];
    UIButton *btnNavItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(![CommonFunctions isIphone])
        btnNavItem.bounds = CGRectMake( 0, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    else
        btnNavItem.frame = CGRectMake( -20, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    [btnNavItem setImage:imgNavBarItem forState:UIControlStateNormal];
    [btnNavItem addTarget:targetController action:eventHandler forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgNavBarItem.size.width, 48.0)];
    [backButtonView addSubview:btnNavItem];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    UILabel *lblWatchListCounter = [[UILabel alloc] initWithFrame:CGRectMake(12, 28, 15, 15)];
    lblWatchListCounter.text = [NSString stringWithFormat:@"%d", appDelegate.iWatchListCounter];
    lblWatchListCounter.textAlignment = NSTextAlignmentCenter;
    lblWatchListCounter.font = [UIFont fontWithName:kProximaNova_Bold size:12.0];
    lblWatchListCounter.textColor = YELLOW_COLOR;
    lblWatchListCounter.backgroundColor = [UIColor clearColor];
    [btnNavItem addSubview:lblWatchListCounter];
    
    UILabel *lblWatchListText = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 80, 15)];
    lblWatchListText.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil] uppercaseString];

    lblWatchListText.font = [UIFont fontWithName:kProximaNova_Bold size:13.0];
    lblWatchListText.textColor = [UIColor whiteColor];
    [btnNavItem addSubview:lblWatchListText];
    lblWatchListText.backgroundColor = [UIColor clearColor];
    
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, -70, -4);

    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    return barBtnItem;
}

+ (UIBarButtonItem*)setWatchListEditNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler
{
    UIImage *imgNavBarItem = [UIImage imageNamed:imageName];
    UIButton *btnNavItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(![CommonFunctions isIphone])
        btnNavItem.bounds = CGRectMake( 0, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    else
        btnNavItem.frame = CGRectMake( -20, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    [btnNavItem setImage:imgNavBarItem forState:UIControlStateNormal];
    [btnNavItem addTarget:targetController action:eventHandler forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgNavBarItem.size.width, 48.0)];
    [backButtonView addSubview:btnNavItem];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    UILabel *lblWatchListCounter = [[UILabel alloc] initWithFrame:CGRectMake(12, 28, 15, 15)];
    lblWatchListCounter.text = [NSString stringWithFormat:@"%d", appDelegate.iWatchListCounter];
    lblWatchListCounter.textAlignment = NSTextAlignmentCenter;
    lblWatchListCounter.font = [UIFont fontWithName:kProximaNova_Bold size:12.0];
    lblWatchListCounter.textColor = YELLOW_COLOR;
    lblWatchListCounter.backgroundColor = [UIColor clearColor];
    [btnNavItem addSubview:lblWatchListCounter];
    
    UILabel *lblWatchListText = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 80, 15)];
    lblWatchListText.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil] uppercaseString];
    lblWatchListText.font = [UIFont fontWithName:kProximaNova_Bold size:13.0];
    lblWatchListText.textColor = [UIColor whiteColor];
    [btnNavItem addSubview:lblWatchListText];
    lblWatchListText.backgroundColor = [UIColor clearColor];
    
    UILabel *lblEditText = [[UILabel alloc] initWithFrame:CGRectMake(145, 28, 80, 15)];
    lblEditText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"edit" value:@"" table:nil];
    lblEditText.font = [UIFont fontWithName:kProximaNova_Bold size:13.0];
    lblEditText.textColor = [UIColor whiteColor];
    [btnNavItem addSubview:lblEditText];
    lblEditText.backgroundColor = [UIColor clearColor];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
    {
        [lblEditText setFrame:CGRectMake(130, 28, 80, 15)];
        lblEditText.font = [UIFont fontWithName:kProximaNova_Bold size:10.0];
    }
    
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, -100, -4);
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    return barBtnItem;
}

+ (UIBarButtonItem*)setWatchListDoneNavigationBarButton:(NSString*)imageName Target:(id)targetController selector:(SEL)eventHandler
{
    UIImage *imgNavBarItem = [UIImage imageNamed:imageName];
    UIButton *btnNavItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(![CommonFunctions isIphone])
        btnNavItem.bounds = CGRectMake( 0, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    else
        btnNavItem.frame = CGRectMake( -20, 0, imgNavBarItem.size.width, imgNavBarItem.size.height);
    [btnNavItem setImage:imgNavBarItem forState:UIControlStateNormal];
    [btnNavItem addTarget:targetController action:eventHandler forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgNavBarItem.size.width, 48.0)];
    [backButtonView addSubview:btnNavItem];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    UILabel *lblWatchListCounter = [[UILabel alloc] initWithFrame:CGRectMake(12, 28, 15, 15)];
    lblWatchListCounter.text = [NSString stringWithFormat:@"%d", appDelegate.iWatchListCounter];
    lblWatchListCounter.textAlignment = NSTextAlignmentCenter;
    lblWatchListCounter.font = [UIFont fontWithName:kProximaNova_Bold size:12.0];
    lblWatchListCounter.textColor = YELLOW_COLOR;
    lblWatchListCounter.backgroundColor = [UIColor clearColor];
    [btnNavItem addSubview:lblWatchListCounter];
    
    UILabel *lblWatchListText = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 80, 15)];
    lblWatchListText.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil] uppercaseString];
    lblWatchListText.font = [UIFont fontWithName:kProximaNova_Bold size:13.0];
    lblWatchListText.textColor = [UIColor whiteColor];
    [btnNavItem addSubview:lblWatchListText];
    lblWatchListText.backgroundColor = [UIColor clearColor];
    
    UILabel *lblEditText = [[UILabel alloc] initWithFrame:CGRectMake(145, 28, 80, 15)];
    lblEditText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"done" value:@"" table:nil];
    lblEditText.font = [UIFont fontWithName:kProximaNova_Bold size:13.0];
    lblEditText.textColor = [UIColor whiteColor];
    [btnNavItem addSubview:lblEditText];
    lblEditText.backgroundColor = [UIColor clearColor];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
    {
        [lblEditText setFrame:CGRectMake(130, 28, 80, 15)];
        lblEditText.font = [UIFont fontWithName:kProximaNova_Bold size:10.0];
    }
    
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, -100, -4);
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    return barBtnItem;
}

+ (UIButton*)melodyIconButton:(id)targetController selector:(SEL)eventHandler
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor clearColor]];
    btn.tag = 5000;
    [btn addTarget:targetController action:eventHandler forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, 0, 80, 72)];
    return btn;
}

- (UIButton*)castingIconButton:(id)sender moviePlayerViewController:(MPMoviePlayerViewController*)objMPMoviePlayerViewController
{
    self.startingTime = objMPMoviePlayerViewController.moviePlayer.currentPlaybackTime;
    [self discoverDevices];
    btnCasting = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCasting setBackgroundColor:[UIColor clearColor]];
    btnCasting.tag = 6000;
    [btnCasting setImage:[UIImage imageNamed:@"cast_icon_disconnect"] forState:UIControlStateNormal];
    [btnCasting addTarget:self action:@selector(btncastAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *viewSender = (UIView*)sender;
    [btnCasting setFrame:CGRectMake(viewSender.frame.origin.x+50, viewSender.frame.origin.y+50, 50, 50)];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [btnCasting setFrame:CGRectMake(viewSender.frame.origin.x+10, viewSender.frame.origin.y+50, 50, 50)];
    
    return btnCasting;
}

- (UIView*)adddOverlayOnMPMoviplayerWhileCasting:(MPMoviePlayerViewController*)objMPMoviePlayerViewController
{    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    if (objPlayerOverlay!=nil) {
        [objPlayerOverlay removeFromSuperview];
        objPlayerOverlay = nil;
    }
    objPlayerOverlay = [PlayerOverlay customView];
    objPlayerOverlay.delegatePlayPause = self;
    objPlayerOverlay.isPlaying = YES;

    [objPlayerOverlay addSlider:appDelegate.videoStartTime maximumValue:self.totalVideoDuration];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideActivityIndicatorAfterConnection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideActivityIndicator) name:@"HideActivityIndicatorAfterConnection" object:nil];

    return objPlayerOverlay;
}

- (void)hideActivityIndicator
{
    if (objPlayerOverlay!=nil) {
        [objPlayerOverlay hideActivityIndicator];
    }
}

- (void)sliderSeekValue:(NSNumber*)sliderValue
{
    float result = [sliderValue floatValue];
    [objCastingVideo seekForward:result];
}

- (void)sliderDidEndSliding:(NSNotification *)notification {
    [objCastingVideo seekForward:slider.value];
}

- (void)callPlayPause
{
    if (isPlaying) {
        [objCastingVideo stopVideo];
        isPlaying = NO;
    }
    else{
        [objCastingVideo playVideoAfterStop];
        isPlaying = YES;
    }
}

- (UIView*)createAndDisplayMPVolumeView:(id)sender
{    
    UIView *viewVolume =(UIView*)sender;
    UIView *volumeHolder = [[UIView alloc] initWithFrame: CGRectMake(viewVolume.frame.origin.x, viewVolume.frame.origin.y+viewVolume.frame.size.height, 260, 20)];
    [volumeHolder setBackgroundColor: [UIColor clearColor]];
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: volumeHolder.bounds];
    [volumeHolder addSubview: myVolumeView];
    
    return volumeHolder;
}

- (void)discoverDevices
{
    [objPlayerOverlay removeFromSuperview];
    objCastingVideo = [CastingVideos new];
    [objCastingVideo discoverDevice];
}

- (void)btnPlayStopOnCastDevice:(id)sender
{
    UIButton *btnPlayPauseOnCast = (UIButton*)sender;
    if (isPlaying) {
        [btnPlayPauseOnCast setImage:[UIImage imageNamed:@"icon_play_cast"] forState:UIControlStateNormal];
        [objCastingVideo stopVideo];
        isPlaying = NO;
    }
    else{
        [btnPlayPauseOnCast setImage:[UIImage imageNamed:@"icon_pause_cast"] forState:UIControlStateNormal];
        [objCastingVideo playVideoAfterStop];
        isPlaying = YES;
    }
}

- (void)btncastAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.isConnectedToDevice) {
       
        [objPlayerOverlay removeFromSuperview];
        objPlayerOverlay = nil;
        isPlaying = NO;
        [viewOverlayforCastingFunc removeFromSuperview];
        [objCastingVideo disconnectDevice];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideActivityIndicatorAfterConnection" object:nil];
        
        UIButton *btnCast = (UIButton*)sender;
        [btnCast setImage:[UIImage imageNamed:@"cast_icon_disconnect"] forState:UIControlStateNormal];
    }
    else
    {
        isPlaying = YES;
        objCastingVideo.strVideoUrl = self.strVideoUrl;
        objCastingVideo.strVideoName = self.strVideoName;
        objCastingVideo.strYoutubeVideoUrl = self.strYoutubeVideoUrl;
        objCastingVideo.viewDevices = sender;
        objCastingVideo.videoStartingTime = self.startingTime;
        objCastingVideo.videoTotalDuration = self.totalVideoDuration;
        
        [objCastingVideo connectToDevice];
        [btnPlayStop setImage:[UIImage imageNamed:@"icon_pause_cast"] forState:UIControlStateNormal];
    }
}

- (void)castBtnAction
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.isConnectedToDevice) {
        
        [btnCasting setImage:[UIImage imageNamed:@"cast_icon_disconnect"] forState:UIControlStateNormal];
        [objPlayerOverlay removeFromSuperview];
        isPlaying = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:objPlayerOverlay];
        [viewOverlayforCastingFunc removeFromSuperview];
        [objCastingVideo disconnectDevice];
    }
    else
    {
        isPlaying = YES;
        objCastingVideo.strVideoUrl = self.strVideoUrl;
        objCastingVideo.viewDevices = btnCasting;
        objCastingVideo.videoStartingTime = self.startingTime;
        objCastingVideo.videoTotalDuration = self.totalVideoDuration;
        [btnCasting setImage:[UIImage imageNamed:@"cast_icon_connect"] forState:UIControlStateNormal];

        [objCastingVideo connectToDevice];
        [btnPlayStop setImage:[UIImage imageNamed:@"icon_pause_cast"] forState:UIControlStateNormal];
    }
}

- (void)hideCastButton
{
    btnCasting.hidden = YES;
}

- (void)unHideCastButton
{
    btnCasting.hidden = NO;
}

- (void)disconnectDevice
{
    [objCastingVideo disconnectDevice];
}

- (NSInteger)castingDevicesCount
{
   return [objCastingVideo fetchCastingDevicesCount];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideActivityIndicatorAfterConnection" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end