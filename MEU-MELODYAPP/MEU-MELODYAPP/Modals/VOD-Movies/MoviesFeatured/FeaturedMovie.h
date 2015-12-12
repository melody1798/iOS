//
//  FeaturedMovie.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeaturedMovie : NSObject

@property (strong, nonatomic) NSString*     movieTitle_en;
@property (strong, nonatomic) NSString*     movieTitle_ar;
@property (strong, nonatomic) NSString*     movieUrl;
@property (strong, nonatomic) NSString*     movieThumbnail;
@property (strong, nonatomic) NSString*     movieID;

@property (strong, nonatomic) NSString*     englishTag;
@property (strong, nonatomic) NSString*     arabicTag;

- (void)fillVODMovieFeaturedVideoInfo:(id)info;

@end
