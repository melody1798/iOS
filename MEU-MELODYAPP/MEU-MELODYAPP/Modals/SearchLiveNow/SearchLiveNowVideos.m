//
//  SearchLiveNowVideos.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SearchLiveNowVideos.h"
#import "ServerConnection.h"
#import "RequestBuilder.h"
#import "Constant.h"
#import "SearchLiveNowVideo.h"
#import "CommonFunctions.h"

@implementation SearchLiveNowVideos

@synthesize arrSearchVideos;

- (void)searchChannelsLiveNow:(id)target selector:(SEL)selector channelName:(NSString*)channelName isArb:(NSString*)isArb
{
    _delegate = target;
    _eventHandler = selector;
    
    //NSString *strUrl = [NSString stringWithFormat:@"%@%@?channelName=%@&isArb=%@&country=%@", kBaseUrl, kSearchChannel, channelName, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?searchKeyword=%@&country=%@", kBaseUrl, kLiveNowLiveMovies, channelName, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];

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
        
        if ([responseDict objectForKey:@"Response"] == (id)[NSNull null])
        {
            [_delegate performSelectorOnMainThread:_eventHandler withObject:arrSearchVideos waitUntilDone:NO];
        }
        else
        {
            [self fillDict:[responseDict objectForKey:@"Response"]];
        }
    }
}

- (void)fillDict:(NSArray*)arrResponse
{
    arrSearchVideos = [[NSMutableArray alloc] init];
    
    for (id videoInfo in arrResponse) {
        
        SearchLiveNowVideo *objSearchLiveNowVideo = [SearchLiveNowVideo new];
        [objSearchLiveNowVideo fillInfo:videoInfo];
        [arrSearchVideos addObject:objSearchLiveNowVideo];
    }
    [_delegate performSelectorOnMainThread:_eventHandler withObject:arrSearchVideos waitUntilDone:NO];
}

#pragma mark - Upcoming Search

- (void)searchChannelsUpcoming:(id)target selector:(SEL)selector channelName:(NSString*)channelName isArb:(NSString*)isArb
{
    _delegate = target;
    _eventHandler = selector;
    
//    NSString *strUrl = [NSString stringWithFormat:@"%@%@?programname=%@&isArb=%@&country=%@", kBaseUrl, kSearchChannelUpcoming, channelName, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?searchKeyword=%@&country=%@", kBaseUrl, kLiveNowFeaturedService, channelName, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];

    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseUpcoming:)];
}

- (void)serverResponseUpcoming:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
        if ([responseDict objectForKey:@"Response"] == (id)[NSNull null])
        {
            [_delegate performSelectorOnMainThread:_eventHandler withObject:arrSearchVideos waitUntilDone:NO];
        }
        else {
            [self fillUpcomingDict:[responseDict objectForKey:@"Response"]];
        }
    }
}

- (void)fillUpcomingDict:(NSArray*)arrResponse
{
    arrSearchVideos = [[NSMutableArray alloc] init];
    
    for (id videoInfo in arrResponse) {
        
        SearchLiveNowVideo *objSearchLiveNowVideo = [SearchLiveNowVideo new];
        [objSearchLiveNowVideo fillUpcomingProgramInfo:videoInfo];
        [arrSearchVideos addObject:objSearchLiveNowVideo];
    }
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:arrSearchVideos waitUntilDone:NO];
}

#pragma mark - Search in VOD

- (void)searchVOD:(id)target selector:(SEL)selector movieName:(NSString*)movieName isArb:(NSString*)isArb
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?movieStartString=%@&isArb=%@&country=%@", kBaseUrl, kSearchVOD, movieName, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseVOD:)];
}

- (void)serverResponseVOD:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        [self fillVODDict:[responseDict objectForKey:@"Response"]];
    }
}

- (void)fillVODDict:(NSArray*)arrResponse
{
    arrSearchVideos = [[NSMutableArray alloc] init];
    
    for (id videoInfo in arrResponse) {
        
        SearchLiveNowVideo *objSearchLiveNowVideo = [SearchLiveNowVideo new];
        [objSearchLiveNowVideo fillVODInfo:videoInfo];
        [arrSearchVideos addObject:objSearchLiveNowVideo];
    }
    [_delegate performSelectorOnMainThread:_eventHandler withObject:arrSearchVideos waitUntilDone:NO];
}

@end