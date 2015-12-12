//
//  Channels.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Channels.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "Channel.h"
#import "CommonFunctions.h"

@implementation Channels

@synthesize arrChannels;

- (void)fetchChannels:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?country=%@", kBaseUrl, kChannelsService, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Write in file
  //  [CommonFunctions writeToTextFile:strUrl];
    
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
    self.arrChannels = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        Channel *objChannel = [Channel new];
        [objChannel fillChannelInfo:videoInfo];
        [self.arrChannels addObject:objChannel];
    }
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrChannels waitUntilDone:NO];
}

#pragma mark - Channel Detail

- (void)fetchChannelDetails:(id)target selector:(SEL)selector channelName:(NSString*)channelName isArb:(NSString*)isArb
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?channelName=%@&isArb=%@", kBaseUrl, kChannelDetailByName, channelName, isArb];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    //Write in file
    [CommonFunctions writeToTextFile:strUrl];

    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseChannelDetails:)];
}

- (void)serverResponseChannelDetails:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        [self fillChannelDetailDict:[responseDict objectForKey:@"Response"]];
    }
}

- (void)fillChannelDetailDict:(NSDictionary*)dictResponse
{
    self.arrChannels = [NSMutableArray new];
    Channel *objChannel = [Channel new];
    [objChannel fillChannelInfo:dictResponse];
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:objChannel waitUntilDone:NO];
}

@end