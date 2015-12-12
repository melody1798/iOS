//
//  MusicViewController.h
//  MEU-MELODYAPP
//
//  Created by Channi on 8/20/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//List all Series/Featured episodes/genres-series genres.

#import <UIKit/UIKit.h>

@interface SeriesViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
{
    __weak IBOutlet UICollectionView *collView;
    __weak IBOutlet UILabel *lblMusicName;
    __weak IBOutlet UISegmentedControl *segmentControl;
    __weak IBOutlet UIImageView *imgSeries;
    __weak IBOutlet UILabel *lblSeriesName;
    __weak IBOutlet UILabel *lblSelectSeason;
    __weak IBOutlet UILabel *lblNoRecordFound;
    __weak IBOutlet UIView *vwSeriesDetail;
    __weak IBOutlet UITableView *tblSeries;
    __weak IBOutlet UIButton *btnSelectSeason;
    __weak IBOutlet UIView *headerView;
    NSArray *arrSeries;
    NSArray *arrEpisodes;
    NSArray *arrGenres;
    NSMutableArray *arrGenreDetail;
    NSMutableArray *arrAlphabetsForGenre;
    NSArray *arrSeriesEpisodes;
    int isGenreDetail;
    BOOL seriesDetailPage;
    BOOL genreDetailPage;
    BOOL genreSubDetailPage;
    NSArray *arrSeasons;
    UIPickerView *pckVw;
    NSString *seriesName;
    NSString *serieId;
    
    int nestedSlctdIndex;
}

- (IBAction)segmentedIndexChanged;
@end
