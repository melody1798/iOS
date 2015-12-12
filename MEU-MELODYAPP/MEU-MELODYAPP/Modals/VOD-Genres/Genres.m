//
//  Genres.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Genres.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "Constant.h"
#import "Genre.h"

@implementation Genres

- (void)fetchGenres:(id)target selector:(SEL)selector methodName:(NSString*) strSectionType
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *isArb;
    NSString *strUrl;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        isArb = @"false";

    else
        isArb = @"true";

    if ([strSectionType isEqualToString:@"movies"]) {
        strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@&Country=%@", kBaseUrl, kVODMoviesGenresService, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    else if ([strSectionType isEqualToString:@"series"]) {
        strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@&Country=%@", kBaseUrl, kSeriesGenres, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    else{
        strUrl = [NSString stringWithFormat:@"%@%@?isArb=%@&Country=%@", kBaseUrl, kVODMusicGenre, isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    }
    
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    
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
    self.arrGenres = [NSMutableArray new];
    for (id genreInfo in arrResponse) {
        Genre *objGenre = [Genre new];
        [objGenre fillGenreInfo:genreInfo];
        [self.arrGenres addObject:objGenre];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrGenres waitUntilDone:NO];
}

@end