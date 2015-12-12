//
//  MusicSinger.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicSinger : NSObject

//@property (strong, nonatomic) NSString*     singerId;
@property (strong, nonatomic) NSString*     singerName_en;
@property (strong, nonatomic) NSString*     singerName_ar;
//@property (strong, nonatomic) NSString*     singerThumb;
@property (strong, nonatomic) NSString*     musicVideoId;
@property (strong, nonatomic) NSString*     musicVideoName_en;
@property (strong, nonatomic) NSString*     musicVideoName_ar;
@property (strong, nonatomic) NSString*     musicVideoThumb;
@property (strong, nonatomic) NSString*     musicVideoUrl;

- (void)fillMusicSingers:(id)info;

@end
