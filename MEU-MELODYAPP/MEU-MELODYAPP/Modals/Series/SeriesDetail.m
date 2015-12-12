//
//  SeriesDetail.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesDetail.h"
#import "ServerConnection.h"
#import "RequestBuilder.h"
#import "DetailArtist.h"

typedef enum {
    Actor = 1,
    Producer = 2,
    Supporting = 3,
    Singer = 4
} ArtistRole;

@implementation SeriesDetail

@synthesize arrSeriesCastAndCrew, arrSeriesProducers;
@synthesize seriesId;
@synthesize seriesName;
@synthesize seriesDesc;
@synthesize seriesThumbUrl;
@synthesize seasonNum;
@synthesize episodeNum;

- (void)fetchSeriesDetail:(id)target selector:(SEL)selector parameter:(NSString*)seriesid
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?seriesId=%@", kBaseUrl, kSeriesDetail, seriesid]];
    
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

- (void)fillDict:(NSDictionary*)dictResponse
{
    seriesId = [dictResponse objectForKey:@"Id"];
    if ([dictResponse objectForKey:@"EnglishTitle"] != [NSNull null])
        self.seriesName_en =  [dictResponse objectForKey:@"EnglishTitle"];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        self.seriesName =  [dictResponse objectForKey:@"EnglishTitle"];
        self.seriesDesc = [dictResponse objectForKey:@"EnglishDescription"];

        if ([dictResponse objectForKey:@"EnglishDescription"] == [NSNull null])
            self.seriesDesc = @"";
    }
    else{
        self.seriesName = ([dictResponse objectForKey:@"ArabicTitle"] != [NSNull null])?[dictResponse objectForKey:@"ArabicTitle"]:@"";
        
        self.seriesDesc = ([dictResponse objectForKey:@"ArabicDescription"] != [NSNull null])?[dictResponse objectForKey:@"ArabicDescription"]:@"";
    }
    
    self.seriesThumbUrl = [dictResponse objectForKey:@"ThumbNail"];
    self.seasonNum = [dictResponse objectForKey:@""];
    self.episodeNum = [dictResponse objectForKey:@""];

    self.arrSeriesCastAndCrew = [[NSMutableArray alloc] init];
    self.arrSeriesProducers = [[NSMutableArray alloc] init];
    
    if ([dictResponse objectForKey:@"CastAndCrew"] != [NSNull null])
    {
        for (int i = 0; i < [[dictResponse objectForKey:@"CastAndCrew"] count]; i++){
            DetailArtist *objDetailArtist = [DetailArtist new];
            objDetailArtist.artistName_en = [[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistEnglishName"];
            objDetailArtist.artistName_ar = [[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistArabicName"];
            
            objDetailArtist.artistRole_en = [[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"EnglishRoleName"];
            objDetailArtist.artistRole_ar = [[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArabicRoleName"];
            objDetailArtist.artistRoleId = [[[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistRole"] stringValue];
            if ([[[[dictResponse objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistRole"] integerValue] == Producer)
                [arrSeriesProducers addObject:objDetailArtist];
            else
                [arrSeriesCastAndCrew addObject:objDetailArtist];
        }
    }
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self waitUntilDone:NO];
}

@end