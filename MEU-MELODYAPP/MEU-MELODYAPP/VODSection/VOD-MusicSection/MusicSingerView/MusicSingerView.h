//
//  MusicSingerView.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Show music A-Z in iPad.

#import <UIKit/UIKit.h>
#import "MusicSingers.h"

@protocol musicSingerSelectionDelegate;

@interface MusicSingerView : UIView <UITableViewDataSource, UITableViewDelegate>
{
   // IBOutlet UICollectionView*      collectionVw;
    IBOutlet UITableView*           tblVw;
}

@property (weak, nonatomic) IBOutlet UILabel*       lblNoVideoFoundText;
@property (weak, nonatomic) id <musicSingerSelectionDelegate> delegate;
@property (strong, nonatomic) NSMutableArray*              arrMusicSingers;
@property (strong, nonatomic) NSMutableArray*            arrAlphabets;

+ (id)customView;
//- (void)registerCollectionViewCell;
- (void)fetchMusicSingers;
- (void)reloadSingersTableView;
- (void)fetchMusicSingersAfterLanguageChange;

@end

@protocol musicSingerSelectionDelegate <NSObject>

- (void)musicSingerSelected:(NSString*)singerId singerName_en:(NSString*)singerName_en singerName_ar:(NSString*)singerName_ar;

@end
