//
//  WatchListMovie.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "WatchListMovie.h"
#import "CommonFunctions.h"

@implementation WatchListMovie

@synthesize movieName_en, movieName_ar;
@synthesize movieThumb;
@synthesize movieUrl;
@synthesize movieId;
@synthesize seriesID;
@synthesize episodeID;
@synthesize seasonNum;
@synthesize episodeNum;
@synthesize episodeDuration;
@synthesize seriesName_en;
@synthesize seriesName_ar;
@synthesize seriesDesc_en;
@synthesize seriesDesc_ar;
@synthesize seriesSeasonsCount;
@synthesize bIsExistsInWatchList;
@synthesize videoType;

- (void)fillDict:(id)info
{
    movieName_en = [CommonFunctions isEnglish]?[info objectForKey:@"EnglishTitle"]:[info objectForKey:@"ArabicTitle"];
    movieName_ar = [info objectForKey:@"ArabicTitle"];
    movieThumb = [info objectForKey:@"ThumbNail"];
    
    movieUrl = [info objectForKey:@"MovieUrl"];
    if ([info objectForKey:@"MovieUrl"] == (id)[NSNull null])
        movieUrl = @"";
    
    movieId = [info objectForKey:@"Id"];
    bIsExistsInWatchList = [[info objectForKey:@"IsExistsInWatchList"] boolValue];
    videoType = [[info objectForKey:@"VideoType"] integerValue];
    
    if ([info objectForKey:@"SeriesID"] != (id)[NSNull null])
    {
        seriesID = [NSString stringWithFormat:@"%@", [info objectForKey:@"SeriesID"]];
        seasonNum = [info objectForKey:@"Season"];
        episodeNum = [info objectForKey:@"EpisodeNumber"];
        episodeDuration = [info objectForKey:@"Duration"];
        
        seriesName_en = [info objectForKey:@"SeriesName"];
        seriesName_ar = [info objectForKey:@"SeriesNameArb"];
        seriesDesc_en = [info objectForKey:@"EnglishDescription"];
        seriesDesc_ar = [info objectForKey:@"ArabicDescription"];
        seriesSeasonsCount = [[info objectForKey:@"NumberofSeasons"] intValue];
    }
    else
    {
        seriesID = [info objectForKey:@""];
        seasonNum = [info objectForKey:@""];
        episodeNum = [info objectForKey:@""];
        episodeDuration = [info objectForKey:@"Duration"];
        seriesName_en = [info objectForKey:@""];
        seriesName_ar = [info objectForKey:@""];
        seriesDesc_en = [info objectForKey:@""];
        seriesDesc_ar = [info objectForKey:@""];
        seriesSeasonsCount = [[info objectForKey:@""] intValue];
    }
}

@end
