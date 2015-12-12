//
//  DetailGenre.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailGenre : NSObject

@property (strong, nonatomic) NSString*     movieTitle_en;
@property (strong, nonatomic) NSString*     movieTitle_ar;
@property (strong, nonatomic) NSString*     movieUrl;
@property (strong, nonatomic) NSString*     movieID;
@property (strong, nonatomic) NSString*     movieGenre_en;
@property (strong, nonatomic) NSString*     movieGenre_ar;
@property (strong, nonatomic) NSString*     movieThumbnail;
@property (strong, nonatomic) NSString*     movieDuration;
@property (strong, nonatomic) NSString*     musicVideoSingerName_en;
@property (strong, nonatomic) NSString*     musicVideoSingerName_ar;
@property (assign, nonatomic) NSInteger     videoType;

- (void)fillGenreDetailInfo:(id)info;

@end
