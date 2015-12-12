//
//  Episode.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Episode.h"
#import "CommonFunctions.h"
#import "DetailArtist.h"

typedef enum {
    Actor = 1,
    Producer = 2,
    Supporting = 3,
    Singer = 4
} ArtistRole;

@implementation Episode

@synthesize episodeDesc_en, episodeDesc_ar;
@synthesize episodeId;
@synthesize episodeName_en, episodeName_ar;
@synthesize episodeThumb;
@synthesize episodeUrl;
@synthesize episodeNum;
@synthesize seasonNum;
@synthesize seriesID;
@synthesize bIsExistsInWatchList;
@synthesize episodeDuration;
@synthesize seriesName_en, seriesName_ar;
@synthesize seriesDesc_en, seriesDesc_ar;
@synthesize seriesSeasonsCount;
@synthesize arrCastAndCrew, arrProducers;
@synthesize seriesThumbnail;

- (void)fillDict:(id)info
{
    seriesID = [info objectForKey:@"SeriesID"];
    episodeName_en = [info objectForKey:@"EnglishTitle"];
    episodeName_ar = [info objectForKey:@"ArabicTitle"];
    
    episodeDesc_en = @" ";
    episodeDesc_ar = @" ";
    episodeDesc_en = [info objectForKey:@"EnglishDescription"];
    episodeDesc_ar = [info objectForKey:@"ArabicDescription"];
    
    
    if ([info objectForKey:@"EnglishDescription"] == (id)[NSNull null])
        episodeDesc_en = @"";
    if ([info objectForKey:@"ArabicDescription"] == (id)[NSNull null])
        episodeDesc_ar = @"";

    episodeId = [[info objectForKey:@"Id"] stringValue];
    episodeThumb = [info objectForKey:@"ThumbNail"];
    episodeUrl = [info objectForKey:@"MovieUrl"];
    if ([info objectForKey:@"MovieUrl"] == (id)[NSNull null])
        episodeUrl = @"";
    
    if ([info objectForKey:@"episodeNum"] == (id)[NSNull null])
        episodeNum = @"";
    else
        episodeNum = [info objectForKey:@"EpisodeNumber"];

    
    if ([info objectForKey:@"Season"] == (id)[NSNull null])
        seasonNum = @"";
    else
        seasonNum = [NSString stringWithFormat:@"%@", [info objectForKey:@"Season"]];

    bIsExistsInWatchList = [[info objectForKey:@"IsExistsInWatchList"] boolValue];
    episodeDuration = [info objectForKey:@"Duration"];
    if ([info objectForKey:@"Duration"] == (id)[NSNull null])
        episodeDuration = @"";
        
    seriesName_en = [CommonFunctions isEnglish]?[info objectForKey:@"SeriesName"]:[info objectForKey:@"SeriesNameArb"];
    seriesName_ar = [[info objectForKey:@"SeriesNameArb"] length]==0?@"":[info objectForKey:@"SeriesNameArb"];
    seriesDesc_en = [[info objectForKey:@"SeriesDescription"] length]==0?@"":[info objectForKey:@"SeriesDescription"];
    seriesDesc_ar = [[info objectForKey:@"SeriesDescriptionArb"] length]==0?@"":[info objectForKey:@"SeriesDescriptionArb"];
    
    seriesSeasonsCount = [[info objectForKey:@"NumberofSeasons"] integerValue];
    
    if ([[info objectForKey:@"CastAndCrew"] count]!=0) {
        
        [self fillArtistDetails:[info objectForKey:@"CastAndCrew"]];
    }
}

- (void)fillArtistDetails:(id)info
{
    arrCastAndCrew = [NSMutableArray new];
    arrProducers = [NSMutableArray new];
    for (int i = 0; i < [info count]; i++) {
        
        DetailArtist *objDetailArtist = [DetailArtist new];
        objDetailArtist.artistName_en = [[info objectAtIndex:i] objectForKey:@"ArtistEnglishName"];
        objDetailArtist.artistName_ar = [[info objectAtIndex:i] objectForKey:@"ArtistArabicName"];
        objDetailArtist.artistRole_en = [[info objectAtIndex:i] objectForKey:@"EnglishRoleName"];
        objDetailArtist.artistRole_ar = [[info objectAtIndex:i] objectForKey:@"ArabicRoleName"];
        objDetailArtist.artistRoleId = [[[info objectAtIndex:i] objectForKey:@"ArtistRole"] stringValue];
        if ([[[info objectAtIndex:i] objectForKey:@"ArtistRole"] integerValue] == Producer)
            [arrProducers addObject:objDetailArtist];
        else
            [arrCastAndCrew addObject:objDetailArtist];
    }
}

@end