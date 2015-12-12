//
//  ChannelTableViewCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//List of channels in custom cells.

#import <UIKit/UIKit.h>
#import "UpcomingVideo.h"

@interface ChannelTableViewCell : UITableViewCell
{
    IBOutlet UILabel*       lblVideoName;
    IBOutlet UILabel*       lblVideoTime;
}

- (void)setChannelSetValue:(UpcomingVideo*)objUpcomingVideo;

@end
