//
//  UpcomingVideo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "UpcomingVideo.h"
#import "CommonFunctions.h"
@implementation UpcomingVideo

@synthesize upcomingVideoName_en, upcomingVideoName_ar;
@synthesize upcomingVideoTime;
@synthesize upcomingVideoId;
@synthesize upcomingVideoUrl;
@synthesize upcomingVideoThumbnail;
@synthesize upcomingDay;

- (void)fillChannelInfo:(id)info
{
//    upcomingVideoName_en = [CommonFunctions isEnglish]?[info objectForKey:@"MovieName"]:[info objectForKey:@"MovieNameArb"];

    upcomingVideoName_en =[info objectForKey:@"MovieName"];

    if ([info objectForKey:@"MovieNameArb"] == (id)[NSNull null])
        upcomingVideoName_ar = @"";
    else
        upcomingVideoName_ar = [info objectForKey:@"MovieNameArb"];
    upcomingVideoTime = [info objectForKey:@"StartTime"];
    upcomingVideoId = [info objectForKey:@"MovieId"];
    upcomingVideoUrl = [info objectForKey:@""];
    upcomingVideoThumbnail = [info objectForKey:@"ChannelLogoUrl"];
    upcomingDay = [info objectForKey:@"Day"];
}

@end