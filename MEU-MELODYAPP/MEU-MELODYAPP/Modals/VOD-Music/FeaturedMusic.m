//
//  FeaturedMusic.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FeaturedMusic.h"
#import "CommonFunctions.h"
@implementation FeaturedMusic

@synthesize musicTitle_en, musicTitle_ar;
@synthesize musicThumbnail, musicUrl;
@synthesize musicId;
@synthesize singerName_en, singerName_ar;

- (void)fillVODMusicFeaturedVideoInfo:(id)info
{
    musicTitle_en = [info objectForKey:@"EnglishTitle"];
    musicTitle_ar = [info objectForKey:@"ArabicTitle"];
    musicThumbnail = [info objectForKey:@"ThumbNail"];
    musicUrl = [info objectForKey:@"MovieUrl"];
    musicId = [info objectForKey:@"Id"];
    
    if ([info objectForKey:@"ArtistEnglishName"] != (id) [NSNull null])
        singerName_en = [info objectForKey:@"ArtistEnglishName"];
    
    if ([info objectForKey:@"ArtistArabicName"] != (id) [NSNull null])
        singerName_ar = [info objectForKey:@"ArtistArabicName"];
}

@end