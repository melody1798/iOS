//
//  SeriesSeasons.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesSeasons.h"
#import "ServerConnection.h"
#import "RequestBuilder.h"
#import "SeriesSeason.h"
#import "CommonFunctions.h"

@implementation SeriesSeasons

- (void)fetchSeriesSeasons:(id)target selector:(SEL)selector  parameter:(NSString*)serieId
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?seriesId=%@", kBaseUrl, kSeriesSeasons, serieId]];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverSerieSeasonResponse:)];
}

- (void)serverSerieSeasonResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
       /* if (![CommonFunctions isIphone]) {
            NSMutableArray *arrSeasons = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in [responseDict objectForKey:@"Response"]) {
                
                [arrSeasons addObject:[dict objectForKey:@"SeasonNumber"]];
            }
            
            [self fillDict:arrSeasons];
        }
        else
        {  */
            NSArray *arrResponse = [responseDict objectForKey:@"Response"];
            
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"NoofEpisodes" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSArray *sortedArray = [arrResponse sortedArrayUsingDescriptors:sortDescriptors];
            
            [self fillDictIphone:sortedArray];
      //  }
    }
}

- (void)fillDict:(NSArray*)arrResponse
{
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
    NSArray *arr = [arrResponse sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    self.arrSeasons = [NSMutableArray new];
    for (NSString *seasonNum in arr) {
        SeriesSeason *objSeriesSeason = [SeriesSeason new];
        [objSeriesSeason fillValues:seasonNum];
        [self.arrSeasons addObject:objSeriesSeason];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrSeasons waitUntilDone:NO];
}

- (void)fillDictIphone:(NSArray*)arrResponse
{
    self.arrSeasons = [NSMutableArray new];
    for (NSDictionary *seasonDict in arrResponse) {
        SeriesSeason *objSeriesSeason = [SeriesSeason new];
        [objSeriesSeason fillValues:[seasonDict objectForKey:@"SeasonNumber"]];
        [self.arrSeasons addObject:objSeriesSeason];
    }
    
    //Fill UIView.
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrSeasons waitUntilDone:NO];
}

@end