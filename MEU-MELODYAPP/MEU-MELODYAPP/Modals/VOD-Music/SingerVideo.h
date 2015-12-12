//
//  SingerVideo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingerVideo : NSObject

@property (strong, nonatomic) NSString*     movieName_en;
@property (strong, nonatomic) NSString*     movieName_ar;
@property (strong, nonatomic) NSString*     movieThumb;
@property (strong, nonatomic) NSString*     movieUrl;
@property (strong, nonatomic) NSString*     movieID;

- (void)fillSingerVideos:(id)info;

@end
