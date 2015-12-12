//
//  FeaturedMusic.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeaturedMusic : NSObject

@property (strong, nonatomic) NSString*     musicTitle_en;
@property (strong, nonatomic) NSString*     musicTitle_ar;
@property (strong, nonatomic) NSString*     musicUrl;
@property (strong, nonatomic) NSString*     musicThumbnail;
@property (strong, nonatomic) NSString*     musicId;
@property (strong, nonatomic) NSString*     singerName_en;
@property (strong, nonatomic) NSString*     singerName_ar;

- (void)fillVODMusicFeaturedVideoInfo:(id)info;

@end
