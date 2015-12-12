//
//  SingerVideo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SingerVideo.h"
#import "CommonFunctions.h"
@implementation SingerVideo

@synthesize movieName_en, movieName_ar;
@synthesize movieThumb, movieUrl;
@synthesize movieID;

- (void)fillSingerVideos:(id)info
{
    movieName_en = [info objectForKey:@"EnglishTitle"];
    movieName_ar = [info objectForKey:@"ArabicTitle"];
    movieThumb = [info objectForKey:@"ThumbNail"];
    movieUrl = [info objectForKey:@"MovieUrl"];
    movieID = [info objectForKey:@"Id"];
}

@end