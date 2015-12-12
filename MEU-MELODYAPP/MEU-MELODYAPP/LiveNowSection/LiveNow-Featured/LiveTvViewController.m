//
//  LiveTvViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/02/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "LiveTvViewController.h"
#import "LiveNowFeaturedVideos.h"
#import "LiveNowFeaturedVideo.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"
#import "UIImageView+WebCache.h"
#import "LiveNowCustomCell.h"

@interface LiveTvViewController () <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView*                vWBanner;
    IBOutlet UIScrollView*          scrollViewBanner;
    IBOutlet UIPageControl*         pageControl;
    IBOutlet UILabel*               lblLiveNowText;
    IBOutlet UITableView*           tblLiveNow;
    IBOutlet UILabel*               lblNoVideoFoundBannerView;
    IBOutlet UILabel*               lblNoVideoFoundTableView;
}

@property (strong, nonatomic) NSArray*      arrLiveFeaturedVideos;
@property (strong, nonatomic) NSArray*      arrLiveChannelVideos;

@end

@implementation LiveTvViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    [self getLiveNowFeaturedVideos];
}

#pragma mark - GetLiveNowFeatured Videos
-(void)getLiveNowFeaturedVideos
{
    //Fetch Live Now-Featured
    
  //  [MBProgressHUD showHUDAddedTo:vWBanner animated:YES];
    LiveNowFeaturedVideos *objLiveNowFeaturedVideos = [LiveNowFeaturedVideos new];
   // [objLiveNowFeaturedVideos fetchLiveFeaturedVideos:self selector:@selector(liveNowFeaturedVideoResponse:)];
    
   // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    LiveNowFeaturedVideos *objLiveNowFeaturedVideo = [LiveNowFeaturedVideos new];
   // [objLiveNowFeaturedVideo fetchLiveMovies:self selector:@selector(liveChannelVideo:)];
}

- (void)liveNowFeaturedVideoResponse:(NSMutableArray*)arrResponse
{
   // [MBProgressHUD hideHUDForView:vWBanner animated:NO];
    
    self.arrLiveFeaturedVideos = [[NSArray alloc] initWithArray:arrResponse];
    [pageControl setHidden:NO];
    
    lblNoVideoFoundBannerView.hidden = YES;
    pageControl.numberOfPages = [self.arrLiveFeaturedVideos count];
    if ([arrResponse count] == 0) {
        lblNoVideoFoundBannerView.hidden = NO;
    }
    
    [self setBannerView];
    [tblLiveNow reloadData];
}

- (void)liveChannelVideo:(NSArray*)arrResponse
{
   // [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [lblNoVideoFoundTableView setHidden:YES];
    self.arrLiveChannelVideos = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrLiveChannelVideos count] == 0) {
        [self.view bringSubviewToFront:lblNoVideoFoundTableView];
        [lblNoVideoFoundTableView setHidden:NO];
    }
    [tblLiveNow reloadData];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    LiveNowCustomCell *cell = [tblLiveNow dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LiveNowCustomCell" owner:self options:Nil] firstObject];
    }
    
    LiveNowFeaturedVideo *objLiveNowFeaturedVideo = [self.arrLiveChannelVideos objectAtIndex:indexPath.row];
    
    //        NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:[CommonFunctions convertGMTDateFromLocalDateWithDays:objLiveNowFeaturedVideo.videoTime_en]];
    
    NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objLiveNowFeaturedVideo.videoTime_en];
    
    cell.lblTime.text = [convertedTime uppercaseString];
    
    cell.lblChannelName.text = objLiveNowFeaturedVideo.videoName_en;
    
    CGSize timeLblSize = [cell.lblTime.text sizeWithFont:cell.lblTime.font constrainedToSize:CGSizeMake(120, CGRectGetHeight(cell.lblTime.frame))];
    
    cell.lblTime.frame = CGRectMake(CGRectGetMinX(cell.lblTime.frame), CGRectGetMinY(cell.lblTime.frame), timeLblSize.width, CGRectGetHeight(cell.lblTime.frame));
    cell.lblChannelName.frame = CGRectMake(CGRectGetMaxX(cell.lblTime.frame)+5, CGRectGetMinY(cell.lblChannelName.frame), 150, CGRectGetHeight(cell.lblChannelName.frame));
    
    [cell.imgLiveNowChannel sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:[UIImage imageNamed:@""]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setBannerView
{
    NSMutableArray *arrVideos = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.arrLiveFeaturedVideos count]; i++)
    {
        [arrVideos addObject:[self.arrLiveFeaturedVideos objectAtIndex:i]];
    }
    
    for (UIView *view in scrollViewBanner.subviews)
    {
        [view removeFromSuperview];
    }
    NSInteger xOrigin = 0;
    if([arrVideos count] > 0)
    {
        scrollViewBanner.layer.borderWidth = 2;
        scrollViewBanner.layer.borderColor = [[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] CGColor];
    }
    for (int i = 0; i < [arrVideos count]; i++)
    {
        
        LiveNowFeaturedVideo *objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*) [arrVideos objectAtIndex:i];
        //        if (i == 0)
        //            [imgVwPrev sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en]];
        
        CGRect scrollViewFrame = scrollViewBanner.frame;
        scrollViewFrame.origin.x = xOrigin;
        scrollViewFrame.origin.y = 0;
        // scrollViewFrame.size.height = scrollViewFrame.size.height;
        
        UIView *viewBanner = [[UIView alloc] initWithFrame:scrollViewFrame];
        viewBanner.backgroundColor = [UIColor clearColor];
        
        //Set image on banner  638 236
        UIImageView *imageBanner = [[UIImageView alloc] initWithFrame:CGRectMake(([CommonFunctions isIphone]? 0:65), 0, scrollViewFrame.size.width-([CommonFunctions isIphone]? 2:130), scrollViewFrame.size.height-([CommonFunctions isIphone]? 0:0))];
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.fImageWidth = imageBanner.frame.size.width;
        appdelegate.fImageHeight = imageBanner.frame.size.height;
        
        imageBanner.backgroundColor = [UIColor clearColor];
        if(![CommonFunctions isIphone])
            imageBanner.contentMode = UIViewContentModeScaleAspectFill;
        
        [imageBanner sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en] placeholderImage:[UIImage imageNamed:@"abc"]];
        
        [viewBanner addSubview:imageBanner];
        
        //Add Play button
        UIButton *btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(([CommonFunctions isIphone]? scrollViewBanner.frame.size.width - 30:imageBanner.center.x-21), ([CommonFunctions isIphone]? scrollViewBanner.frame.size.height - 34:imageBanner.frame.size.height/2-21), [CommonFunctions isIphone]? 19:42, [CommonFunctions isIphone]? 19:42)];
        
        [btnPlay setImage:[UIImage imageNamed:[CommonFunctions isIphone]?@"play_btn~iphone":@"play_btn~ipad"] forState:UIControlStateNormal];
        btnPlay.tag = i;
        [btnPlay addTarget:self action:@selector(btnPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btnPlay.contentMode = UIViewContentModeCenter;
        //[viewBanner addSubview:btnPlay];
        
        if([CommonFunctions isIphone])
            [viewBanner bringSubviewToFront:btnPlay];
        
        //Set labels on banner
        CGRect infoView;
        infoView.origin.x = imageBanner.frame.origin.x;
        infoView.origin.y = imageBanner.frame.size.height-47;
        infoView.size.width = imageBanner.frame.size.width;
        infoView.size.height = 47;
        
        if ([CommonFunctions isIphone]) {
            
            infoView.origin.y = imageBanner.frame.size.height-37;
            infoView.size.height = 35;
        }
        UIView *viewVideoInfo = [[UIView alloc] initWithFrame:infoView];
        
        viewVideoInfo.backgroundColor = [UIColor blackColor];
        viewVideoInfo.alpha = 0.85;
        
        UIImageView *imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 35, 35)];
        imageLogo.contentMode = UIViewContentModeScaleToFill;
        [imageLogo sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:nil];
        
        if (![CommonFunctions isIphone]) {
            UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(50, 3, 1, viewVideoInfo.frame.size.height-6)];
            lblSeperator.backgroundColor = [UIColor darkGrayColor];
            [viewVideoInfo addSubview:lblSeperator];
        }
        
        if(![CommonFunctions isIphone])
            [viewVideoInfo addSubview:imageLogo];
        
        UILabel *lblMovieNameBanner = [[UILabel alloc] initWithFrame:CGRectMake([CommonFunctions isIphone]? scrollViewBanner.frame.origin.x+38:(imageLogo.frame.origin.x+imageLogo.frame.size.width+15), [CommonFunctions isIphone]?2:5, [CommonFunctions isIphone]?[UIScreen mainScreen].bounds.size.width - imageLogo.frame.size.width-88:[UIScreen mainScreen].bounds.size.width - imageLogo.frame.size.width-125, 23)];
        lblMovieNameBanner.backgroundColor = [UIColor clearColor];
        lblMovieNameBanner.textColor = YELLOW_COLOR;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            [lblMovieNameBanner setText:objLiveNowFeaturedVideo.videoName_en];
        else
            [lblMovieNameBanner setText:objLiveNowFeaturedVideo.videoName_ar];
        
        lblMovieNameBanner.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 15.0:22.0)];
        [viewVideoInfo addSubview:lblMovieNameBanner];
        
        UILabel *lblMovieTimeBanner = [[UILabel alloc] initWithFrame:CGRectMake([CommonFunctions isIphone]? scrollViewBanner.frame.origin.x+38:(imageLogo.frame.origin.x+imageLogo.frame.size.width+15), [CommonFunctions isIphone]?lblMovieNameBanner.frame.size.height-8:lblMovieNameBanner.frame.size.height, [UIScreen mainScreen].bounds.size.width - imageLogo.frame.size.width, 23)];
        lblMovieNameBanner.backgroundColor = [UIColor clearColor];
        
        lblMovieTimeBanner.text = [self changeDateFormatForDays:[CommonFunctions convertGMTDateFromLocalDateWithDays:objLiveNowFeaturedVideo.videoTime_en]];
        
        lblMovieTimeBanner.textColor = [UIColor whiteColor];
        lblMovieTimeBanner.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 12.0:16.0)];
        [lblMovieTimeBanner setBackgroundColor:[UIColor clearColor]];
        
        if([CommonFunctions isIphone])
        {
            UIImageView *imageLogoSmall = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            CGSize size = CGSizeZero;
            if (IS_IOS7_OR_LATER)
                size = [lblMovieTimeBanner.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kProximaNova_SemiBold size:12.0],NSFontAttributeName, nil]];
            else
                size = [lblMovieTimeBanner.text sizeWithFont:[UIFont fontWithName:kProximaNova_SemiBold size:12.0]];
            CGRect rect = imageLogoSmall.frame;
            rect.origin.x = lblMovieTimeBanner.frame.origin.x + size.width + 2;
            rect.origin.y = lblMovieTimeBanner.frame.origin.y + 7;
            rect.size.width = 10;
            rect.size.height = 10;
            
            CGRect imgFrame = rect;
            imgFrame.origin.x = 10;
            imgFrame.origin.y = 3;
            imgFrame.size.width = 30;
            imgFrame.size.height = 30;
            
            [imageLogoSmall setFrame:imgFrame];
            //            NSURL *url = [NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en];
            //            NSData *data = [NSData dataWithContentsOfURL:url];
            //            UIImage *img = [[UIImage alloc] initWithData:data];
            //            UIImage *small = [UIImage imageWithCGImage:img.CGImage scale:0.50 orientation:img.imageOrientation];
            //[imageLogoSmall setImage:[UIImage imageNamed:@"dummy_logo"]];
            [imageLogoSmall sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:[UIImage imageNamed:nil]];
            
            [viewVideoInfo addSubview:imageLogoSmall];
        }
        
        [viewVideoInfo addSubview:lblMovieTimeBanner];
        [viewBanner addSubview:viewVideoInfo];
        [viewBanner bringSubviewToFront:viewVideoInfo];
        [viewBanner bringSubviewToFront:btnPlay];
        [scrollViewBanner addSubview:viewBanner];
        
        xOrigin+= scrollViewBanner.frame.size.width;
        [scrollViewBanner setContentSize:CGSizeMake(viewBanner.frame.size.width * (i+1), 0)];
    }
    
    //  pageControl.numberOfPages = scrollViewBanner.contentSize.width/scrollViewBanner.frame.size.width;
}


- (NSString*)changeDateFormatForDays:(NSString*)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = [components day];
    int hour = [components hour];
    int mins = [components minute];
    
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    dateFormatter.dateFormat=@"EEEE";
    NSString * dayString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    NSString *strFormattedDate;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        if (hour > 12)
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d PM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour-12, mins];
        }
        else if (hour == 12)
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d PM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour, mins];
        }
        else if (hour == 0)
        {
            hour = 12;
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d AM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour, mins];
        }
        else
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d AM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour, mins];
        }
    }
    else
    {
        if (hour > 12)
        {
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour-12, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
        else if (hour == 12)
        {
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
        else if (hour == 0)
        {
            hour = 12;
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
        else
        {
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"am" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
    }
    return strFormattedDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
