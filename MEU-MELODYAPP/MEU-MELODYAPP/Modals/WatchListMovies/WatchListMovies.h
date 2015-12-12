//
//  WatchListMovies.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatchListMovies : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (strong, nonatomic) NSMutableArray*       arrWatchListMovies;

- (void)saveMovieToWatchList:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters;
- (void)fetchWatchList:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters;
- (void)deleteWatchListItem:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters;

- (void)saveMovieToLastViewed:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters;

@end
