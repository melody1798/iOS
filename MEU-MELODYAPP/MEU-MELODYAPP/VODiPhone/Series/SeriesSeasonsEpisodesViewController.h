//
//  SeriesSeasonsEpisodesViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/11/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Set series episodes according to seasons.

#import <UIKit/UIKit.h>

@interface SeriesSeasonsEpisodesViewController : UIViewController

@property (strong, nonatomic) NSString* strSeriesId;
@property (strong, nonatomic) NSString* seriesUrl;
@property (strong, nonatomic) NSString* seriesName_en;
@property (strong, nonatomic) NSString* seriesName_ar;
@property (assign, nonatomic) BOOL      isFromCollection;
@property (assign, nonatomic) BOOL      isFromSearch;

@end
