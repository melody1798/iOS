//
//  VODMoviesCollectionsCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 28/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// VOD Movies custom collection view cell.

#import <UIKit/UIKit.h>
#import "MoviesCollection.h"

@interface VODMoviesCollectionsCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel*           lblCollectionName;
@property (strong, nonatomic) IBOutlet UIImageView*     imgVwCollection;

- (void)setCellValues:(MoviesCollection*)objMoviesCollection;

@end
