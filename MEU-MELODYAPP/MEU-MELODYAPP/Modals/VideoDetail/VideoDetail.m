//
//  VideoDetail.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VideoDetail.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "DetailArtists.h"
#import "DetailArtist.h"
#import "CommonFunctions.h"

typedef enum {
    Actor = 1,
    Producer = 2,
    Supporting = 3,
    Singer = 4
} ArtistRole;

@implementation VideoDetail

@synthesize movieDesc_en, movieDesc_ar;
@synthesize movieTitle_ar, movieTitle_en;
@synthesize movieDuration;
@synthesize movieUrl;
@synthesize movieType_en, movieType_ar;
@synthesize arrCastAndCrew;
@synthesize arrProducers;
@synthesize existsInWatchlist;
@synthesize movieThumbnail;
@synthesize videoType;
@synthesize seriesName;
@synthesize seriesDesc;
@synthesize seriesSeasonCount;
@synthesize seasonNum;
@synthesize episodeNum;
@synthesize duration;
@synthesize movieTitle_eniPhone;

- (void)fetchVideoDetail:(id)target selector:(SEL)selector parameter:(NSString*)requestParameter UserID:(NSString*)userID
{
    _delegate = target;
    _eventHandler = selector;
    NSString *strUrl;
    if(userID==nil)
        strUrl = [NSString stringWithFormat:@"%@%@?movieId=%@", kBaseUrl, kVideoDetail, requestParameter];
    else
        strUrl = [NSString stringWithFormat:@"%@%@?movieId=%@&userid=%@", kBaseUrl, kVideoDetail, requestParameter, (userID == Nil)?kEmptyString:userID];
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponse:)];
}

- (void)serverResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
        [self fillDict:[responseDict objectForKey:@"Response"]];
    }
}

- (void)fillDict:(NSDictionary*)dictResponse
{
    existsInWatchlist = [[dictResponse objectForKey:@"IsExistsInWatchList"] boolValue];
    movieDesc_en = [CommonFunctions isEnglish]?[dictResponse objectForKey:@"EnglishDescription"]:[dictResponse objectForKey:@"ArabicDescription"];
    if ([dictResponse objectForKey:@"EnglishDescription"] == (id)[NSNull null]) {
        movieDesc_en = @"";
    }
    movieDesc_ar = [dictResponse objectForKey:@"ArabicDescription"];
    if ([dictResponse objectForKey:@"ArabicDescription"] == (id)[NSNull null]) {
        movieDesc_ar = @"";
    }
    movieTitle_en = [CommonFunctions isEnglish]?[dictResponse objectForKey:@"EnglishTitle"]:[dictResponse objectForKey:@"ArabicTitle"];
    
    movieTitle_eniPhone = [dictResponse objectForKey:@"EnglishTitle"];
    
    movieTitle_ar = [dictResponse objectForKey:@"ArabicTitle"];
    
    movieUrl = [dictResponse objectForKey:@"MovieUrl"];

    if ([dictResponse objectForKey:@"MovieUrl"] == (id)[NSNull null])
        movieUrl = @"";

    movieDuration = [dictResponse objectForKey:@"Duration"];
    if ([dictResponse objectForKey:@"Duration"] == (id)[NSNull null])
        movieDuration = @"";

    if ([[dictResponse objectForKey:@"CustomeGenre"] count] > 0) {
        movieType_en = [[[dictResponse objectForKey:@"CustomeGenre"] objectAtIndex:0]objectForKey:@"EnglishName"];
        movieType_ar = [[[dictResponse objectForKey:@"CustomeGenre"] objectAtIndex:0]objectForKey:@"ArabicName"];
    }
    movieThumbnail = [dictResponse objectForKey:@"ThumbNail"];
    videoType = [NSString stringWithFormat:@"%@", [dictResponse objectForKey:@"VideoType"]];
    
    if ([videoType isEqualToString:@"3"]) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

            seriesName = [dictResponse objectForKey:@"SeriesName"];
        else
            seriesName = [dictResponse objectForKey:@"SeriesNameArb"];

        seriesSeasonCount =  [[dictResponse objectForKey:@"NumberofSeasons"] stringValue];
        seasonNum  =  [[dictResponse objectForKey:@"Season"] stringValue];
        episodeNum =  [[dictResponse objectForKey:@"EpisodeNumber"] stringValue];
        duration = [dictResponse objectForKey:@"Duration"];
    }
    
    if ([[dictResponse objectForKey:@"CastAndCrew"] count]!=0) {
        
        [self fillArtistDetails:[dictResponse objectForKey:@"CastAndCrew"]];
    }
    
    //Fill UIView.    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self waitUntilDone:NO];
}

- (void)fillArtistDetails:(id)info
{
    arrCastAndCrew = [NSMutableArray new];
    arrProducers = [NSMutableArray new];
    for (int i = 0; i < [info count]; i++) {
        
        DetailArtist *objDetailArtist = [DetailArtist new];
        
        objDetailArtist.artistId = [[info objectAtIndex:i] objectForKey:@"ArtistId"];
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