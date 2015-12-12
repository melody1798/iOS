//
//  UpcomingVideos.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpcomingVideos : NSObject
{
    id                 _delegate;
    SEL                _eventHandler;
}

@property (strong, nonatomic) NSMutableArray*       arrUpcomingVideos;

@property (strong, nonatomic) NSString*         liveVideoName_en;
@property (strong, nonatomic) NSString*         liveVideoName_ar;
@property (strong, nonatomic) NSString*         liveVideoStartTime;
@property (strong, nonatomic) NSString*         liveVideoThumbnail;
@property (strong, nonatomic) NSString*         channelLogoUrl;
@property (strong, nonatomic) NSString*         liveChannelUrl;

- (void)fetchChannelUpcomingVideos:(id)target selector:(SEL)selector channelName:(NSString*)channelName;

@end
