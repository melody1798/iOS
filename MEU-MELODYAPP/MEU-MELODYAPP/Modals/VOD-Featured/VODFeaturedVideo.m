//
//  VODFeaturedVideo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODFeaturedVideo.h"
#import "CommonFunctions.h"
@implementation VODFeaturedVideo

@synthesize movieTitle_en, movieTitle_ar;
@synthesize movieThumbnail, movieUrl;
@synthesize movieID;
@synthesize movieTag;
@synthesize videoType;
@synthesize seriesId;
@synthesize seasonNum;
@synthesize artistName_en, artistName_ar;
@synthesize episodeNum;
@synthesize seriesName_en, seriesName_ar;
@synthesize numberOfSeasons;

- (void)fillVODFeaturedVideoInfo:(id)info
{
    movieTitle_en = [CommonFunctions isEnglish]?[info objectForKey:@"EnglishTitle"]:[info objectForKey:@"ArabicTitle"];
    movieTitle_ar = [info objectForKey:@"ArabicTitle"];
    movieThumbnail = [info objectForKey:@"ThumbNail"];
    movieUrl = [info objectForKey:@"MovieUrl"];
    movieID = [[info objectForKey:@"Id"] stringValue];
    movieTag = [CommonFunctions isEnglish]?[info objectForKey:@"EnglishTag"]:[info objectForKey:@"ArabicTag"];
    videoType = [[info objectForKey:@"VideoType"] stringValue];
    seriesId = [info objectForKey:@"SeriesID"];
    seasonNum = [info objectForKey:@"Season"];
    artistName_en = [info objectForKey:@"ArtistEnglishName"];
    artistName_ar = [info objectForKey:@"ArtistArabicName"];
    episodeNum = [info objectForKey:@"EpisodeNumber"];
    seriesName_en = [info objectForKey:@"SeriesName"];
    seriesName_ar = [info objectForKey:@"SeriesNameArb"];
    numberOfSeasons = [[info objectForKey:@"NumberofSeasons"] integerValue];
}

@end