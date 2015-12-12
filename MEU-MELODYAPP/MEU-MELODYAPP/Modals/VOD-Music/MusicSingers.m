//
//  MusicSingers.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MusicSingers.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "MusicSinger.h"

@implementation MusicSingers

- (void)fetchMusicSingers:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@&country=%@", kBaseUrl, kVODMusicVideos, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
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
    self.arrMusicSingers = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        MusicSinger *obMusicSinger = [MusicSinger new];
        [obMusicSinger fillMusicSingers:videoInfo];
        [self.arrMusicSingers addObject:obMusicSinger];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrMusicSingers waitUntilDone:NO];
}

@end