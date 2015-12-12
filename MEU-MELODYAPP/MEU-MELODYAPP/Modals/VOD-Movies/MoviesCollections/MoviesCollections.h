//
//  MoviesCollections.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoviesCollections : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrMoviesCollections;

- (void)fetchMoviesCollections:(id)target selector:(SEL)selector;
- (void)fetchVODCollections:(id)target selector:(SEL)selector;

@end
