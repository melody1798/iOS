//
//  LiveNowFeaturedCollectionCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Live videos custom collection view cells.


#import <UIKit/UIKit.h>
#import "LiveNowFeaturedVideo.h"

@interface LiveNowFeaturedCollectionCell : UICollectionViewCell
{
}

@property (weak, nonatomic) IBOutlet UIImageView*   imageVwLogo;
@property (strong, nonatomic) IBOutlet UIImageView*   imageVwVideo;
@property (weak, nonatomic) IBOutlet UILabel*   lblVideoName;
@property (weak, nonatomic) IBOutlet UILabel*   lblVideoTime;
@property (strong, nonatomic) IBOutlet UIButton*   btnPlay;

- (void)setCellValues:(LiveNowFeaturedVideo*)objLiveNowFeaturedVideo;

@end
