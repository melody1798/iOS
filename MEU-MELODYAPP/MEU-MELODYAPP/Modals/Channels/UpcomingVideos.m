//
//  UpcomingVideos.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "UpcomingVideos.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "UpcomingVideo.h"

@implementation UpcomingVideos

@synthesize liveVideoName_en, liveVideoName_ar;
@synthesize liveVideoStartTime, liveVideoThumbnail;
@synthesize channelLogoUrl, liveChannelUrl;

- (void)fetchChannelUpcomingVideos:(id)target selector:(SEL)selector channelName:(NSString*)channelName
{
    _delegate = target;
    _eventHandler = selector;
    //channelName=my%20channel&country=India

    NSString *strUrl = [NSString stringWithFormat:@"%@%@?channelName=%@&country=%@", kBaseUrl, kChannelUpcomingMovies, channelName, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
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
            [_delegate performSelectorOnMainThread:_eventHandler withObject:self waitUntilDone:NO];
        else
        {
            if ([[responseDict objectForKey:@"Response"] objectForKey:@"ChannelLogoUrl"] != (id)[NSNull null])
                
                channelLogoUrl = [[responseDict objectForKey:@"Response"] objectForKey:@"ChannelLogoUrl"];
            else
                channelLogoUrl = @"";
            
            if ([[responseDict objectForKey:@"Response"] objectForKey:@"LiveChannel"] != (id)[NSNull null])
                [self fillLiveNowDataDict:[[responseDict objectForKey:@"Response"] objectForKey:@"LiveChannel"]];
            [self fillDict:[[responseDict objectForKey:@"Response"] objectForKey:@"UpcomingChannels"]];
        }
    }
}

- (void)fillLiveNowDataDict:(id)info
{
    self.liveVideoName_en = [info objectForKey:@"MovieName"];
    self.liveVideoName_ar = [info objectForKey:@"MovieNameArb"];
    self.liveVideoStartTime = [info objectForKey:@"Day"];
    self.liveVideoThumbnail = [info objectForKey:@"ThumbNail"];
    self.liveChannelUrl = [info objectForKey:@"ChannelUrl"];
}

- (void)fillDict:(NSArray*)arrResponse
{
    self.arrUpcomingVideos = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        UpcomingVideo *objUpcomingVideo = [UpcomingVideo new];
        [objUpcomingVideo fillChannelInfo:videoInfo];
        [self.arrUpcomingVideos addObject:objUpcomingVideo];
    }
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self waitUntilDone:NO];
}

@end