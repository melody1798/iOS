//
//  Series.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Series.h"
#import "ServerConnection.h"
#import "RequestBuilder.h"
#import "Serie.h"

@implementation Series

- (void)fetchAllSeries:(id)target selector:(SEL)selector isArb:(NSString*)isArb
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@&Country=%@", kBaseUrl, kAllSeries, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverSeriesResponse:)];
}

- (void)serverSeriesResponse:(NSMutableData*)responseData
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
    self.arrSeries = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        Serie *objSerie = [Serie new];
        [objSerie fillDict:videoInfo];
        [self.arrSeries addObject:objSerie];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrSeries waitUntilDone:NO];
}

@end