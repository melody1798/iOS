//
//  Episodes.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Episodes.h"
#import "Episode.h"
#import "ServerConnection.h"
#import "RequestBuilder.h"
#import "Constant.h"

@implementation Episodes

- (void)fetchFeaturedEpisodes:(id)target selector:(SEL)selector userId:(NSString *)userId
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl;
    if (userId == nil) {
        strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kFeaturedEpisodes, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    else{
        strUrl = [NSString stringWithFormat:@"%@%@?userId=%@?Country=%@", kBaseUrl, kFeaturedEpisodes, userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverFetauredEpisodesResponse:)];
}

- (void)fetchSeriesEpisodes:(id)target selector:(SEL)selector  parameter:(NSString*)serieId userID:(NSString*)userId
{
    _delegate = target;
    _eventHandler = selector;
    
//    /userId
    NSString *strUrl;
    if (userId == nil) {
        strUrl = [NSString stringWithFormat:@"%@%@?seriesId=%@&?Country=%@", kBaseUrl, kSeriesEpisodes, serieId, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    else{
        strUrl = [NSString stringWithFormat:@"%@%@?seriesId=%@&userId=%@&Country=%@", kBaseUrl, kSeriesEpisodes, serieId, userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverFetauredEpisodesResponse:)];
}

- (void)fetchSeriesSeasonalEpisodes:(id)target selector:(SEL)selector  parameter:(NSString*)serieId seasonId:(NSString*)seasonId userID:(NSString*)userId
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl;
    if (userId == nil) {
        strUrl = [NSString stringWithFormat:@"%@%@?seriesId=%@&seasonId=%@&Country=%@", kBaseUrl, kSeriesEpisodes, serieId, seasonId, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    else{
        strUrl = [NSString stringWithFormat:@"%@%@?seriesId=%@&seasonId=%@&userId=%@&Country=%@", kBaseUrl, kSeriesEpisodes, serieId, seasonId, userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverFetauredEpisodesResponse:)];
}

- (void)serverFetauredEpisodesResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        [self fillDict:[responseDict objectForKey:@"Response"]];
    }
}

- (void)fillDict:(NSArray*)arrResponse
{
    self.arrEpisodes = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        Episode *objEpisode = [Episode new];
        [objEpisode fillDict:videoInfo];
        [self.arrEpisodes addObject:objEpisode];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrEpisodes waitUntilDone:YES];
}

@end