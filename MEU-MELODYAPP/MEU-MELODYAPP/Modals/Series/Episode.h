//
//  Episode.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Episode : NSObject

@property (strong, nonatomic) NSString*         episodeThumb;
@property (strong, nonatomic) NSString*         episodeName_en;
@property (strong, nonatomic) NSString*         episodeName_ar;
@property (strong, nonatomic) NSString*         episodeId;
@property (strong, nonatomic) NSString*         episodeUrl;
@property (strong, nonatomic) NSString*         episodeDesc_en;
@property (strong, nonatomic) NSString*         episodeDesc_ar;
@property (strong, nonatomic) NSString*         episodeDuration;
@property (strong, nonatomic) NSString*         episodeNum;
@property (strong, nonatomic) NSString*         seasonNum;
@property (strong, nonatomic) NSString*         seriesID;

@property (strong, nonatomic) NSString*         seriesName_en;
@property (strong, nonatomic) NSString*         seriesName_ar;
@property (strong, nonatomic) NSString*         seriesDesc_en;
@property (strong, nonatomic) NSString*         seriesDesc_ar;
@property (assign, nonatomic) NSInteger         seriesSeasonsCount;
@property (assign, nonatomic) NSInteger         seriesThumbnail;

@property (assign, nonatomic) BOOL              bIsExistsInWatchList;

@property (strong, nonatomic) NSMutableArray*       arrCastAndCrew;
@property (strong, nonatomic) NSMutableArray*       arrProducers;

- (void)fillDict:(id)info;

@end