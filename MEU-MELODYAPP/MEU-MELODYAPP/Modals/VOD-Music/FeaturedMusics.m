//
//  FeaturedMusics.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FeaturedMusics.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "FeaturedMusic.h"

@implementation FeaturedMusics

- (void)fetchFeaturedMusicVideos:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kVODMusicFeatured, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
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

- (void)fillDict:(NSArray*)arrResponse
{
    self.arrFeaturedMusicVideos = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        FeaturedMusic *objFeaturedMusic = [FeaturedMusic new];
        [objFeaturedMusic fillVODMusicFeaturedVideoInfo:videoInfo];
        [self.arrFeaturedMusicVideos addObject:objFeaturedMusic];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrFeaturedMusicVideos waitUntilDone:NO];
}

@end