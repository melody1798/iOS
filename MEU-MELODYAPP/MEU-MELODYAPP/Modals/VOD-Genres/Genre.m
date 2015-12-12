//
//  Genre.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Genre.h"
#import "CommonFunctions.h"
@implementation Genre

@synthesize genreId;
@synthesize genreName_en, genreName_ar;

-(void)fillGenreInfo:(id)info
{
    genreId = [info objectForKey:@"GenereId"];
    genreName_en = [info objectForKey:@"EnglishName"];
    genreName_ar = [info objectForKey:@"ArabicName"];
}

@end