//
//  AtoZMovies.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "AtoZMovies.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "AtoZMovie.h"

@implementation AtoZMovies

- (void)fetchAtoZMovies:(id)target selector:(SEL)selector
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@&country=%@", kBaseUrl, kVODMoviesAtoZService, [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]?@"true":@"false", [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    
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
    self.arrAtoZMovies = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
         AtoZMovie *objAtoZMovie = [AtoZMovie new];
        [objAtoZMovie fillAtoZMovieInfo:videoInfo];
        [self.arrAtoZMovies addObject:objAtoZMovie];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrAtoZMovies waitUntilDone:NO];
}

@end