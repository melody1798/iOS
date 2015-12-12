//
//  Episodes.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Episodes : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*       arrEpisodes;

- (void)fetchFeaturedEpisodes:(id)target selector:(SEL)selector userId:(NSString*)userId;
- (void)fetchSeriesEpisodes:(id)target selector:(SEL)selector  parameter:(NSString*)serieId userID:(NSString*)userId;
- (void)fetchSeriesSeasonalEpisodes:(id)target selector:(SEL)selector  parameter:(NSString*)serieId seasonId:(NSString*)seasonId userID:(NSString*)userId;

@end
