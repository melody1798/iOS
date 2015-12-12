//
//  SearchTableViewCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 26/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CommonFunctions.h"
#import "Constant.h"
#import "AppDelegate.h"

@implementation SearchTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.fImageWidth = 120;
    appdelegate.fImageHeight = 120;
    
    lblProgramName.font = [UIFont fontWithName:kProximaNova_Regular size:18.0];
    lblProgramName.textColor = YELLOW_COLOR;
    
    lblTime.font = [UIFont fontWithName:kProximaNova_Regular size:16.0];
}

- (void)setCellValue:(SearchLiveNowVideo*)objSearchLiveNowVideo
{
    CGRect lblTimeFrame = lblProgramName.frame;
    lblTimeFrame.origin.x = 83;
    lblProgramName.frame = lblTimeFrame;
    
    lblTime.hidden = YES;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        lblProgramName.text = objSearchLiveNowVideo.videoName_en;
    else
        lblProgramName.text = objSearchLiveNowVideo.videoName_ar;

    [imgVwLogo sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.videoThumb] placeholderImage:nil];
}

- (void)setCellValueUpcomingVideos:(SearchLiveNowVideo*)objSearchLiveNowVideo
{
    NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objSearchLiveNowVideo.upcomingVideoDay];
    lblTime.text = [convertedTime uppercaseString];

    CGRect lblTimeFrame = lblProgramName.frame;
    lblTimeFrame.origin.x = 172;
    lblTimeFrame.size.width = 230;
    lblProgramName.frame = lblTimeFrame;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblProgramName.text = objSearchLiveNowVideo.upcomingVideoName_en;
    else
        lblProgramName.text = objSearchLiveNowVideo.upcomingVideoName_ar;

    [imgVwLogo sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.upcomingVideoChannelLogoUrl] placeholderImage:nil];
}

- (void)setCellLiveNowSearch:(LiveNowFeaturedVideo*)objLiveNowFeaturedVideo
{
    lblTime.hidden = YES;
    lblTime.text = [CommonFunctions returnTime:objLiveNowFeaturedVideo.videoTime_en];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblProgramName.text = objLiveNowFeaturedVideo.videoName_en;
    else
        lblProgramName.text = objLiveNowFeaturedVideo.videoName_ar;

    [imgVwLogo sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en] placeholderImage:nil];
}

@end