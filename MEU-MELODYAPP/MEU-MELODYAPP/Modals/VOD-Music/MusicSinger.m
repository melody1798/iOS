//
//  MusicSinger.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MusicSinger.h"
#import "CommonFunctions.h"

@implementation MusicSinger

@synthesize musicVideoId, musicVideoName_en, musicVideoName_ar, musicVideoThumb, musicVideoUrl;
@synthesize singerName_en, singerName_ar;

- (void)fillMusicSingers:(id)info
{
    musicVideoId = [info objectForKey:@"Id"];
    musicVideoName_en = [info objectForKey:@"EnglishTitle"];
    musicVideoName_ar = [info objectForKey:@"ArabicTitle"];
   
    if ([info objectForKey:@"ArtistEnglishName"] != [NSNull null])
        
        singerName_en = [info objectForKey:@"ArtistEnglishName"];
    else
        singerName_en = @"";
    
    if ([info objectForKey:@"ArtistArabicName"] != [NSNull null])
        singerName_ar = [info objectForKey:@"ArtistArabicName"];
    else
        singerName_ar = @"";
    
    musicVideoThumb = [info objectForKey:@"ThumbNail"];
    musicVideoUrl = [info objectForKey:@"MovieUrl"];
}

@end