//
//  LiveNowFeaturedVideo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveNowFeaturedVideo.h"
#import "CommonFunctions.h"

@implementation LiveNowFeaturedVideo

@synthesize videoThumbnailUrl_en, videoThumbnailUrl_ar;
@synthesize videoName_en, videoName_ar;
@synthesize videoTime_en;
@synthesize videoUrl;
@synthesize channelLogoUrl;
@synthesize startTime;

- (void)fillLiveFeaturedVideoInfo:(id)info
{
    videoName_en = [CommonFunctions isEnglish]?[info objectForKey:@"EnglishTitle"]:([[info objectForKey:@"ArabicTitle"] isEqual:[NSNull null]]?@"":[info objectForKey:@"ArabicTitle"]);
    videoName_ar = ([[info objectForKey:@"ArabicTitle"] isEqual:[NSNull null]]?@"":[info objectForKey:@"ArabicTitle"]);
    videoTime_en = [info objectForKey:@"Day"];
    
    videoThumbnailUrl_en = [info objectForKey:@"ThumbNail"];
    videoThumbnailUrl_ar = [info objectForKey:@"ThumbNail"];
    
    channelLogoUrl = [info objectForKey:@"ChannelLogoUrl"];
    if ([info objectForKey:@"ChannelLogoUrl"] == (id)[NSNull null])
        
        channelLogoUrl = @"";
    
    startTime = [info objectForKey:@"Day"];
    if ([info objectForKey:@"Day"] == (id)[NSNull null])
        
        startTime = @"";
    
    if ([info objectForKey:@"ChannelUrl"] != (id)[NSNull null]) {
        videoUrl = [info objectForKey:@"ChannelUrl"];
    }
}

@end