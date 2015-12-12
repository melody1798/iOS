//
//  LiveNowFeaturedVideos.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveNowFeaturedVideos.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "LiveNowFeaturedVideo.h"
#import "CommonFunctions.h"

@implementation LiveNowFeaturedVideos

@synthesize arrLiveFeaturedVideos;

//48 hours videos
- (void)fetchLiveFeaturedVideos:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
//    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kLiveNowFeaturedService, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]]];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kLiveNowFeaturedService, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Write url in file
    [CommonFunctions writeToTextFile:strUrl];

    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponse:)];
}

//Live videos
- (void)fetchLiveMovies:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kLiveNowLiveMovies, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Write url in file
    [CommonFunctions writeToTextFile:strUrl];
    
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
            [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrLiveFeaturedVideos waitUntilDone:NO];
        }
        else
            [self fillDict:[responseDict objectForKey:@"Response"]];
    }
}

- (void)fillDict:(NSArray*)arrResponse
{
    self.arrLiveFeaturedVideos = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        LiveNowFeaturedVideo *objLiveNowFeaturedVideo = [LiveNowFeaturedVideo new];
        [objLiveNowFeaturedVideo fillLiveFeaturedVideoInfo:videoInfo];
        [self.arrLiveFeaturedVideos addObject:objLiveNowFeaturedVideo];
    }

    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrLiveFeaturedVideos waitUntilDone:NO];
}

@end