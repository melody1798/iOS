//
//  AtoZMovie.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "AtoZMovie.h"
#import "CommonFunctions.h"

@implementation AtoZMovie

@synthesize movieName_eniPhone;
@synthesize movieName_en;
@synthesize movieName_ar;
@synthesize movieUrl;
@synthesize movieId;
@synthesize movieThumbNail;
@synthesize movieGenre_en;
@synthesize movieGenre_ar;
@synthesize movieDuration;

- (void)fillAtoZMovieInfo:(id)info
{
    movieName_en = [info objectForKey:@"EnglishTitle"];
    movieName_eniPhone = [info objectForKey:@"EnglishTitle"];
    movieName_ar = [info objectForKey:@"ArabicTitle"];
    movieUrl = [info objectForKey:@"MovieUrl"];
    movieId = [info objectForKey:@"Id"];
    movieThumbNail = [info objectForKey:@"ThumbNail"];
    
    movieDuration = [info objectForKey:@"Duration"];

    if ([info objectForKey:@"Duration"]  == (id)[NSNull null]) {
        movieDuration = @"";
    }
    
    if ([[info objectForKey:@"CustomeGenre"] count] != 0) {
        movieGenre_en = [CommonFunctions isEnglish]?[[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"EnglishName"]:[[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"ArabicName"];
        
        movieGenre_ar = [[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"ArabicName"];
        
        if ([[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"EnglishName"] == (id)[NSNull null])
            movieGenre_en = @"";
        if ([[[info objectForKey:@"CustomeGenre"] objectAtIndex:0] objectForKey:@"ArabicName"] == (id)[NSNull null])
            
            movieGenre_ar = @"";
    }
    else{
        movieGenre_en = @"";
        movieGenre_ar = @"";
    }
}

@end