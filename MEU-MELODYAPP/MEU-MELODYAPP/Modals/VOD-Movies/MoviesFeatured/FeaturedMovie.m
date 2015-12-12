//
//  FeaturedMovie.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FeaturedMovie.h"
#import "CommonFunctions.h"
@implementation FeaturedMovie

@synthesize movieTitle_en, movieTitle_ar,englishTag,arabicTag;
@synthesize movieThumbnail, movieUrl;
@synthesize movieID;

- (void)fillVODMovieFeaturedVideoInfo:(id)info
{
    movieTitle_en = [info objectForKey:@"EnglishTitle"];
    movieTitle_ar = [info objectForKey:@"ArabicTitle"];
    movieThumbnail = [info objectForKey:@"ThumbNail"];
    movieUrl = [info objectForKey:@"MovieUrl"];
    movieID = [info objectForKey:@"Id"];
    englishTag = [CommonFunctions isEnglish]?[info objectForKey:@"EnglishTag"]:[info objectForKey:@"ArabicTag"];
    arabicTag = [info objectForKey:@"ArabicTag"];
}

@end
