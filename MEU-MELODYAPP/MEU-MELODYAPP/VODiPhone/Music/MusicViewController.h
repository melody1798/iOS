//
//  MusicViewController.h
//  MEU-MELODYAPP
//
//  Created by Channi on 8/20/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Set music videos/ Music A-Z/ Music genres-music videos.

#import <UIKit/UIKit.h>

@interface MusicViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UICollectionView *collView;
    __weak IBOutlet UILabel *lblMusicName;
    __weak IBOutlet UISegmentedControl *segmentControl;
    __weak IBOutlet UITableView *tblMusic;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UILabel *lblNoRecordFound;
    NSArray *arrFeaturedMusicVideos;
    NSMutableArray *arrMusicSingers;
    NSArray *arrGenres;
    NSMutableArray *arrGenreDetail;
    NSMutableArray *arrAlphabetsForGenre;
    NSMutableArray *arrSingerVideos;
    NSMutableArray *arrAlphabets;
    int isGenreDetail;
    BOOL singerDetail;

}
- (IBAction)segmentedIndexChanged;
@end
