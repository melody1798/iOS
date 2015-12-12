//
//  DetailGenre.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "DetailGenre.h"
#import "CommonFunctions.h"
@implementation DetailGenre

@synthesize movieTitle_en, movieTitle_ar;
@synthesize movieUrl;
@synthesize movieID;
@synthesize movieGenre_en, movieGenre_ar;
@synthesize movieThumbnail;
@synthesize movieDuration;
@synthesize musicVideoSingerName_en, musicVideoSingerName_ar;
@synthesize videoType;

- (void)fillGenreDetailInfo:(id)info
{
    movieTitle_en = [info objectForKey:@"EnglishTitle"];
    movieTitle_ar = [info objectForKey:@"ArabicTitle"];
    
    if ([info objectForKey:@"MovieUrl"] == (id)[NSNull null])
        movieUrl = @"";
    else
        movieUrl = [info objectForKey:@"MovieUrl"];
    
    movieID = [info objectForKey:@"Id"];
    movieThumbnail = [info objectForKey:@"ThumbNail"];
    if ([info objectForKey:@"MovieUrl"] != (id)[NSNull null] && [[info objectForKey:@"CustomeGenre"] count] != 0) {
        movieGenre_en = [CommonFunctions isEnglish]?[[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"EnglishName"]:[[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"ArabicName"];
        
        movieGenre_ar = [[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"ArabicName"];
    }
    else{
        movieGenre_en = @"";
        movieGenre_ar = @"";
    }
    
    movieDuration =  [info objectForKey:@"Duration"] != (id)[NSNull null]?[info objectForKey:@"Duration"]:@"";

    if ([info objectForKey:@"ArtistEnglishName"] != (id)[NSNull null])
        musicVideoSingerName_en = [info objectForKey:@"ArtistEnglishName"];
    else
        musicVideoSingerName_en = @"";

    if ([info objectForKey:@"ArtistArabicName"] != (id)[NSNull null])
        musicVideoSingerName_ar = [info objectForKey:@"ArtistArabicName"];
    else
        musicVideoSingerName_ar = @"";

    if ([info objectForKey:@"VideoType"] != (id)[NSNull null])
        videoType = [[info objectForKey:@"VideoType"] intValue];
    else
        videoType = 0;
}

@end