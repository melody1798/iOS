//
//  MusicSingers.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicSingers.h"

@interface MusicSingers : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrMusicSingers;

- (void)fetchMusicSingers:(id)target selector:(SEL)selector;

@end
