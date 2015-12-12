//
//  WatchListViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Watchlist and lastviewed iPad.

#import <UIKit/UIKit.h>

@protocol FetchMovieDetailFromWatchList;

@interface WatchListViewController : UIViewController

@property (strong, nonatomic) UIImage*      _imgViewBg;
@property (weak, nonatomic) id <FetchMovieDetailFromWatchList> delegate;
@property (assign, nonatomic) BOOL          isFromHome;
@end

@protocol FetchMovieDetailFromWatchList <NSObject>

@optional
- (void)movieDetailFromWatchListPop:(NSString*)movieId;

@end
