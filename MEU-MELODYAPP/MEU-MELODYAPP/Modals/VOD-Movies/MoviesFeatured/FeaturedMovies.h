//
//  FeaturedMovies.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeaturedMovies : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrFeaturedMovies;

- (void)fetchFeaturedMovies:(id)target selector:(SEL)selector;

@end
