//
//  SeasonsViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
// seasons pop over view controller iPad.

#import <UIKit/UIKit.h>

@protocol SelectedSeasonDelegate;

@interface SeasonsViewController : UIViewController

@property (strong, nonatomic) NSString*     strSeriesId;
@property (strong, nonatomic) NSArray*      arrSeasons;
@property (weak, nonatomic) id <SelectedSeasonDelegate>  delegate;

@end

@protocol SelectedSeasonDelegate <NSObject>
- (void)fetchEpisodesForSelectedSeason:(NSString*)seasonId;
@end
