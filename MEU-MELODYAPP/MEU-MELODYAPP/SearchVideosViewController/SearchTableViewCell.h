//
//  SearchTableViewCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 26/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Search content cell layout.

#import <UIKit/UIKit.h>
#import "SearchLiveNowVideo.h"
#import "LiveNowFeaturedVideo.h"

@interface SearchTableViewCell : UITableViewCell
{
    IBOutlet UIImageView*       imgVwLogo;
    IBOutlet UILabel*           lblTime;
    IBOutlet UILabel*           lblProgramName;
}

- (void)setCellValue:(SearchLiveNowVideo*)objSearchLiveNowVideo;
- (void)setCellValueUpcomingVideos:(SearchLiveNowVideo*)objSearchLiveNowVideo;
- (void)setCellLiveNowSearch:(LiveNowFeaturedVideo*)objLiveNowFeaturedVideo;

@end
