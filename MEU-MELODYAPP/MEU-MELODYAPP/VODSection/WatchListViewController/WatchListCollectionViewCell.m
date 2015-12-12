//
//  WatchListCollectionViewCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 18/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "WatchListCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"

@implementation WatchListCollectionViewCell

@synthesize btnDelete;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellValues:(WatchListMovie*)objWatchListMovie
{
    // Drawing code
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.fImageWidth = imgVwThumb.frame.size.width;
    appDelegate.fImageHeight = imgVwThumb.frame.size.height;
    
    lblEpisodeNum.hidden = YES;
    lblMovieName.numberOfLines = 2;

    [imgVwThumb sd_setImageWithURL:[NSURL URLWithString:objWatchListMovie.movieThumb] placeholderImage:nil];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblMovieName.text = objWatchListMovie.movieName_en;
    else
        lblMovieName.text = objWatchListMovie.movieName_ar;

    if (objWatchListMovie.videoType == 3) {
        
        NSString *seriesEpiName = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objWatchListMovie.seriesName_en:objWatchListMovie.seriesName_ar;
        
//        lblMovieName.text = [NSString stringWithFormat:@"%@\n%@ %@", [seriesEpiName length]>22?[seriesEpiName substringToIndex:21]:seriesEpiName, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objWatchListMovie.episodeNum];
        
        lblMovieName.text = seriesEpiName;
        lblMovieName.numberOfLines = 1;
        
        lblEpisodeNum.hidden = NO;
        lblEpisodeNum.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objWatchListMovie.episodeNum];
    }
    lblMovieName.textColor = YELLOW_COLOR;
    lblMovieName.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblEpisodeNum.textColor = [UIColor whiteColor];
    lblEpisodeNum.font = [UIFont fontWithName:kProximaNova_SemiBold size:12.0];

    btnDelete.tag = [objWatchListMovie.movieId intValue];
}

- (IBAction)btnDeleteAction:(id)sender
{
    if ([delegate respondsToSelector:@selector(deleteWatchListItem:)]) {
        [delegate deleteWatchListItem:(int)[sender tag]];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}

@end