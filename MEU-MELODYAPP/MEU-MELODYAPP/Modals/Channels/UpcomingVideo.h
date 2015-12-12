//
//  UpcomingVideo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpcomingVideo : NSObject

@property (strong, nonatomic) NSString*         upcomingVideoName_en;
@property (strong, nonatomic) NSString*         upcomingVideoName_ar;
@property (strong, nonatomic) NSString*         upcomingVideoTime;
@property (strong, nonatomic) NSString*         upcomingVideoId;
@property (strong, nonatomic) NSString*         upcomingVideoUrl;
@property (strong, nonatomic) NSString*         upcomingVideoThumbnail;
@property (strong, nonatomic) NSString*         upcomingDay;

- (void)fillChannelInfo:(id)info;

@end
