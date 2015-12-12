//
//  WatchListMovies.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "WatchListMovies.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "WatchListMovie.h"
#import "NSIUtility.h"
#import "CommonFunctions.h"

@implementation WatchListMovies

@synthesize arrWatchListMovies;

- (void)saveMovieToWatchList:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@", kBaseUrl, kWatchListSave, isArb];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseAddToWatchList:)];
}

- (void)serverResponseAddToWatchList:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
      //  [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"added to watchlist" value:@"" table:nil]];
    }
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
}

- (void)fetchWatchList:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";

    NSString *strUrl = [NSString stringWithFormat:@"%@%@?userId=%@&isArb=%@", kBaseUrl, kWatchListFetch, [requestParameters objectForKey:@"userId"], isArb];
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

- (void)deleteWatchListItem:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kBaseUrl, kWatchListDelete];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseDeleteWatchListItem:)];
}

- (void)serverResponseDeleteWatchListItem:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
}

- (void)serverResponse:(NSMutableData*)responseData
{
    arrWatchListMovies = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
        for (id videoInfo in [responseDict objectForKey:@"Response"]) {
            
            WatchListMovie *objWatchListMovie = [WatchListMovie new];
            [objWatchListMovie fillDict:videoInfo];
            [arrWatchListMovies addObject:objWatchListMovie];
        }
    }
    [_delegate performSelectorOnMainThread:_eventHandler withObject:arrWatchListMovies waitUntilDone:NO];
}

#pragma mark - Last Viewed Methods

- (void)saveMovieToLastViewed:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters{
    
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kBaseUrl, kLastViewedSave];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:strUrl];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponseAddToLastViewed:)];
}

- (void)serverResponseAddToLastViewed:(NSMutableData*)responseData
{
   //  NSError *error;
    
    //Convert response data into JSON format.
//    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
//    DLog(@"%@", responseDict);
    if(_eventHandler!= Nil)
        [_delegate performSelectorOnMainThread:_eventHandler withObject:arrWatchListMovies waitUntilDone:NO];
}

@end