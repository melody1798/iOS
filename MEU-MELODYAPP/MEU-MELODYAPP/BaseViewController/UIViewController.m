//
//  UIViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "UIViewController.h"
#import "Constant.h"
#import "AppDelegate.h"

@interface UIViewController ()

@end

@implementation UIViewController (RotationAdditions)

- (BOOL)shouldAutorotate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return YES;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    if ([self isKindOfClass:NSClassFromString(@"MPInlineVideoFullscreenViewController")] || [self isKindOfClass:NSClassFromString(@"AVFullScreenViewController")] || [self isKindOfClass:NSClassFromString(@"AVPlayerViewController")] || [self isKindOfClass:NSClassFromString(@"AVFullScreenPlaybackControlsViewController")])
    {
       // [self wantsFullScreenLayout];
        [appDelegate checkOrientation:1];
        return UIInterfaceOrientationMaskLandscape;
    }
    else
        if ([self isKindOfClass:NSClassFromString(@"MoviePlayerViewController")])
    {
        [appDelegate checkOrientation:1];
        return UIInterfaceOrientationMaskLandscape;
    }
    else if ([self isKindOfClass:NSClassFromString(@"MPMoviePlayerViewController")])
    {
        [appDelegate checkOrientation:1];
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        if (appDelegate.isEnableOrientation == YES)
            return UIInterfaceOrientationMaskAll;
    }
    [appDelegate checkOrientation:0];
    return UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskPortrait;
}

@end