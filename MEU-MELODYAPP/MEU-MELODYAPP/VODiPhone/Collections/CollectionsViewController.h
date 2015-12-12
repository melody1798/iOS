//
//  CollectionsViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 21/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Show collections in VOD section and videos in collections.

#import <UIKit/UIKit.h>

@interface CollectionsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    __weak IBOutlet UITableView *tblCollections;
    __weak IBOutlet UICollectionView *collVw;
    __weak IBOutlet UIView *vwheader;
    __weak IBOutlet UILabel *lblHeader;
    __weak IBOutlet UIView *vwCollection;
    __weak IBOutlet UILabel *lblNoVideoFound;
    NSMutableArray *arrMoviesCollections;
    NSMutableArray *arrMoviesInCollection;
    BOOL collectionDetailVisible;
}

@end
