//
//  LiveNowFeaturedVideos.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveNowFeaturedVideos : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrLiveFeaturedVideos;

- (void)fetchLiveFeaturedVideos:(id)target selector:(SEL)selector;
- (void)fetchLiveMovies:(id)target selector:(SEL)selector;

@end
