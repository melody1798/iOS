//
//  SeriesEpisodesViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Display episodes under particular series.

#import <UIKit/UIKit.h>

@interface SeriesEpisodesViewController : UIViewController

@property (strong, nonatomic) NSString*     strSeriesId;
@property (strong, nonatomic) NSString*     seriesUrl;
@property (strong, nonatomic) NSString*     seriesName_en;
@property (strong, nonatomic) NSString*     seriesName_ar;

@end
