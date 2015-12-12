//
//  ChannelTableViewCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "ChannelTableViewCell.h"
#import "CommonFunctions.h"

@implementation ChannelTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChannelSetValue:(UpcomingVideo*)objUpcomingVideo
{
    //Set cell value.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblVideoName.text = objUpcomingVideo.upcomingVideoName_en;
    else
        lblVideoName.text = objUpcomingVideo.upcomingVideoName_ar;

    //Set local time after converted using local GMT time zone.
    NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objUpcomingVideo.upcomingDay];
    lblVideoTime.text = [convertedTime uppercaseString];
}

@end