//
//  SingerVideos.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingerVideos : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrSingerVideos;

- (void)fetchSingerVideos:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;

@end
