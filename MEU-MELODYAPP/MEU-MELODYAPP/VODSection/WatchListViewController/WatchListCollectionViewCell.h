//
//  WatchListCollectionViewCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 18/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Watchlist custom cells iPad.

#import <UIKit/UIKit.h>
#import "WatchListMovie.h"

@protocol DeleteWatchListDelegate;

@interface WatchListCollectionViewCell : UICollectionViewCell
{
    IBOutlet UIImageView*       imgVwThumb;
    IBOutlet UILabel*           lblMovieName;
    IBOutlet UILabel*           lblEpisodeNum;
}

@property (strong, nonatomic) IBOutlet UIButton*          btnDelete;
@property (weak, nonatomic) id <DeleteWatchListDelegate> delegate;

- (void)setCellValues:(WatchListMovie*)objMoviesCollection;
- (IBAction)btnDeleteAction:(id)sender;

@end

@protocol DeleteWatchListDelegate <NSObject>

- (void)deleteWatchListItem:(int)tag;

@end
