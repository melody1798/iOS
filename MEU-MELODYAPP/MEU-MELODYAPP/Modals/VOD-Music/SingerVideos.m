//
//  SingerVideos.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SingerVideos.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "Constant.h"
#import "SingerVideo.h"

@implementation SingerVideos

- (void)fetchSingerVideos:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?ArtistId=%@", kBaseUrl, kSingerMovies, [requestParameters objectForKey:@"singerId"]];
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
    self.arrSingerVideos = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        SingerVideo *objDetailGenre = [SingerVideo new];
        [objDetailGenre fillSingerVideos:videoInfo];
        [self.arrSingerVideos addObject:objDetailGenre];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrSingerVideos waitUntilDone:NO];
}

@end