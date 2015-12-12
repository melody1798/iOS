//
//  MoviesCollections.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MoviesCollections.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "MoviesCollection.h"

@implementation MoviesCollections

- (void)fetchMoviesCollections:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
   // NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kVODMoviesCollectionList, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]]];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kVODMoviesCollectionList, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponse:)];
}

- (void)fetchVODCollections:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kVODCollections, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
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
    self.arrMoviesCollections = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        MoviesCollection *objMoviesCollection = [MoviesCollection new];
        [objMoviesCollection fillCollectionDetail:videoInfo];
        [self.arrMoviesCollections addObject:objMoviesCollection];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrMoviesCollections waitUntilDone:NO];
}

@end