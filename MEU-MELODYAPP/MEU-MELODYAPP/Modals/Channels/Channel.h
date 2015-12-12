//
//  Channel.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (strong, nonatomic) NSString*     channelName_en;
@property (strong, nonatomic) NSString*     channelName_ar;
@property (strong, nonatomic) NSString*     channelLogoUrl;
@property (strong, nonatomic) NSString*     channelId;
@property (strong, nonatomic) NSString*     channelLiveNowVideoName_en;
@property (strong, nonatomic) NSString*     channelLiveNowVideoName_ar;
@property (strong, nonatomic) NSString*     channelLiveNowVideoTime;
@property (strong, nonatomic) NSString*     channelLiveNowVideoUrl;


- (void)fillChannelInfo:(id)info;

@end
