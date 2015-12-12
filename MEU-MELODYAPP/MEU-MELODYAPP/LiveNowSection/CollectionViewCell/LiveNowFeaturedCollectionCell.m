//
//  LiveNowFeaturedCollectionCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveNowFeaturedCollectionCell.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"

@implementation LiveNowFeaturedCollectionCell

@synthesize imageVwLogo, imageVwVideo;
@synthesize lblVideoName, lblVideoTime;
@synthesize btnPlay;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //Set UI
    [lblVideoName setTextColor:YELLOW_COLOR];
    [lblVideoName setFont:[UIFont fontWithName:kProximaNova_SemiBold size:18.0]];
    [lblVideoTime setFont:[UIFont fontWithName:kProximaNova_SemiBold size:16.0]];
}

#pragma mark - Set Cell values
- (void)setCellValues:(LiveNowFeaturedVideo*)objLiveNowFeaturedVideo
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.fImageWidth = imageVwVideo.frame.size.width;
    appdelegate.fImageHeight = imageVwVideo.frame.size.height;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        [lblVideoName setText:objLiveNowFeaturedVideo.videoName_en];
    else
        [lblVideoName setText:objLiveNowFeaturedVideo.videoName_ar];

    NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objLiveNowFeaturedVideo.startTime];
    lblVideoTime.text = [convertedTime uppercaseString];

    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en] placeholderImage:nil];
    [imageVwLogo sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:nil];
}

@end