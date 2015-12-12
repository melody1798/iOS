//
//  FeaturedMusics.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeaturedMusics : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrFeaturedMusicVideos;

- (void)fetchFeaturedMusicVideos:(id)target selector:(SEL)selector;

@end
