//
//  MelodyHitsCustomCell.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpcomingVideo.h"

@interface MelodyHitsCustomCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UILabel *lblTime;
@property(nonatomic,retain) IBOutlet UILabel *lblChannelName;


- (void)setChannelSetValue:(UpcomingVideo*)objUpcomingVideo;

@end
