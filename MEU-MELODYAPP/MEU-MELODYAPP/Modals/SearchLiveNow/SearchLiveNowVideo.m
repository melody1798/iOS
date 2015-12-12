//
//  SearchLiveNowVideo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SearchLiveNowVideo.h"
#import "CommonFunctions.h"
@implementation SearchLiveNowVideo

@synthesize videoName_en, videoName_ar;
@synthesize videoDescription_en, videoDescription_ar;
@synthesize videoId;
@synthesize videoUrl;
@synthesize videoThumb;
@synthesize createdOn;
@synthesize videoDuration;
@synthesize isSeries;
@synthesize videoType;
@synthesize artistName_en, artistName_ar;
@synthesize channelName;
@synthesize channelURL;
@synthesize upcomingVideoChannelLogoUrl;
@synthesize upcomingVideoDay;
@synthesize upcomingVideoName_en;
@synthesize upcomingVideoName_ar;
@synthesize upcomingVideoStartTime;
@synthesize upcomingChannelName;
@synthesize liveVideoDay;

- (void)fillInfo:(id)dict
{
    channelName = [dict objectForKey:@"ChannelNameEng"];
    videoThumb = [dict objectForKey:@"ChannelLogoUrl"] != (id)[NSNull null]?[dict objectForKey:@"ChannelLogoUrl"]:@"";
    videoName_en = [dict objectForKey:@"EnglishTitle"];
    videoName_ar = [dict objectForKey:@"ArabicTitle"];
    upcomingVideoStartTime = [dict objectForKey:@"StartTime"];
    upcomingChannelName = [dict objectForKey:@"ChannelNameEng"];
    channelURL = [dict objectForKey:@"ChannelUrl"];
    upcomingVideoDay = [dict objectForKey:@"Day"];
    upcomingVideoChannelLogoUrl = [dict objectForKey:@"ChannelLogoUrl"] != (id)[NSNull null]?[dict objectForKey:@"ChannelLogoUrl"]:@"";;
}

- (void)fillUpcomingProgramInfo:(id)dict
{
    upcomingVideoChannelLogoUrl = [dict objectForKey:@"ChannelLogoUrl"] != (id)[NSNull null]?[dict objectForKey:@"ChannelLogoUrl"]:@"";
    upcomingVideoName_en = [CommonFunctions isEnglish]?[dict objectForKey:@"EnglishTitle"]:[dict objectForKey:@"ArabicTitle"];
    upcomingVideoName_ar = [dict objectForKey:@"ArabicTitle"];
    upcomingVideoDay = [dict objectForKey:@"Day"];
    upcomingVideoStartTime = [dict objectForKey:@"StartTime"];
    upcomingChannelName = [dict objectForKey:@"ChannelNameEng"];
    channelName = [dict objectForKey:@"ChannelNameEng"];
    videoThumb = [dict objectForKey:@"ChannelLogoUrl"] != (id)[NSNull null]?[dict objectForKey:@"ChannelLogoUrl"]:@"";
    videoName_en = [CommonFunctions isEnglish]?[dict objectForKey:@"EnglishTitle"]:[dict objectForKey:@"ArabicTitle"];
    videoName_ar = [dict objectForKey:@"ArabicTitle"];
    channelURL = [dict objectForKey:@"ChannelUrl"];
}

- (void)fillVODInfo:(id)dict
{
    if ([dict objectForKey:@"Duration"] == (id)[NSNull null])
        videoDuration = @"";
    else
        videoDuration = [dict objectForKey:@"Duration"];
    
    videoName_en = [CommonFunctions isEnglish]?[dict objectForKey:@"EnglishTitle"]:[dict objectForKey:@"ArabicTitle"];
    videoName_ar = [dict objectForKey:@"ArabicTitle"];
    
    videoDescription_en = [CommonFunctions isEnglish]?[dict objectForKey:@"MovieDescription"]:[dict objectForKey:@"ArabicDescription"];
    videoDescription_ar = [dict objectForKey:@"ArabicDescription"];
    if (videoDescription_en == (id)[NSNull null]) {
        videoDescription_en = @"";
    }
    if (videoDescription_ar == (id)[NSNull null]) {
        videoDescription_ar = @"";
    }
    
    videoId = [dict objectForKey:@"Id"];
    
    if ([dict objectForKey:@"MovieUrl"] == (id)[NSNull null])
        videoUrl = [dict objectForKey:@""];
    else
        videoUrl = [dict objectForKey:@"MovieUrl"];
    videoThumb = [dict objectForKey:@"ThumbNail"];
    createdOn = [dict objectForKey:@"CreatedOn"];
    
    isSeries = [[dict objectForKey:@"IsSeries"] boolValue];
    if (isSeries)
        videoDuration = [NSString stringWithFormat:@"%@", [dict objectForKey:@"NoofEpisodes"]];
    
    if ([dict objectForKey:@"VideoType"] != [NSNull null]) {
        videoType = [[dict objectForKey:@"VideoType"] integerValue];
    }
    else
        videoType = 0;
    
    if (![dict objectForKey:@"VideoType"]) {
        videoType = 0;
    }
    if (videoType == 2) {
        
        if ([dict objectForKey:@"ArtistEnglishName"] == (id)[NSNull null])
            artistName_en = @"";
        
        else
            artistName_en = [dict objectForKey:@"ArtistEnglishName"];
        
        if ([dict objectForKey:@"ArtistArabicName"] == (id)[NSNull null])
            artistName_ar = @"";
        else
            artistName_ar = [dict objectForKey:@"ArtistArabicName"];
    }
    else
    {
        artistName_en = @"";
        artistName_ar = @"";
    }
}

@end