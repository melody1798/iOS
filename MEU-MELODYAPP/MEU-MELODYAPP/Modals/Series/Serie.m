//
//  Serie.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "Serie.h"
#import "CommonFunctions.h"
@implementation Serie

@synthesize serieId;
@synthesize serieName_en, serieName_ar;
@synthesize serieThumb;

- (void)fillDict:(id)info
{
    serieId = [info objectForKey:@"Id"];
    serieName_en = [info objectForKey:@"EnglishTitle"];
    serieName_ar = [info objectForKey:@"ArabicTitle"];
    serieThumb = [info objectForKey:@"ThumbNail"];
}

@end
