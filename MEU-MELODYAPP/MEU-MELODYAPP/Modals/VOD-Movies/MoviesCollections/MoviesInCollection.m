//
//  MoviesInCollection.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MoviesInCollection.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "MovieInCollection.h"

@implementation MoviesInCollection

@synthesize arrCollectionMovies;

- (void)fetchCollectionMovies:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
   // NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?collectionId=%@&Country=%@", kBaseUrl, kVODMoviesCollectionMoviesList, [requestParameters objectForKey:@"collectionId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]]];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?collectionId=%@&Country=%@", kBaseUrl, kVODMoviesCollectionMoviesList, [requestParameters objectForKey:@"collectionId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
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
    self.arrCollectionMovies = [NSMutableArray new];
    for (id videoInfo in arrResponse) {
        MovieInCollection *objMovieInCollection = [MovieInCollection new];
        [objMovieInCollection fillCollectionMovieInfo:videoInfo];
        [self.arrCollectionMovies addObject:objMovieInCollection];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrCollectionMovies waitUntilDone:NO];
}

@end