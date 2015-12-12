//
//  SeriesSeasons.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeriesSeasons : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrSeasons;

- (void)fetchSeriesSeasons:(id)target selector:(SEL)selector  parameter:(NSString*)serieId;

@end
