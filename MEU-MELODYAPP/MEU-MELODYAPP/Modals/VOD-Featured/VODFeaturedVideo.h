//
//  VODFeaturedVideo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VODFeaturedVideo : NSObject

@property (strong, nonatomic) NSString*     movieTitle_en;
@property (strong, nonatomic) NSString*     movieTitle_ar;
@property (strong, nonatomic) NSString*     movieUrl;
@property (strong, nonatomic) NSString*     movieThumbnail;
@property (strong, nonatomic) NSString*     movieID;
@property (strong, nonatomic) NSString*     movieTag;
@property (strong, nonatomic) NSString*     videoType;
@property (strong, nonatomic) NSString*     seriesId;
@property (strong, nonatomic) NSString*     seasonNum;
@property (strong, nonatomic) NSString*     artistName_en;
@property (strong, nonatomic) NSString*     artistName_ar;
@property (strong, nonatomic) NSString*     seriesName_en;
@property (strong, nonatomic) NSString*     seriesName_ar;
@property (strong, nonatomic) NSString*     episodeNum;
@property (assign, nonatomic) NSInteger     numberOfSeasons;

- (void)fillVODFeaturedVideoInfo:(id)info;

@end
