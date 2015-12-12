//
//  MovieInCollection.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MovieInCollection.h"
#import "CommonFunctions.h"

@implementation MovieInCollection

@synthesize movieName_en, movieName_ar;
@synthesize thumbUrl;
@synthesize movieID;
@synthesize isSeries;
@synthesize movieType;
@synthesize singerName_en, singerName_ar;
@synthesize movieUrl;

- (void)fillCollectionMovieInfo:(id)info
{
    movieName_en = [info objectForKey:@"EnglishTitle"];
    movieName_ar = [info objectForKey:@"ArabicTitle"];
    thumbUrl = [info objectForKey:@"ThumbNail"];
    movieID = [info objectForKey:@"Id"];
    isSeries = [[info objectForKey:@"IsSeries"] boolValue];
    movieUrl = [info objectForKey:@"VideoType"] == (id)[NSNull null]?@"":[info objectForKey:@"MovieUrl"];
    
    if (isSeries) {
        movieID = [info objectForKey:@"Id"];
    }
    
    if ([info objectForKey:@"VideoType"] == (id)[NSNull null])
        movieType = 0;
    else
    {
        movieType = [[info objectForKey:@"VideoType"] integerValue];
        if (movieType == 2) {
            
            singerName_en = [info objectForKey:@"ArtistEnglishName"];
            singerName_ar = [info objectForKey:@"ArtistArabicName"];
            
//            for (int i = 0; i < [[info objectForKey:@"CastAndCrew"] count]; i++) {
//                if ([[[[info objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistRole"] integerValue] == 4) {
//                    
//                    singerName_en = [[[info objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistEnglishName"];
//                    singerName_ar = [[[info objectForKey:@"CastAndCrew"] objectAtIndex:i] objectForKey:@"ArtistArabicName"];
//                }
//            }
        }
    }
}

@end