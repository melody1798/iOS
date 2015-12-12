//
//  ChannelDetailView.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "ChannelDetailView.h"
#import "ChannelTableViewCell.h"
#import "Constant.h"
#import "UpcomingVideos.h"
#import "UIImageView+WebCache.h"
#import "VideoDetail.h"
#import "Channels.h"
#import "CommonFunctions.h"

@implementation ChannelDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)customView
{
    ChannelDetailView *customView = [[[NSBundle mainBundle] loadNibNamed:@"ChannelDetailView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[ChannelDetailView class]])
        return customView;
    else
        return nil;
}

- (void)setUIAppearance
{
    //Set UI
    lblLiveNowTitle.font = [UIFont fontWithName:kProximaNova_Light size:18.0];
    lblChannelName.font = [UIFont fontWithName:kProximaNova_Light size:18.0];
    lblNoUpcomings.font = [UIFont fontWithName:kProximaNova_Bold size:24.0];
    [self setLocalizedText];
}

- (void)setLocalizedText
{
    //Set localize data
    lblLiveNowTitle.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil] uppercaseString];
    lblNoUpcomings.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
    
    lblChannelName.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
    
    lblMovieName.font = [UIFont fontWithName:kProximaNova_SemiBold size:22.0];
    lblMovieName.backgroundColor = [UIColor clearColor];
    lblMovieName.textColor = YELLOW_COLOR;
    lblMovieTime.textColor = [UIColor whiteColor];
    lblMovieTime.backgroundColor = [UIColor clearColor];
    lblMovieTime.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 12.0:14.0)];
}

- (void)fetchChannelDetails:(Channel*)objChannel
{
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Channel"];
    
    self.strChannelUrl = [NSString stringWithFormat:@"%@", objChannel.channelLiveNowVideoUrl];
    
    if (objChannel.channelLiveNowVideoUrl != nil) {
        [self playVideo:objChannel.channelLiveNowVideoUrl];
    }
    
    lblChannelName.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
    self.strChannelName_en = [NSString stringWithFormat:@"%@", objChannel.channelName_en];
    self.strChannelName_ar = [NSString stringWithFormat:@"%@", objChannel.channelName_ar];

    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:objChannel.channelLogoUrl] placeholderImage:nil];
    
    //Fetch upcoming programs.
    UpcomingVideos *objUpcomingVideos = [UpcomingVideos new];
    [objUpcomingVideos fetchChannelUpcomingVideos:self selector:@selector(upcomingVideosResponse:) channelName:objChannel.channelName_en];
}

#pragma mark - Channel Detail from search view
- (void)fetchChannelDetailsAfterSearch:(SearchLiveNowVideo*)objSearchLiveNowVideo
{
    self.strChannelUrl = [NSString stringWithFormat:@"%@", objSearchLiveNowVideo.channelURL];
    
    if (objSearchLiveNowVideo.channelURL != nil) {
        [self playVideo:objSearchLiveNowVideo.channelURL];
    }
    
    lblChannelName.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
    
    self.strChannelName_en = [NSString stringWithFormat:@"%@", objSearchLiveNowVideo.upcomingChannelName];
    self.strChannelName_ar = [NSString stringWithFormat:@"%@", objSearchLiveNowVideo.upcomingChannelName];
    
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.upcomingVideoChannelLogoUrl] placeholderImage:nil];
    
    UpcomingVideos *objUpcomingVideos = [UpcomingVideos new];
    [objUpcomingVideos fetchChannelUpcomingVideos:self selector:@selector(upcomingVideosResponse:) channelName:objSearchLiveNowVideo.upcomingChannelName];
}

#pragma mark - Handle server response.
- (void)upcomingVideosResponse:(UpcomingVideos*)objUpcomingVideos
{
    lblNoUpcomings.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(updateChannelLogoFromSearch:)]) {
        [_delegate updateChannelLogoFromSearch:objUpcomingVideos.channelLogoUrl];
    }
    
    [self GroupUpcomingData:objUpcomingVideos.arrUpcomingVideos]; //Group data according to date/day.
    
    if ([arrUpcomingVideos count] == 0) {
        lblNoUpcomings.hidden = NO;
    }
    
    if (objUpcomingVideos.liveVideoName_en != nil) {
        
        self.bLiveVideoPlaying = YES;
        self.strChannelUrl = objUpcomingVideos.liveChannelUrl;
        lblMovieName.hidden = NO;
        lblMovieTime.hidden = NO;
        imgVwPlayMovieIcon.hidden = NO;
        lblMovieTime.textAlignment = NSTextAlignmentLeft;

        self.strLiveMovie_en = [NSString stringWithFormat:@"%@", objUpcomingVideos.liveVideoName_en];
        self.strLiveMovie_ar = [NSString stringWithFormat:@"%@", objUpcomingVideos.liveVideoName_ar];

        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            lblMovieName.text = objUpcomingVideos.liveVideoName_en;
        }
        else
        {
            lblMovieName.text = objUpcomingVideos.liveVideoName_ar;
        }
        
        if (objUpcomingVideos.liveVideoStartTime!=nil) {
            
            NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objUpcomingVideos.liveVideoStartTime];
            lblMovieTime.text = [convertedTime uppercaseString];
        }
        else
            lblMovieTime.hidden = YES;
        
        [imgVwMovieLogo setHidden:NO];
        [imgVwMovieLogo sd_setImageWithURL:[NSURL URLWithString:objUpcomingVideos.liveVideoThumbnail]];
    }
    else
    {
        self.bLiveVideoPlaying = NO;
        lblMovieName.hidden = YES;
        lblMovieTime.hidden = NO;
        imgVwPlayMovieIcon.hidden = YES;
        [imgVwMovieLogo sd_setImageWithURL:[NSURL URLWithString:@""]];
        [imgVwMovieLogo setHidden:YES];
        lblMovieTime.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No live show found for this channel." value:@"" table:nil];
        lblMovieTime.textAlignment = NSTextAlignmentRight;
    }
    [tblVwUpcoming reloadData];
}

- (void)playVideo:(NSString*)videoUrl
{
    NSString *urlString =  [self getYouTubeEmbed:videoUrl embedRect:webVwChannel.frame];
    [webVwChannel loadHTMLString:urlString baseURL:nil];
    webVwChannel.scrollView.scrollEnabled = NO;
}

#pragma mark - Group upcoming data
- (void)GroupUpcomingData:(NSArray*)arrUpcomingData
{
    arrUpcomingVideos = [[NSArray alloc] initWithArray:arrUpcomingData];
    arrTodayUpcomingVideos = [[NSArray alloc] initWithArray:arrUpcomingData];
    
    [self sortDataByDate:arrUpcomingData];
}

- (void)sortDataByDate:(NSArray*)sortedDateArray
{
    days = [NSMutableArray array];
    groupedEvents = [NSMutableDictionary dictionary];
    
    for (UpcomingVideo *objUpcomingVideo in sortedDateArray)
    {
        NSString *dato = [CommonFunctions convertGMTDateFromLocalDateWithDays:objUpcomingVideo.upcomingDay];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *gmtDate = [formatter dateFromString: dato];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *newDate = [formatter stringFromDate:gmtDate];
        gmtDate = [formatter dateFromString:newDate];

        if (![days containsObject:gmtDate] && gmtDate!=nil)
        {
            [days addObject:gmtDate];
            [groupedEvents setObject:[NSMutableArray arrayWithObject:objUpcomingVideo] forKey:gmtDate];
        }
        else
        {
            [((NSMutableArray*)[groupedEvents objectForKey:gmtDate]) addObject:objUpcomingVideo];
        }
    }
    
    days = [[days sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    
    [tblVwUpcoming reloadData];
}

#pragma mark - Handle button action
- (IBAction)playBtnAction:(id)sender
{
    if (self.bLiveVideoPlaying == YES) {
        
        if (![self checkUserAccessToken]) {
            
            [self showLoginScreen];
        }
        else{
            if ([_delegate respondsToSelector:@selector(playChannelUrlInFullScreenMode:)]) {
                [_delegate playChannelUrlInFullScreenMode:self.strChannelUrl];
            }
        }
    }
}

- (void)showLoginScreen
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegateUpdateMovie = self;
    CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    [objLoginViewController.view setFrame:CGRectMake(0, windowHeight, self.frame.size.width, windowHeight)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:objLoginViewController.view];
    [UIView animateWithDuration:0.5f animations:^{
        [objLoginViewController.view setFrame:CGRectMake(0, 0, self.frame.size.width, windowHeight)];
    } completion:nil];
}

- (void)updateMovieDetailViewAfterLogin
{
    if ([_delegate respondsToSelector:@selector(playChannelUrlInFullScreenMode:)]) {
        [_delegate playChannelUrlInFullScreenMode:self.strChannelUrl];
    }
}

- (BOOL)checkUserAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
        return YES;
    else
        return NO;
}

#pragma mark - Change language
- (void)changeLanguageChannelView
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        lblMovieName.text = self.strLiveMovie_en;
    else
        lblMovieName.text = self.strLiveMovie_ar;
    
    [self setLocalizedText];
    NSString *strTime = lblMovieTime.text;
    lblMovieTime.text = [CommonFunctions convertTimeUnitLanguage:strTime];
    [tblVwUpcoming reloadData];
}

#pragma mark - Youtube handling
-(NSString *)getYouTubeEmbed:(NSString *)VideoPath embedRect:(CGRect)rect
{
    NSString *html = @"";
    
    if ([VideoPath rangeOfString:@"vimeo.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSString *embedHTML = [NSString stringWithFormat:@"<iframe width=\"%f\" height=\"%f\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>",rect.size.width,rect.size.height,VideoPath];
        html = [NSString stringWithFormat:@"%@",embedHTML];
    }
    else if ([VideoPath rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        webVwChannel.allowsInlineMediaPlayback = YES;
        webVwChannel.mediaPlaybackRequiresUserAction = NO;
        
        NSArray* dividedText = [VideoPath componentsSeparatedByString:@"v="];
        NSString *videoUrl;
        
        if ([dividedText count] >= 1 && [dividedText count]!=0 && [dividedText count]!=1) {
            videoUrl = [dividedText objectAtIndex:1];
            
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"youtube" ofType:@"html"];
            NSError *error;
            NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            html = [htmlStr stringByReplacingOccurrencesOfString:@"**" withString:videoUrl];
            
            if ([CommonFunctions isIphone]) {
                html = [NSString stringWithFormat:@"<iframe class=\"youtube-player\" type=\"text/html\" width=\"100%%\" height=\"%f\" src=\"%@\" frameborder=\"0\"></iframe>", webVwChannel.frame.size.height+180, VideoPath];
                html = [html stringByReplacingOccurrencesOfString:@"/watch?v=" withString:@"/embed/"];
            }
        }
    }
    else if ([VideoPath rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        html = [NSString stringWithFormat:@"<iframe src=%@ width=%f\" height=%f\" frameborder=0 marginwidth=0 marginheight=0 scrolling=no; border-width:0px 0px 0; margin-bottom:0px; max-width:%f\" allowfullscreen> </iframe> <div style=margin-bottom:0px> <strong> <a href=https://www.slideshare.net/Andrii_Naidenko/brightcove-video-platform-overview title=Brightcove video platform overview target=_blank>Brightcove video platform overview</a> </strong> from <strong><a href=%@ target=_blank></a></strong> </div>", VideoPath, rect.size.width, rect.size.height, rect.size.width, VideoPath];
    }
    else
    {
        html = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %f\"/></head><body style=\"background:#000;margin-top:0px;margin-left:0px\"><div><object width=\"%f\" height=\"%f\"><param name=\"movie\"></param><param name=\"wmode\" autoplay=\"autoplay\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%f\" height=\"%f\"></embed></object></div></body></html>", rect.size.width,rect.size.width, rect.size.height,VideoPath,rect.size.width, rect.size.height];
    }
    
    return html;
}


#pragma mark - Play Channel from Selected search
- (void)fetchChannelDetailsPlayFromSearch:(NSString*)channelName
{
   // lblChannelName.text = channelName;
    lblChannelName.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
    
    Channels *objChannels = [Channels new];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        [objChannels fetchChannelDetails:self selector:@selector(channelDetailResponse:) channelName:channelName isArb:@"false"];
    else
        [objChannels fetchChannelDetails:self selector:@selector(channelDetailResponse:) channelName:channelName isArb:@"true"];

    UpcomingVideos *objUpcomingVideos = [UpcomingVideos new];
    [objUpcomingVideos fetchChannelUpcomingVideos:self selector:@selector(upcomingVideosResponse:) channelName:channelName];
}

- (void)channelDetailResponse:(Channel*)objChannel
{
    [self playVideo:objChannel.channelLiveNowVideoUrl];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [days count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[groupedEvents objectForKey:[days objectAtIndex:section]] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"channelcell";
    ChannelTableViewCell *cell = (ChannelTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (ChannelTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"ChannelTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    [cell setChannelSetValue:[[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *vwHeaderUpcoming = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 38)];
    vwHeaderUpcoming.backgroundColor = [UIColor blackColor];
    
    UIImageView *imgVwHeaderBack = [[UIImageView alloc] initWithFrame:vwHeaderUpcoming.frame];
    imgVwHeaderBack.backgroundColor = [UIColor colorWithRed:59/255.0 green:59/255.0 blue:59/255.0 alpha:1.0];
    
    UILabel *lblUpcoming = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 768, 28)];
    lblUpcoming.textAlignment = NSTextAlignmentCenter;

    BOOL y = [self compareDates:[days objectAtIndex:section]];
    if (y) {
        lblUpcoming.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
        return nil;
    }
    else
    {
        [lblUpcoming setFrame:CGRectMake(20, 0, 768, 38)];
        [lblUpcoming setTextAlignment:NSTextAlignmentLeft];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss EEEE";
        NSString *strDate = [formatter stringFromDate:[days objectAtIndex:section]];
        [lblUpcoming setText:[self changeDateFormat:strDate]];
    }
    
    lblUpcoming.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
    lblUpcoming.textColor = [UIColor whiteColor];
    lblUpcoming.backgroundColor = [UIColor clearColor];
    
    [vwHeaderUpcoming addSubview:imgVwHeaderBack];
    [vwHeaderUpcoming addSubview:lblUpcoming];

    return vwHeaderUpcoming;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BOOL y = [self compareDates:[days objectAtIndex:section]];
    if (y) {
        return 0;
    }
    return 38;
}

- (BOOL)compareDates:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

-(NSString *)changeDateFormat:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss EEEE"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    int day = (int)[components day];
    
    dateFormatter.dateFormat=@"MMMM";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        dateFormatter.dateFormat=@"MMM";
    }
    NSString * monthString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    dateFormatter.dateFormat=@"EEEE";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        dateFormatter.dateFormat=@"EEE";
    }
    NSString * dayString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    NSString *strFormattedDate;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        
        strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day];
    }
    else
    {
        strFormattedDate = [NSString stringWithFormat:@"%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
    }
    
    return strFormattedDate;
}

-(NSString *)changeDateFormatForLive:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm a"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    int hour = (int)[components hour];
    int mins = (int)[components minute];
    
    NSString *strFormattedDate;
    if (hour >= 12)
        strFormattedDate = [NSString stringWithFormat:@"%02d:%02d PM", hour-12, mins];
    else
        strFormattedDate = [NSString stringWithFormat:@"%02d:%02d AM", hour, mins];
    
    return strFormattedDate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end