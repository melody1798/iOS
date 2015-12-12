//
//  SeriesDetail.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeriesDetail : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrSeriesCastAndCrew;
@property (retain, nonatomic) NSMutableArray*   arrSeriesProducers;
@property (retain, nonatomic) NSString*         seriesId;
@property (retain, nonatomic) NSString*         seriesName;
@property (retain, nonatomic) NSString*         seriesDesc;
@property (retain, nonatomic) NSString*         seriesThumbUrl;
@property (retain, nonatomic) NSString*         seasonNum;
@property (retain, nonatomic) NSString*         episodeNum;
@property (retain, nonatomic) NSString*         seriesName_en;

- (void)fetchSeriesDetail:(id)target selector:(SEL)selector parameter:(NSString*)seriesId;


@end
