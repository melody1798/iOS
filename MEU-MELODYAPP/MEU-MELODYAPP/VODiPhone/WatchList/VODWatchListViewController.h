//
//  VODWatchListViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Show watchlist videos and last viewed videos.

#import <UIKit/UIKit.h>

@interface VODWatchListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UILabel *lblWatchlist;
    __weak IBOutlet UITableView *tblWatchlist;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UILabel *lblWatchListHeader;
    NSMutableArray *arrLastViewedMovies;
    NSMutableArray *arrWatchList;
    int numberOfSections;
}
@end
