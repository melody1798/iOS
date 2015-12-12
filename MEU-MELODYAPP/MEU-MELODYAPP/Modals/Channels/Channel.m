//
//  Channel.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Channel.h"
#import "CommonFunctions.h"
@implementation Channel

@synthesize channelName_en, channelName_ar;
@synthesize channelId;
@synthesize channelLogoUrl;
@synthesize channelLiveNowVideoName_en, channelLiveNowVideoName_ar;
@synthesize channelLiveNowVideoTime;
@synthesize channelLiveNowVideoUrl;

- (void)fillChannelInfo:(id)info
{
    if ([info objectForKey:@"Id"] == (id)[NSNull null])
        channelId = @"";
    else
        channelId = [info objectForKey:@"Id"];
    
    if ([info objectForKey:@"EnglishTitle"] == (id)[NSNull null])
        channelName_en = @"";
    else
        channelName_en = [info objectForKey:@"EnglishTitle"];
    
    if ([info objectForKey:@"ArabicTitle"] == (id)[NSNull null])

        channelName_ar = @"";
    else
        channelName_ar = [info objectForKey:@"ArabicTitle"];
    
    if ([info objectForKey:@"LogoUrl"] == (id)[NSNull null])

        channelLogoUrl = @"";
    else
        channelLogoUrl = [info objectForKey:@"LogoUrl"];
    
    channelLiveNowVideoName_en = [info objectForKey:@""];
    channelLiveNowVideoName_ar = [info objectForKey:@""];
    channelLiveNowVideoTime = [info objectForKey:@""];
    
    if ([info objectForKey:@"VideoUrl"] == (id)[NSNull null])

        channelLiveNowVideoUrl = @"";
    else
        channelLiveNowVideoUrl = [info objectForKey:@"VideoUrl"];
}

@end
