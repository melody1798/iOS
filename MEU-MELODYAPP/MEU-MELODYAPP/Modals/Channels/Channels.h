//
//  Channels.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channels : NSObject
{
    id                 _delegate;
    SEL                _eventHandler;
}

@property (strong, nonatomic) NSMutableArray*       arrChannels;

- (void)fetchChannels:(id)target selector:(SEL)selector;
- (void)fetchChannelDetails:(id)target selector:(SEL)selector channelName:(NSString*)channelName isArb:(NSString*)isArb;

@end
