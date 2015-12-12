//
//  VODMoviesCollections.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 28/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Collection view in VOD-movies section.

#import <UIKit/UIKit.h>
#import "MoviesCollection.h"

@protocol collectionDidSelect;

@interface VODMoviesCollections : UIView <UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*      collectionVwCollections;
}

@property (weak, nonatomic) IBOutlet UILabel*       lblNoCollectionFound;
@property (strong, nonatomic) NSArray*  arrCollections;
@property (weak, nonatomic) id <collectionDidSelect> delegate;
@property (assign, nonatomic) int i;

+ (id)customView;
- (void)registerCollectionVwCell;
- (void)reloadCollectionView:(NSArray*)arrResponse;

@end

@protocol collectionDidSelect <NSObject>

- (void)collectionVwSelectedItem:(MoviesCollection*)objMoviesCollection;

@end

