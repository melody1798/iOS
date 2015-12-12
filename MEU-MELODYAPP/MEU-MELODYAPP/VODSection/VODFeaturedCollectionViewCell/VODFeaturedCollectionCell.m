//
//  VODFeaturedCollectionCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODFeaturedCollectionCell.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"
#import "SingerVideo.h"
#import "AppDelegate.h"
#import "Serie.h"

@implementation VODFeaturedCollectionCell

@synthesize imageVwVideo;
@synthesize lblVideoName, lblSingerName;
@synthesize imgVwTitleBg;

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
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.fImageWidth = imageVwVideo.frame.size.width;
    appdelegate.fImageHeight = imageVwVideo.frame.size.height;
    // Drawing code
    [lblVideoName setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [lblSingerName setFont:[UIFont fontWithName:kProximaNova_Regular size:15.0]];
}

- (void)setCellValuesForVODFeaturedMovies:(VODFeaturedVideo*)objVODFeaturedVideo
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        self.lblVideoName.text = objVODFeaturedVideo.movieTitle_en;
    else
        self.lblVideoName.text = objVODFeaturedVideo.movieTitle_ar;

    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objVODFeaturedVideo.movieThumbnail] placeholderImage:nil];
    
    float widthLbl = [self getTextHeight:objVODFeaturedVideo.movieTitle_en AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
}

- (void)setCellValuesForCollectionMovies:(MovieInCollection*)objMovieInCollection
{
    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objMovieInCollection.thumbUrl] placeholderImage:nil];
    
    float widthLbl = [self getTextHeight:objMovieInCollection.movieName_en AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
}

- (void)setCellValuesForMusic:(FeaturedMusic*)objFeaturedMusic
{
    lblSingerName.hidden = NO;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        self.lblVideoName.text = [NSString stringWithFormat:@"%@",  objFeaturedMusic.musicTitle_en];

        if ([objFeaturedMusic.singerName_en length]!=0)
        {
            self.lblSingerName.text = [NSString stringWithFormat:@"%@", objFeaturedMusic.singerName_en];
        }
    }
    else
    {
        self.lblVideoName.text = [NSString stringWithFormat:@"%@",  objFeaturedMusic.musicTitle_ar];

        if ([objFeaturedMusic.singerName_en length]!=0)

            self.lblSingerName.text = [NSString stringWithFormat:@"%@", objFeaturedMusic.singerName_ar];
    }
    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objFeaturedMusic.musicThumbnail] placeholderImage:nil];

    if ([lblSingerName.text length] != 0) {
        
        CGRect lblTitleFrame = self.lblVideoName.frame;
        lblTitleFrame.origin.y = 165;
        lblVideoName.frame = lblTitleFrame;
    }
    
    NSString* strTitleOrName = @"";
    
    if(objFeaturedMusic.musicTitle_en.length >= objFeaturedMusic.singerName_en.length) {
        strTitleOrName = objFeaturedMusic.musicTitle_en;
    }
    else {
        strTitleOrName = objFeaturedMusic.singerName_en;
    }
    
    float widthLbl = [self getTextHeight:strTitleOrName AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    self.lblVideoName.numberOfLines = 2;
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, 40);
}

- (void)setCellValuesForMusicGenre:(DetailGenre*)objDetailGenre
{
    float widthLbl;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        if ([objDetailGenre.musicVideoSingerName_en length]!=0)
            self.lblVideoName.text = [NSString stringWithFormat:@"%@ - %@",  objDetailGenre.movieTitle_en, objDetailGenre.musicVideoSingerName_en];
        
        else
            self.lblVideoName.text = [NSString stringWithFormat:@"%@",  objDetailGenre.movieTitle_en];
        
        widthLbl = [self getTextHeight:objDetailGenre.movieTitle_en AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    }
    else
    {
        if ([objDetailGenre.musicVideoSingerName_ar length]!=0)
            self.lblVideoName.text = [NSString stringWithFormat:@"%@ - %@",  objDetailGenre.movieTitle_ar, objDetailGenre.musicVideoSingerName_ar];
        else
            self.lblVideoName.text = [NSString stringWithFormat:@"%@",  objDetailGenre.movieTitle_ar];
        
        widthLbl = [self getTextHeight:objDetailGenre.movieTitle_ar AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    }
    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objDetailGenre.movieThumbnail] placeholderImage:nil];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
}

- (void)setCellValuesForSingers:(MusicSinger*)objMusicSinger
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        self.lblVideoName.text = objMusicSinger.singerName_en;
    else
        self.lblVideoName.text = objMusicSinger.singerName_ar;

    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objMusicSinger.musicVideoThumb] placeholderImage:nil];
    
    float widthLbl = [self getTextHeight:objMusicSinger.singerName_en AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
}

- (void)setCellValuesForSingersVideos:(SingerVideo*)objSingerVideo
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        self.lblVideoName.text = objSingerVideo.movieName_en;
    else
        self.lblVideoName.text = objSingerVideo.movieName_ar;

    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objSingerVideo.movieThumb] placeholderImage:nil];
    
    float widthLbl = [self getTextHeight:objSingerVideo.movieName_en AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
}

- (void)setCellValuesForAllSeries:(Serie*)objSerie
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        self.lblVideoName.text = objSerie.serieName_en;
    else
        self.lblVideoName.text = objSerie.serieName_ar;

    float widthLbl = [self getTextHeight:objSerie.serieName_en AndFrame:CGRectMake(20, 5, lblVideoName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
    
    [imageVwVideo sd_setImageWithURL:[NSURL URLWithString:objSerie.serieThumb] placeholderImage:nil];
}

#pragma -mark Calculate The Width Of label
- (float)getTextHeight:(NSString*)str AndFrame:(CGRect)frame
{
    UIFont *font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    CGFloat widthLbl;
    if (IS_IOS7_OR_LATER) {
        
        
        CGRect rect = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)
                                        options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];
        
        frame.size.width = ceilf(CGRectGetWidth(rect));
        widthLbl = ceilf(frame.size.width) + 20;
        
    } else {
        CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(259, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        widthLbl = ceilf(size.width) + 20;
    }
    return MAX(widthLbl, 84.0);
}

@end