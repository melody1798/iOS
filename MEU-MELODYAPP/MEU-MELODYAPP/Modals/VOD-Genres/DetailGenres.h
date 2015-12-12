//
//  DetailGenres.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailGenres : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
    NSString*         strGenreType;
}

@property (retain, nonatomic) NSMutableArray*   arrGenreDetails;

- (void)fetchGenreDetails:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters genreType:(NSString*)genreType;

@end
