//
//  LastViewedMovie.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LastViewedMovie.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "CommonFunctions.h"
@implementation LastViewedMovie

@synthesize movieName_en, movieName_ar;
@synthesize movieThumb;
@synthesize movieUrl;
@synthesize movieId;
@synthesize isExistsInWatchList;

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
@synthesize videoType;
@synthesize singerName_en, singerName_ar;

- (void)saveMovieToLastViewed:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kBaseUrl, kLastViewedSave];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseLastViewed:)];
}

- (void)serverResponseLastViewed:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
        
    }
}

- (void)fetchLastviewed:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?userId=%@", kBaseUrl, kLastViewedFetch, [requestParameters objectForKey:@"userId"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseFetchLastViewed:)];
}

- (void)serverResponseFetchLastViewed:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    if ([[responseDict objectForKey:@"Error"] intValue] == 0)
    {
//        Error = 0;
//        Message = "No last viewed movie.";
//        Response = "<null>";
        
        if (![[responseDict valueForKey:@"Message"] isEqualToString:@"No last viewed movie."])
        {
            [self fillDict:[responseDict objectForKey:@"Response"]];
        }
        else
        {
            [_delegate performSelectorOnMainThread:_eventHandler withObject:nil waitUntilDone:NO];
        }
    }
    else
        [_delegate performSelectorOnMainThread:_eventHandler withObject:nil waitUntilDone:NO];
}

- (void)fillDict:(NSDictionary*)dictResponse
{
    if (dictResponse != nil) {
        
        self.movieName_en = [CommonFunctions isEnglish]?[dictResponse objectForKey:@"EnglishTitle"]:[dictResponse objectForKey:@"ArabicTitle"];
        self.movieName_ar = [dictResponse objectForKey:@"ArabicTitle"];
        self.movieThumb = [dictResponse objectForKey:@"ThumbNail"];
        self.movieUrl = [dictResponse objectForKey:@"MovieUrl"];
        if ([dictResponse objectForKey:@"MovieUrl"] == (id)[NSNull null])
            self.movieUrl = @"";
        
        
        self.movieId = [dictResponse objectForKey:@"Id"];
        self.isExistsInWatchList = [dictResponse objectForKey:@"IsExistsInWatchList"];
        self.videoType = [[dictResponse objectForKey:@"VideoType"] integerValue];
        
        if ([dictResponse objectForKey:@"SeriesID"] != (id)[NSNull null])
        {
            seriesID = [NSString stringWithFormat:@"%@", [dictResponse objectForKey:@"SeriesID"]];
            seasonNum = [dictResponse objectForKey:@"Season"];
            episodeNum = [dictResponse objectForKey:@"EpisodeNumber"];
            episodeDuration = [dictResponse objectForKey:@"Duration"];
            
            seriesName_en = [CommonFunctions isEnglish]?[dictResponse objectForKey:@"SeriesName"]:[dictResponse objectForKey:@"SeriesNameArb"];
            seriesName_ar = [[dictResponse objectForKey:@"SeriesNameArb"] length]==0?@"":[dictResponse objectForKey:@"SeriesNameArb"];
            seriesDesc_en = [[dictResponse objectForKey:@"SeriesDescription"] length]==0?@"":[dictResponse objectForKey:@"SeriesDescription"];
            seriesDesc_ar = [[dictResponse objectForKey:@"SeriesDescriptionArb"] length]==0?@"":[dictResponse objectForKey:@"SeriesDescriptionArb"];
            
            seriesSeasonsCount = [[dictResponse objectForKey:@"NumberofSeasons"] integerValue];
        }
        else
        {
            seriesID = [dictResponse objectForKey:@""];
            seasonNum = [dictResponse objectForKey:@""];
            episodeNum = [dictResponse objectForKey:@""];
            episodeDuration = [dictResponse objectForKey:@"Duration"];
        }
        
        if ([[dictResponse objectForKey:@"VideoType"] intValue] == 2)
            if ([dictResponse objectForKey:@"CastAndCrew"] != (id)[NSNull null] && [[dictResponse objectForKey:@"CastAndCrew"] count]>0) {
            
                if ([[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:0] objectForKey:@"ArtistEnglishName"] != (id)[NSNull null])
                    
                    singerName_en = [[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:0] objectForKey:@"ArtistEnglishName"];
                else
                    singerName_en = @"";
                
                
                if ([[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:0] objectForKey:@"ArtistArabicName"] != (id)[NSNull null])
                    
                    singerName_ar = [[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:0] objectForKey:@"ArtistArabicName"];
                else
                    singerName_ar = @"";
        }
        [_delegate performSelectorOnMainThread:_eventHandler withObject:self waitUntilDone:NO];
    }
    else
        [_delegate performSelectorOnMainThread:_eventHandler withObject:nil waitUntilDone:NO];
}

@end