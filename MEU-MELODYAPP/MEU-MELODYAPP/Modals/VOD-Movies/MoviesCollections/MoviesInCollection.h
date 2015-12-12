//
//  MoviesInCollection.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoviesInCollection : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrCollectionMovies;

- (void)fetchCollectionMovies:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;

@end
