//
//  LiveNowFeaturedVideo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveNowFeaturedVideo : NSObject

@property (retain, nonatomic) NSString*     videoName_en;
@property (retain, nonatomic) NSString*     videoThumbnailUrl_en;
@property (retain, nonatomic) NSString*     videoTime_en;
@property (retain, nonatomic) NSString*     videoName_ar;
@property (retain, nonatomic) NSString*     videoThumbnailUrl_ar;
@property (retain, nonatomic) NSString*     videoUrl;

@property (retain, nonatomic) NSString*     channelLogoUrl;
@property (retain, nonatomic) NSString*     startTime;

- (void)fillLiveFeaturedVideoInfo:(id)info;

@end
