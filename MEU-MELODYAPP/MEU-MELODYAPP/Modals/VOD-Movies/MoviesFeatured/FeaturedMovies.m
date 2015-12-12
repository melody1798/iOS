//
//  FeaturedMovies.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FeaturedMovies.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "FeaturedMovie.h"
#import "CommonFunctions.h"

@implementation FeaturedMovies

- (void)fetchFeaturedMovies:(id)target selector:(SEL)selector 
{
    _delegate = target;
    _eventHandler = selector;
    
  //  NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kVODMoviesFeaturedService, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]]];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?Country=%@", kBaseUrl, kVODMoviesFeaturedService, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Write in file
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
        
        if ([responseDict objectForKey:@"Response"] != (id) [NSNull null]) {
            [self fillDict:[responseDict objectForKey:@"Response"]];
        }
    }
    else
        [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrFeaturedMovies waitUntilDone:NO];
}

- (void)fillDict:(NSArray*)arrResponse
{
       self.arrFeaturedMovies = [NSMutableArray new];
       for (id videoInfo in arrResponse) {
         FeaturedMovie *objFeaturedMovie = [FeaturedMovie new];
           [objFeaturedMovie fillVODMovieFeaturedVideoInfo:videoInfo];
          [self.arrFeaturedMovies addObject:objFeaturedMovie];
     }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrFeaturedMovies waitUntilDone:NO];
}

@end