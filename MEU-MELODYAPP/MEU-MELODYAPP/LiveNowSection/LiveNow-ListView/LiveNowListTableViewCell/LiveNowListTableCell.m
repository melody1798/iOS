//
//  LiveNowListTableCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveNowListTableCell.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"
#import "CommonFunctions.h"

@implementation LiveNowListTableCell

@synthesize imageVwVideoLogo;
@synthesize lblMovieName, lblTime;
@synthesize btnPlayVideo;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [lblMovieName setTextColor:YELLOW_COLOR];
    [lblMovieName setFont:[UIFont fontWithName:kProximaNova_Bold size:18.0]];
    [lblTime setFont:[UIFont fontWithName:kProximaNova_Bold size:16.0]];
}

- (void)setCellValues:(LiveNowFeaturedVideo*)objLiveNowFeaturedVideo
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        [lblMovieName setText:objLiveNowFeaturedVideo.videoName_en];
    else
        [lblMovieName setText:objLiveNowFeaturedVideo.videoName_ar];

    NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objLiveNowFeaturedVideo.startTime];
    lblTime.text = [convertedTime uppercaseString];
    [imageVwVideoLogo sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:nil];
}

@end