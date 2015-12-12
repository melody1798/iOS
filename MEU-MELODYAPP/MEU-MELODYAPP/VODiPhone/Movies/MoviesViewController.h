//
//  MoviesViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Show featured movies/ Movies A-Z/ Movies Genres-Movies/Movies collections-Movies.

#import <UIKit/UIKit.h>
@class MoviesDetailViewController;
@class Genres;
@class DetailGenres;
@class VODSegmentControl;

@interface MoviesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    __weak IBOutlet UILabel *lblMovies;
    __weak IBOutlet VODSegmentControl *segmentControl;
    __weak IBOutlet UITableView *tblMovies;
    __weak IBOutlet UITableView *tblGenre;
    __weak IBOutlet UITableView *tblGenreDetail;
    __weak IBOutlet UITableView *tblCollections;
    __weak IBOutlet UICollectionView *collView;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UIView *collParentView;
     UILabel *lblCollectionName;
    MoviesDetailViewController *objMoviesDetailViewController;
    __weak IBOutlet UIView *vwFeatured;
    __weak IBOutlet UIView *vwAToZ;
    __weak IBOutlet UIView *vwGenre;
    __weak IBOutlet UIView *vwCollections;
    __weak IBOutlet UITableView *tblAlphabets;
    NSMutableArray *arrGenreList;
    NSMutableArray *arrAlphabets;
    NSMutableArray *arrAlphabetsForGenre;
    NSMutableArray *arrFeaturedMovies;
    NSMutableArray *arrAtoZMovies;
    NSMutableArray *arrGenres;
    NSMutableArray *arrDetailGenre;
    NSMutableArray *arrMoviesCollections;
    NSMutableArray *arrMoviesInCollection;
    NSMutableArray *arrMovies;
    int lastSelectedIndex;
    int nestedSelectedIndex;
    __weak IBOutlet UILabel *lblNoVideoFound;
    BOOL collectionDetail;
    BOOL genreDetail;
    __weak IBOutlet UIButton*       btnGenre;
}

@end