//
//  LiveNowListTableCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Live videos custom collection view cells for list view iPad.

#import <UIKit/UIKit.h>
#import "LiveNowFeaturedVideo.h"

@interface LiveNowListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView*       imageVwVideoLogo;
@property (weak, nonatomic) IBOutlet UILabel*           lblTime;
@property (weak, nonatomic) IBOutlet UILabel*           lblMovieName;
@property (weak, nonatomic) IBOutlet UIButton*          btnPlayVideo;

- (void)setCellValues:(LiveNowFeaturedVideo*)objLiveNowFeaturedVideo;

@end
