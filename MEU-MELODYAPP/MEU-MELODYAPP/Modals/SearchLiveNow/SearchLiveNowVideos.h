//
//  SearchLiveNowVideos.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchLiveNowVideos : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrSearchVideos;

- (void)searchChannelsLiveNow:(id)target selector:(SEL)selector channelName:(NSString*)channelName isArb:(NSString*)isArb;

- (void)searchChannelsUpcoming:(id)target selector:(SEL)selector channelName:(NSString*)channelName isArb:(NSString*)isArb;

- (void)searchVOD:(id)target selector:(SEL)selector movieName:(NSString*)movieName isArb:(NSString*)isArb;

@end
