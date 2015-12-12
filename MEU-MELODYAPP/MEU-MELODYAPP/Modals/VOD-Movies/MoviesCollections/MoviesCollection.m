//
//  MoviesCollection.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MoviesCollection.h"
#import "CommonFunctions.h"
@implementation MoviesCollection

@synthesize collectionId;
@synthesize collectionName_en, collectionName_ar, collectionThumb, collectionName;

- (void)fillCollectionDetail:(id)info
{
    collectionId = [info objectForKey:@"CollectoinId"];
    collectionName = [info objectForKey:@"EnglishName"];
    collectionName_en = [info objectForKey:@"EnglishName"];
    collectionName_ar = [info objectForKey:@"ArabicName"];
    collectionThumb = [info objectForKey:@"ThumbNail"];
}

@end
