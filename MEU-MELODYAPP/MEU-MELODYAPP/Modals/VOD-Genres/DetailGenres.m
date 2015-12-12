//
//  DetailGenres.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "DetailGenres.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "DetailGenre.h"
#import "Serie.h"

@implementation DetailGenres

@synthesize arrGenreDetails;

- (void)fetchGenreDetails:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters genreType:(NSString*)genreType
{
    _delegate = target;
    _eventHandler = selector;
    strGenreType = genreType;
    
    NSString *strUrl;
    
    NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";
    
    if ([genreType isEqualToString:@"series"])
        strUrl =[NSString stringWithFormat:@"%@%@?GenereId=%@&isArb=%@&Country=%@", kBaseUrl, kSeriesGenresDetail, [requestParameters objectForKey:@"GenereId"], isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    else
        strUrl =[NSString stringWithFormat:@"%@%@?GenereId=%@&isArb=%@&Country=%@", kBaseUrl, kVODMoviesGenresDetailsService, [requestParameters objectForKey:@"GenereId"], isArb, [[NSUserDefaults standardUserDefaults] objectForKey:@"country"]];
    
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
    self.arrGenreDetails = [NSMutableArray new];
    
    if ([strGenreType isEqualToString:@"series"])
    {
        for (id videoInfo in arrResponse) {
            Serie *objSerie = [Serie new];
            [objSerie fillDict:videoInfo];
            [self.arrGenreDetails addObject:objSerie];
        }
    }
    else{
        for (id videoInfo in arrResponse) {
            DetailGenre *objDetailGenre = [DetailGenre new];
            [objDetailGenre fillGenreDetailInfo:videoInfo];
            [self.arrGenreDetails addObject:objDetailGenre];
        }
    }
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrGenreDetails waitUntilDone:NO];
}

@end