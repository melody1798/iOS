//
//  CollectionsDetailCustomCell.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionsDetailCustomCell : UICollectionViewCell
@property(nonatomic,retain) IBOutlet UILabel *lblName;
@property(nonatomic,retain) IBOutlet UILabel *lblEpisodeTitle;

@property(nonatomic,retain) IBOutlet UIImageView *imgMovie;

@end
