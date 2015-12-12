 //
//  CommonFunctions.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CommonFunctions.h"
#import "AtoZMovie.h"
#import "DetailGenre.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MoviePlayerViewController.h"
#import "UpcomingVideo.h"
#import "SearchLiveNowVideo.h"
#import "MusicSinger.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"
#import "LiveNowFeaturedViewController.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@implementation CommonFunctions

+ (CommonFunctions*)shared
{
    static CommonFunctions *sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[self alloc] init];
    });
    return sharedObj;
}

#pragma mark - Network Reachability
-(BOOL)checkNetworkConnectivity
{
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    
    switch(internetStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
            return YES;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
    }
    return YES;
}

#pragma mark - if its iphone
+(BOOL) isIphone
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return YES;
    }
    return NO;
}

#pragma mark - if its iphone5
+(BOOL) isIphone5
{
    if(IS_IPHONE_5)
        return YES;
    return NO;
}


#pragma mark - return Removing White Spacing String
-(BOOL) isInValidString:(UITextField *)txt StringToMatch:(NSString *)stringToMatch
{
    txt.text = [txt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *str1 = txt.text;
    
    if(str1 == nil)
        str1 = kEmptyString;
    
    return ([str1 isEqualToString:stringToMatch] ? YES : NO);
}

-(BOOL) isvalidPasswordLength:(UITextField *)txt StringToMatch:(NSString *)stringToMatch
{
    if (([stringToMatch length] < 6) || ([stringToMatch length] > 21))
        return YES;
    else
        return NO;
}

#pragma mark - Show Alert View
+ (void)showAlertView:(NSString *)message TITLE:(NSString *) title Delegate:(id)delegate
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:kOK otherButtonTitles:nil, nil] show];
}

#pragma mark - Compare Two strings
-(BOOL) compareStrings :(NSString *)str String2:(NSString *)str2
{
    NSString *string1 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *string2 = [str2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    return ([string1 isEqualToString:string2] ? YES : NO);
}

#pragma Pushing to existing ViewController in Navigation Controller Stack
+(void) pushViewController:(UINavigationController *)nav ViewController:(UIViewController *)viewController
{
    for(UIViewController *controller in nav.viewControllers)
        if([controller isKindOfClass:[viewController class]])
        {
            [nav popToViewController:controller animated:YES];
            return;
        }
    [nav pushViewController:viewController animated:YES];
}

#pragma mark - return Date Format
+(NSString *) returnDateFormat:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    int hour = (int)[components hour];
    int mins = (int)[components minute];
    
    NSString *strFormattedDate;
    if (hour >= 12)
        strFormattedDate = [NSString stringWithFormat:@"%d:%d PM", hour, mins];
    else
        strFormattedDate = [NSString stringWithFormat:@"%d:%d AM", hour, mins];
    
    return strFormattedDate;
}

#pragma mark - return Array of Alphabets
+(NSMutableArray *) returnArrayOfAlphabets
{
    NSMutableArray *arrAlphabets = [[NSMutableArray alloc] init];
    for (char a = 'A'; a <= 'Z'; a++)
    {
        [arrAlphabets addObject:[NSString stringWithFormat:@"%c", a]];
    }
//    [arrAlphabets addObject:@"#"];
    return arrAlphabets;
}

#pragma mark - return Alphabet by index
+(NSString *) returnAlphabetByIndex:(int) index
{
    return [[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] objectAtIndex:index];
}


#pragma mark - return array for particular alphabet
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabet :(NSMutableArray *) arrAtoZMovies arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrAtoZMovies count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [[self returnAlphabetByIndex:i] uppercaseString];
        for(int j=0;j<[arrAtoZMovies count];j++)
        {
            AtoZMovie *objAtoZMovie = [arrAtoZMovies objectAtIndex:j];
            
            NSString *title = objAtoZMovie.movieName_eniPhone;
            
            if(![title isEqualToString:kEmptyString])
                title = [[title substringToIndex:1] uppercaseString];
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objAtoZMovie];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanAlphabetsRecordsArray:arrAtoZMovies];
    if([arrayOfSpecialCharacters count] > 0){
        [arrRecords addObject:arrayOfSpecialCharacters];
        [arrAlphabets addObject:@"#"];
    }
    return arrRecords;
}

+(NSMutableArray *)returnArrayOfRecordForMusicSingersParticularAlphabet :(NSMutableArray *) arrAtoZMovies arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrAtoZMovies count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [[self returnAlphabetByIndex:i] uppercaseString];
        for(int j=0;j<[arrAtoZMovies count];j++)
        {
            MusicSinger *objAtoZMovie = [arrAtoZMovies objectAtIndex:j];
            
            NSString *title = objAtoZMovie.musicVideoName_en;
            
            if(![title isEqualToString:kEmptyString])
                title = [[title substringToIndex:1] uppercaseString];
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objAtoZMovie];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanAlphabetsMusicSingersRecordsArray:arrAtoZMovies];
    if([arrayOfSpecialCharacters count] > 0){
        [arrRecords addObject:arrayOfSpecialCharacters];
        [arrAlphabets addObject:@"#"];
    }
    return arrRecords;
}

#pragma mark - return array for particular alphabet
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForDetailGenre :(NSMutableArray *) arrDetailGenre arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrDetailGenre count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [[self returnAlphabetByIndex:i] uppercaseString];
        for(int j=0;j<[arrDetailGenre count];j++)
        {
            DetailGenre *objDetailGenre = [arrDetailGenre objectAtIndex:j];
            NSString *title = objDetailGenre.movieTitle_en;
            if(![title isEqualToString:kEmptyString])
            {
                title = [[title substringToIndex:1] uppercaseString];
            }
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objDetailGenre];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanAlphabetsRecordsArrayForGenre:arrDetailGenre];
    if([arrayOfSpecialCharacters count] > 0){
        [arrAlphabets addObject:@"#"];
        [arrRecords addObject:arrayOfSpecialCharacters];
    }
    return arrRecords;
}

#pragma mark - return array for particular alphabet
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForSearch :(NSMutableArray *) arrSearch arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrSearch count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [[self returnAlphabetByIndex:i] uppercaseString];
        for(int j=0;j<[arrSearch count];j++)
        {
            DetailGenre *objDetailGenre = [arrSearch objectAtIndex:j];
            NSString *title = objDetailGenre.movieTitle_en;
            if(![title isEqualToString:kEmptyString])
            {
                title = [[title substringToIndex:1] uppercaseString];
            }
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objDetailGenre];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanAlphabetsRecordsArrayForSearch:arrSearch];
    if([arrayOfSpecialCharacters count] > 0){
        [arrAlphabets addObject:@"#"];
        [arrRecords addObject:arrayOfSpecialCharacters];
    }
    return arrRecords;
}

#pragma mark - return Other than AlphabetRecords Array
+(NSMutableArray *) returnOtherThanAlphabetsMusicSingersRecordsArray:(NSMutableArray *) arrAtoZMovies
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrAtoZMovies count];i++)
    {
        MusicSinger *objAtoZMovie = [arrAtoZMovies objectAtIndex:i];
        NSString *title = objAtoZMovie.musicVideoName_en;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];j++)
        {
            NSString *alphabetToMatch = [[self returnAlphabetByIndex:j] uppercaseString];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        
        if(count == 0)
            [arrOtherthanAlphabets addObject:objAtoZMovie];
    }
    return arrOtherthanAlphabets;
}

+(NSMutableArray *) returnOtherThanAlphabetsRecordsArray:(NSMutableArray *) arrAtoZMovies
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrAtoZMovies count];i++)
    {
        AtoZMovie *objAtoZMovie = [arrAtoZMovies objectAtIndex:i];
        NSString *title = objAtoZMovie.movieName_en;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];j++)
        {
            NSString *alphabetToMatch = [[self returnAlphabetByIndex:j] uppercaseString];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        
        if(count == 0)
            [arrOtherthanAlphabets addObject:objAtoZMovie];
    }
    return arrOtherthanAlphabets;
}

#pragma mark - return Other than AlphabetRecords Array
+(NSMutableArray *) returnOtherThanAlphabetsRecordsArrayForGenre:(NSMutableArray *) arrDetailGenre
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrDetailGenre count];i++)
    {
        DetailGenre *objDetailGenre = [arrDetailGenre objectAtIndex:i];
        NSString *title = objDetailGenre.movieTitle_en;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];j++)
        {
            NSString *alphabetToMatch = [[self returnAlphabetByIndex:j] uppercaseString];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        if(count == 0)
            [arrOtherthanAlphabets addObject:objDetailGenre];
    }
    return arrOtherthanAlphabets;
}


#pragma mark - return Other than AlphabetRecords Array
+(NSMutableArray *) returnOtherThanAlphabetsRecordsArrayForSearch:(NSMutableArray *) arrSearch
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrSearch count];i++)
    {
        UpcomingVideo *objUpcomingVideo = [arrSearch objectAtIndex:i];
        NSString *title = objUpcomingVideo.upcomingVideoName_en;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets] count];j++)
        {
            NSString *alphabetToMatch = [[self returnAlphabetByIndex:j] uppercaseString];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        if(count == 0)
            [arrOtherthanAlphabets addObject:objUpcomingVideo];
    }
    return arrOtherthanAlphabets;
}
#pragma Return Time
+(NSString *)returnTime:(NSString *)strDate
{
    NSMutableString *strTime = [[NSMutableString alloc] init];
    NSArray *arrTime = [strDate componentsSeparatedByString:@":"];
    if ([arrTime count]>0) {
        
        [strTime appendString:[arrTime objectAtIndex:0]];
        [strTime appendString:@":"];
        [strTime appendString:[arrTime objectAtIndex:1]];
        
        if ([[arrTime objectAtIndex:0] intValue] >= 12) {
            [strTime appendString:@" PM"];
        }
        else{
            [strTime appendString:@" AM"];
        }
    }
    
    return strTime;
}

#pragma mark - return HTML for youtube embed video
+(NSString *)getYouTubeEmbed:(NSString *)VideoPath embedRect:(CGRect)rect
{
    NSString *html = @"";
    
    if ([VideoPath rangeOfString:@"vimeo.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSString *embedHTML = [NSString stringWithFormat:@"<iframe width=\"%f\" height=\"%f\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>",rect.size.width,rect.size.height,VideoPath];
        html = [NSString stringWithFormat:@"%@",embedHTML];
    }
    else if ([VideoPath rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSString *videoUrl = [NSString stringWithFormat:@"http://www.youtube.com/v/%@",VideoPath];
        
        html = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %f\"/></head><body style=\"background:#000;margin-top:0px;margin-left:0px\"><div><object width=\"%f\" height=\"%f\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%f\" height=\"%f\"></embed></object></div></body></html>", rect.size.width,rect.size.width, rect.size.height,videoUrl,videoUrl,rect.size.width, rect.size.height];
        html = [html stringByReplacingOccurrencesOfString:@"/watch?v=" withString:@"/embed/"];
    }
    else if ([VideoPath rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        // VideoPath = @"http://link.brightcove.com/services/player/bcpid3815086849001?bckey=AQ~~,AAADd9u4__E~,fHl6JWluMnctnUR7lsNevXxKfibpHuew&bctid=3815237365001&height=709&width=1024";
        
        html = [NSString stringWithFormat:@"<iframe src=%@ width=%f\" height=%f\" frameborder=0 marginwidth=0 marginheight=0 scrolling=no; border-width:0px 0px 0; margin-bottom:0px; max-width:%f\" allowfullscreen> </iframe> <div style=margin-bottom:0px> <strong> <a href=https://www.slideshare.net/Andrii_Naidenko/brightcove-video-platform-overview title=Brightcove video platform overview target=_blank>Brightcove video platform overview</a> </strong> from <strong><a href=%@ target=_blank></a></strong> </div>", VideoPath, rect.size.width, rect.size.height, rect.size.width, VideoPath];
        
      //  html = [NSString stringWithFormat:@"<iframe src=%@ width=300 height=100 frameborder=0 marginwidth=0 marginheight=0 scrolling=no style=border:0px solid #CCC; border-width:0px 0px 0; margin-bottom:0px; max-width: 100 allowfullscreen> </iframe> <div style=margin-bottom:0px> <strong> <a href= title= target=_blank></a> </strong> from <strong><a href= target=_blank></a></strong> </div>", VideoPath];
    }
    else
    {
        html = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %f\"/></head><body style=\"background:#111;margin-top:0px;margin-left:0px\"><div><object width=\"%f\" height=\"%f\"><param name=\"movie\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%f\" height=\"%f\"></embed></object></div></body></html>", rect.size.width,rect.size.width, rect.size.height,VideoPath,rect.size.width, rect.size.height];
    }
    
    return html;
}

#pragma mark - View For Header
+(UIView *) returnViewForHeader:(NSString *) str UITableView:(UITableView *)tblVw
{
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(tblVw.frame.origin.x, 0, tblVw.frame.size.width, 20)];
    [vw setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
    //[vw setBackgroundColor:[UIColor clearColor]];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(tblVw.frame.origin.x+10, 3, size.width, 14)];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];//change by bharti
    [lbl setBackgroundColor:vw.backgroundColor];
    [lbl setText:str];
    [vw addSubview:lbl];
    return vw;
}

#pragma mark - Play Video
+ (void)playVideo:(NSString*)strVideoUrl ViewController:(UIViewController *) vwController
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] init];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
    {
        if (objLoginViewController.view.superview) {
            return;
        }
        objLoginViewController = nil;
        objLoginViewController = [[LoginViewController alloc] init];
        //  objLoginViewController.delegate = self;
        
        CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        [objLoginViewController.view setFrame:CGRectMake(0, windowHeight, vwController.view.frame.size.width, windowHeight)];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window addSubview:objLoginViewController.view];
        [UIView animateWithDuration:0.5f animations:^{
            [objLoginViewController.view setFrame:CGRectMake(0, 0, vwController.view.frame.size.width, windowHeight)];
        } completion:nil];
    }
    else{
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = strVideoUrl;
        [vwController.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
}

#pragma mark - Fetch CGContext of View

+ (UIImage*)fetchCGContext:(UIView*)view
{
    CGSize sizeVw = CGSizeMake(view.frame.size.width, view.frame.size.height-130);
    UIGraphicsBeginImageContext(sizeVw);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

#pragma mark - if user is logged in
+(BOOL) userLoggedIn
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kAccessTokenKey])
    {
        return YES;
    }
    return NO;
}

#pragma mark - return records Group By
-(NSMutableArray *) returnRecordsGroupByDate:(NSMutableArray *)arrRecordsLocal ArrDates:(NSMutableArray *) arrDates
{
    NSMutableArray *arrDatesOriginal = [arrRecordsLocal mutableCopy];
    arrRecordsLocal = [arrRecordsLocal valueForKeyPath:@"@distinctUnionOfObjects.upcomingVideoDay"];
    
    
    arrRecordsLocal = [[arrRecordsLocal sortedArrayUsingComparator:
                        ^(id obj1, id obj2) {
                            return [obj1 compare:obj2];
                        }] mutableCopy];
    
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    NSMutableArray *arrRecordsInner = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrRecordsLocal count];i++)
    {
        [arrRecordsInner removeAllObjects];
        NSString *date = [arrRecordsLocal objectAtIndex:i];
        for(int j=0;j<[arrDatesOriginal count];j++)
        {
            SearchLiveNowVideo *objSearchLiveNowVideo = [arrDatesOriginal objectAtIndex:j];
            if([date isEqualToString:objSearchLiveNowVideo.upcomingVideoDay])
                [arrRecordsInner addObject:objSearchLiveNowVideo];
        }
        [arrRecords addObject:[arrRecordsInner mutableCopy]];
        
        NSString *strDate = [arrRecordsLocal objectAtIndex:i];
        strDate = [self returnDay:strDate];
        [arrRecordsLocal replaceObjectAtIndex:i withObject:strDate];
        [arrDates addObject:[arrRecordsLocal objectAtIndex:i]];
    }
    
    return arrRecords;
}

-(NSString *)returnDay:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = (int)[components day];
    
    dateFormatter.dateFormat=@"MMM";
    NSString * monthString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    dateFormatter.dateFormat=@"EEEE";
    NSString * dayString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    NSString *strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", dayString, monthString, day];
    return [strFormattedDate uppercaseString];
}

#pragma mark - Return yes if English language is selected by user
+(BOOL) isEnglish
{
    if([[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedLanguageKey] isEqualToString:kEnglish] || (![CommonFunctions isIphone]))
    {
        return YES;
    }
    return NO;
}


+(BOOL) isEnglishLang
{
    if([[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        return YES;
    }
    return NO;
}
#pragma mark - Language Method

+ (NSBundle*)setLocalizedBundle
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *path = nil;
    if ([[defs objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        path = [[NSBundle mainBundle] pathForResource:kEnglish ofType:@"lproj"];
    } else if ([[defs objectForKey:kSelectedLanguageKey] isEqualToString: kArabic]) {
        path = [[NSBundle mainBundle] pathForResource:kArabic ofType:@"lproj"];
    }
    return [NSBundle bundleWithPath:path];
}

+ (UIImage *)scaleDownSizeOfImage:(UIImage *)image Size:(CGSize)size
{
    CGSize originalImgSize = image.size;
    
    if (fmaxf(originalImgSize.height, originalImgSize.width) <= fminf(size.height, size.width)) {
        return image;
    } else {
        CGSize imageSize = [self newImageSizeForImageSize:originalImgSize ImgViewSize:size];
        
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
        [image drawInRect:CGRectMake(0,0,imageSize.width,imageSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

#pragma mark Resize Image For Image View
+ (CGSize)newImageSizeForImageSize:(CGSize)imageSize ImgViewSize:(CGSize)size
{
    CGFloat scaleFactor;
    CGSize newImageSize = CGSizeZero;
    
    float widthFactor  = size.width / imageSize.width;
    float heightFactor = size.height / imageSize.height;
    
    if ( widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    newImageSize = CGSizeMake(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
    
    return newImageSize;
}

#pragma mark - MutableText Function
+ (NSMutableAttributedString*)changeMinTextFont:(NSString*)lblText fontName:(NSString*)textFontName
{
    //Format bullets
    NSMutableAttributedString *bulletStr = [[NSMutableAttributedString alloc] initWithString:@"د"];
    
    if ([CommonFunctions isIphone])
        [bulletStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:textFontName size:20] range:NSMakeRange(0, [bulletStr length])];
    else
        [bulletStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:textFontName size:24] range:NSMakeRange(0, [bulletStr length])];
    //NSString *patternBold1 = @"(Special Notes:)";
    NSString *patternBold1 = [NSString stringWithFormat:@"(د)"];
    
    NSRegularExpression *expressionBold1 = [NSRegularExpression regularExpressionWithPattern:patternBold1 options:0 error:nil];
    
    //  enumerate matches
    NSRange rangeBold1 = NSMakeRange(0,[lblText length]);
    NSMutableAttributedString *txtViewDesc = [[NSMutableAttributedString alloc] initWithString:lblText];

    NSString *str2 = lblText;
    
    [expressionBold1 enumerateMatchesInString:str2 options:0 range:rangeBold1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange bulletTextRange = [result rangeAtIndex:1];
        [txtViewDesc replaceCharactersInRange:bulletTextRange withAttributedString:bulletStr];
    }];
    
    return txtViewDesc;
}

+ (NSString *)convertGMTDateFromLocalDate:(NSString *)gmtDateStr
{
    NSString *dateString = [CommonFunctions convertGMTDateFromLocalDateWithDays:gmtDateStr];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
  //  int day = [components day];
    int hour = (int)[components hour];
    int mins = (int)[components minute];
    
    NSString *strFormattedDate;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        if (hour > 12)
        {
            strFormattedDate = [NSString stringWithFormat:@"%02d:%02d PM", hour-12, mins];
        }
        else if (hour == 12)
        {
            strFormattedDate = [NSString stringWithFormat:@"%02d:%02d PM", hour, mins];
        }
        else if (hour == 0)
        {
            hour = 12;
            strFormattedDate = [NSString stringWithFormat:@"%02d:%02d AM", hour, mins];
        }
        else
        {
            strFormattedDate = [NSString stringWithFormat:@"%02d:%02d AM", hour, mins];
        }
    }
    else
    {
        //[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]
        if (hour > 12)
        {
            NSString *final = [NSString stringWithFormat:@"%02d:%02d %@", hour-12, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            strFormattedDate = final;
        }
        else if (hour == 12)
        {
            NSString *final = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            strFormattedDate = final;
        }
        else if (hour == 0)
        {
            hour = 12;
            NSString *final = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"am" value:@"" table:nil]];
            strFormattedDate = final;
        }
        else
        {
            NSString *final = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"am" value:@"" table:nil]];
            strFormattedDate = final;
        }
    }
    return strFormattedDate;
}

+ (NSString*)convertTimeUnitToArabic:(NSString*)convertedTime
{
    NSArray *arrTimeUnits = [convertedTime componentsSeparatedByString:@" "];
    NSMutableString *time = [[NSMutableString alloc] init];
    if ([arrTimeUnits count]>=2) {
            [time appendString:[arrTimeUnits objectAtIndex:0]];
            [time appendString:@" "];
            [time appendString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:[[arrTimeUnits objectAtIndex:1] lowercaseString] value:@"" table:nil]];
    }
    
    return time;
}

+ (NSString*)convertTimeUnitLanguage:(NSString*)convertedTime
{
    NSArray *arrTimeUnits = [convertedTime componentsSeparatedByString:@" "];
    NSMutableString *time = [[NSMutableString alloc] init];
    if ([arrTimeUnits count]>=2) {
        [time appendString:[arrTimeUnits objectAtIndex:0]];
        [time appendString:@" "];
        [time appendString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:[[arrTimeUnits objectAtIndex:1] lowercaseString] value:@"" table:nil]];
    }
    
    return time;
}

+ (NSString *)convertGMTDateFromLocalDateWithDays:(NSString *)gmtDateStr
{
    NSDateFormatter *serverFormatter = [[NSDateFormatter alloc] init];
    [serverFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [serverFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSDate *theDate = [serverFormatter dateFromString:gmtDateStr];
    NSDateFormatter *userFormatter = [[NSDateFormatter alloc] init];
    // [userFormatter setDateFormat:@"HH:mm dd/MM/yyyy"];
    [userFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [userFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *dateConverted = [userFormatter stringFromDate:theDate];
    
    return dateConverted;
}

+ (NSString *)changeDateFormatForGMTDate:(NSString*)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
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


#pragma mark - Day and Month language conversion

+ (NSString*)changeLanguageForDays:(NSString*)dayString
{
    return [[self setLocalizedBundle] localizedStringForKey:dayString value:@"" table:nil];
}

+ (NSString*)changeLanguageForMonths:(NSString*)monthString
{
    return [[self setLocalizedBundle] localizedStringForKey:monthString value:@"" table:nil];
}


#pragma mark - Arabic UITableView Section indexing

+ (NSMutableArray*)createArabicAlphabetsArray:(NSArray*)arrAtoZMovies
{
    NSMutableArray *arrArabicAlphabets = [[NSMutableArray alloc] init];
    BOOL isSpecialCharacterAtBegin = '\0';
    for (int i = 0; i < [arrAtoZMovies count]; i++) {
        
        AtoZMovie *objAtoZMovie = (AtoZMovie*) [arrAtoZMovies objectAtIndex:i];
        NSString *title = objAtoZMovie.movieName_ar;
        
        unichar c = [title characterAtIndex:0];
        if ((c >= '0' && c <= '9') || c == ' ' || (c >= 33 && c <= 47) || (c >= 58 && c <= 64) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
            
            isSpecialCharacterAtBegin = YES;
        }
        else
        {
            if(![title isEqualToString:kEmptyString])
                title = [title substringToIndex:1];
            
            if (![arrArabicAlphabets containsObject:title]) {
                [arrArabicAlphabets addObject:title];
            }
        }
    }
    
    if (isSpecialCharacterAtBegin) {
        [arrArabicAlphabets addObject:@"#"];
    }
    
    return arrArabicAlphabets;
}

+ (NSMutableArray *)returnArrayOfRecordForParticularAlphabetArabic :(NSMutableArray *) arrAtoZMovies arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrAtoZMovies count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [self returnArabicAlphabetByIndex:i];
        for(int j=0;j<[arrAtoZMovies count];j++)
        {
            AtoZMovie *objAtoZMovie = [arrAtoZMovies objectAtIndex:j];
            
            NSString *title = objAtoZMovie.movieName_ar;
            
            if(![title isEqualToString:kEmptyString])
                title = [[title substringToIndex:1] uppercaseString];
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objAtoZMovie];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanArabicAlphabetsAtoZRecordsArray:arrAtoZMovies];
    if([arrayOfSpecialCharacters count] > 0){
        [arrRecords addObject:arrayOfSpecialCharacters];
        [arrAlphabets addObject:@"#"];
    }
    return arrRecords;
}

+ (NSMutableArray *)returnOtherThanArabicAlphabetsAtoZRecordsArray:(NSMutableArray *) arrAtoZMovies
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrAtoZMovies count];i++)
    {
        AtoZMovie *objAtoZMovie = [arrAtoZMovies objectAtIndex:i];
        NSString *title = objAtoZMovie.movieName_ar;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] count];j++)
        {
            NSString *alphabetToMatch = [self returnArabicAlphabetByIndex:j];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        
        if(count == 0)
            [arrOtherthanAlphabets addObject:objAtoZMovie];
    }
    return arrOtherthanAlphabets;
}

+ (NSString*)returnAlphabetByIndex:(int)index arrArabicAlphabets:(NSArray*)arrArabicAlphabets
{
    return [arrArabicAlphabets objectAtIndex:index];
}

+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForDetailGenreArabic:(NSMutableArray *)arrDetailGenre arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrDetailGenre count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [self returnArabicAlphabetByIndex:i];
        for(int j=0;j<[arrDetailGenre count];j++)
        {
            DetailGenre *objDetailGenre = [arrDetailGenre objectAtIndex:j];
            
            NSString *title = objDetailGenre.movieTitle_ar;
            
            if(![title isEqualToString:kEmptyString])
                title = [[title substringToIndex:1] uppercaseString];
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objDetailGenre];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanArabicAlphabetsGenreDetailRecordsArray:arrDetailGenre];
    if([arrayOfSpecialCharacters count] > 0){
        [arrRecords addObject:arrayOfSpecialCharacters];
        [arrAlphabets addObject:@"#"];
    }
    return arrRecords;
}

+ (NSMutableArray *)returnOtherThanArabicAlphabetsGenreDetailRecordsArray:(NSMutableArray *) arrAtoZMovies
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrAtoZMovies count];i++)
    {
        DetailGenre *objDetailGenre = [arrAtoZMovies objectAtIndex:i];
        NSString *title = objDetailGenre.movieTitle_ar;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] count];j++)
        {
            NSString *alphabetToMatch = [self returnArabicAlphabetByIndex:j];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        
        if(count == 0)
            [arrOtherthanAlphabets addObject:objDetailGenre];
    }
    return arrOtherthanAlphabets;
}

+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForMusicArabic:(NSMutableArray *)arrDetailGenre arrayOfAphabetsToDisplay:(NSMutableArray *)arrAlphabets
{
    [arrAlphabets removeAllObjects];
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];
    if([arrDetailGenre count] == 0)
        return arrRecords;
    for(int i = 0;i<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] count];i++)
    {
        NSMutableArray *arrOfRecordsAccordingToAlphabet = [[NSMutableArray alloc] init];
        NSString *alphabetToMatch = [self returnArabicAlphabetByIndex:i];
        for(int j=0;j<[arrDetailGenre count];j++)
        {
            MusicSinger *objAtoZMovie = [arrDetailGenre objectAtIndex:j];
            
            NSString *title = objAtoZMovie.musicVideoName_ar;
            
            if(![title isEqualToString:kEmptyString])
                title = [[title substringToIndex:1] uppercaseString];
            
            if([alphabetToMatch isEqualToString:title])
            {
                [arrOfRecordsAccordingToAlphabet addObject:objAtoZMovie];
            }
        }
        if([arrOfRecordsAccordingToAlphabet count]>0)
        {
            [arrAlphabets addObject:alphabetToMatch];
            [arrRecords addObject:arrOfRecordsAccordingToAlphabet];
        }
    }
    NSMutableArray *arrayOfSpecialCharacters = [self returnOtherThanArabicAlphabetsMusicSingersRecordsArray:arrDetailGenre];
    if([arrayOfSpecialCharacters count] > 0){
        [arrRecords addObject:arrayOfSpecialCharacters];
        [arrAlphabets addObject:@"#"];
    }
    return arrRecords;
}

+ (NSMutableArray *)returnOtherThanArabicAlphabetsMusicSingersRecordsArray:(NSMutableArray *) arrAtoZMovies
{
    NSMutableArray *arrOtherthanAlphabets = [[NSMutableArray alloc] init];
    for(int i=0;i<[arrAtoZMovies count];i++)
    {
        MusicSinger *objAtoZMovie = [arrAtoZMovies objectAtIndex:i];
        NSString *title = objAtoZMovie.musicVideoName_ar;
        if(![title isEqualToString:kEmptyString])
            title = [[title substringToIndex:1] uppercaseString];
        
        int count = 0;
        
        for(int j = 0;j<[[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] count];j++)
        {
            NSString *alphabetToMatch = [self returnArabicAlphabetByIndex:j];
            if([alphabetToMatch isEqualToString:title])
            {
                count += 1;
            }
        }
        
        if(count == 0)
            [arrOtherthanAlphabets addObject:objAtoZMovie];
    }
    return arrOtherthanAlphabets;
}

+ (NSString*)returnArabicAlphabetByIndex:(int)index
{
    return [[(AppDelegate *)[[UIApplication sharedApplication] delegate] arrayOfAlphabets_ar] objectAtIndex:index];
}

+ (NSMutableArray*)returnArabicAlphabets
{
    NSMutableArray *arrArabicAlphabets = [[NSMutableArray alloc] init];

    [arrArabicAlphabets addObject:@"ا"];
    [arrArabicAlphabets addObject:@"ب"];
    [arrArabicAlphabets addObject:@"ت"];
    [arrArabicAlphabets addObject:@"ث"];
    [arrArabicAlphabets addObject:@"ج"];
    [arrArabicAlphabets addObject:@"ح"];
    [arrArabicAlphabets addObject:@"خ"];
    [arrArabicAlphabets addObject:@"د"];
    [arrArabicAlphabets addObject:@"ذ"];
    [arrArabicAlphabets addObject:@"ر"];
    [arrArabicAlphabets addObject:@"ز"];
    [arrArabicAlphabets addObject:@"س"];
    [arrArabicAlphabets addObject:@"ش"];
    [arrArabicAlphabets addObject:@"ص"];
    [arrArabicAlphabets addObject:@"ض"];
    [arrArabicAlphabets addObject:@"ط"];
    [arrArabicAlphabets addObject:@"ظ"];
    [arrArabicAlphabets addObject:@"ع"];
    [arrArabicAlphabets addObject:@"غ"];
    [arrArabicAlphabets addObject:@"ف"];
    [arrArabicAlphabets addObject:@"ق"];
    [arrArabicAlphabets addObject:@"ك"];
    [arrArabicAlphabets addObject:@"ل"];
    [arrArabicAlphabets addObject:@"م"];
    
    [arrArabicAlphabets addObject:@"ن"];
    [arrArabicAlphabets addObject:@"ه"];
    [arrArabicAlphabets addObject:@"و"];
    [arrArabicAlphabets addObject:@"ى"];
    
    
    return arrArabicAlphabets;
}

+ (NSMutableArray*)createArabicAlphabetsArrayMusicArabic:(NSArray*)arrDetailGenre
{
    NSMutableArray *arrArabicAlphabets = [[NSMutableArray alloc] initWithArray:[self returnArabicAlphabets]];
    
    BOOL isSpecialCharacterAtBegin = '\0';
    for (int i = 0; i < [arrDetailGenre count]; i++) {
        
        MusicSinger *objMusicSinger = [arrDetailGenre objectAtIndex:i];
        NSString *title = objMusicSinger.musicVideoName_ar;
        if ([title length]!=0) {
            
          //  unichar c = [title characterAtIndex:0];
//            if ((c >= '0' && c <= '9') || c == ' ' || (c >= 33 && c <= 47) || (c >= 58 && c <= 64) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
//                
//                isSpecialCharacterAtBegin = YES;
//            }
//            else
//            {
//                if(![title isEqualToString:kEmptyString])
//                    title = [title substringToIndex:1];
            
                if (![arrArabicAlphabets containsObject:title]) {
                    isSpecialCharacterAtBegin = YES;
                }
          //  }
        }
    }
    
    if (isSpecialCharacterAtBegin) {
        [arrArabicAlphabets addObject:@"#"];
    }
    
    return arrArabicAlphabets;
}

+ (NSMutableArray*)createArabicAlphabetsArrayArabic:(NSArray*)arrDetailGenre
{
    NSMutableArray *arrArabicAlphabets = [[NSMutableArray alloc] init];
    BOOL isSpecialCharacterAtBegin = '\0';
    for (int i = 0; i < [arrDetailGenre count]; i++) {
        
        DetailGenre *objDetailGenre = [arrDetailGenre objectAtIndex:i];
        NSString *title = objDetailGenre.movieTitle_ar;
        if ([title length]!=0) {
            
            unichar c = [title characterAtIndex:0];
            if ((c >= '0' && c <= '9') || c == ' ' || (c >= 33 && c <= 47) || (c >= 58 && c <= 64) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
                
                isSpecialCharacterAtBegin = YES;
            }
            else
            {
                if(![title isEqualToString:kEmptyString])
                    title = [title substringToIndex:1];
                
                if (![arrArabicAlphabets containsObject:title]) {
                    [arrArabicAlphabets addObject:title];
                }
            }
        }
    }
    
    if (isSpecialCharacterAtBegin) {
        [arrArabicAlphabets addObject:@"#"];
    }
    
    return arrArabicAlphabets;
}



#pragma mark - iAd Banner view
+ (ADBannerView*)addiAdBanner:(float)yOrigin delegate:(id)delegate
{
    if([CommonFunctions shared].admobBannerView)
    {
        [[CommonFunctions shared].admobBannerView removeFromSuperview];
    }

    if([CommonFunctions shared].adBannerView != nil) {
        NSLog(@"%@", [CommonFunctions shared].adBannerView);
        [[CommonFunctions shared].adBannerView removeFromSuperview];
        [CommonFunctions shared].adBannerView = nil;
    }
    int nHeight;
    
    if (![CommonFunctions isIphone]) {
        nHeight = 70;
    }
    else
    {
        nHeight = 50;
    }
    
    [CommonFunctions shared].adBannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, yOrigin, [[UIScreen mainScreen] bounds].size.width, nHeight)];
    [[CommonFunctions shared].adBannerView setDelegate:delegate];

    return [CommonFunctions shared].adBannerView;
}

+ (GADBannerView*)addAdmobBanner:(float)yOrigin
{
    if([CommonFunctions shared].admobBannerView == nil)
    {
        [CommonFunctions shared].admobBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, yOrigin - 3, [[UIScreen mainScreen] bounds].size.width, 50)];
        //AdMob pub-3843794018935978
        [CommonFunctions shared].admobBannerView.adUnitID = kAdmobAppId;
        [CommonFunctions shared].admobBannerView.rootViewController = (UIViewController *)self;
    }
    int nHeight;
    
    if (![CommonFunctions isIphone]) {
        nHeight = 70;
    }
    else
    {
        nHeight = 50;
    }
//    admobBannerView.rootViewController = self;
    [[CommonFunctions shared].admobBannerView setFrame:CGRectMake(0, yOrigin, [[UIScreen mainScreen] bounds].size.width, nHeight)];
    GADRequest* request = [GADRequest request];
//    request.testDevices = @[ @"e2379c5ada4dda7dd665f1952e1aedd7" ];
    [[CommonFunctions shared].admobBannerView removeFromSuperview];
    [[CommonFunctions shared].admobBannerView loadRequest:request];
    
    return [CommonFunctions shared].admobBannerView;
}

//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
}

#pragma mark - Write logs in file
+ (void)writeToTextFile:(NSString *) response
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
	NSFileManager *fManager = [NSFileManager defaultManager];
    
	if([fManager fileExistsAtPath:path])
	{
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [file seekToFileOffset:[file seekToEndOfFile]];
        response = [NSString stringWithFormat:@"%@\n",response];
        NSDate *now = [NSDate date];
        response = [NSString stringWithFormat:@"%@\n%@",now,response];
        [file writeData:[response dataUsingEncoding: NSStringEncodingConversionAllowLossy]];
	}
    else
    {
        NSData *data = (NSData*)[NSString stringWithContentsOfFile:response encoding:NSStringEncodingConversionAllowLossy error:nil];
        
        // [fManager createFileAtPath:path contents:[NSString stringWithContentsOfFile:response encoding:NSStringEncodingConversionAllowLossy error:nil] attributes:nil];
        [fManager createFileAtPath:path contents:data attributes:nil];
    }
    
    if([fManager fileExistsAtPath:path])
	{
        printf("");
	}
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:response delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    [alert show];
}

+ (NSString*)brightCoveExtendedUrl:(NSString*)movieUrl
{
    NSURL *url = [NSURL URLWithString:movieUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        
      //  return [response valueForKey:@"URL"];
        
        NSString *extentedUrl = [NSString stringWithFormat:@"%@", [response valueForKey:@"URL"]];
        NSArray  *urlComponentArray = [extentedUrl componentsSeparatedByString:@"bctid="];
        if ([urlComponentArray count]>=2) {
            
           return [CommonFunctions brightCoveMp4Url:[urlComponentArray lastObject]];
        }
    }
    
    return @"";
}

+ (NSString*)brightCoveMp4Url:(NSString*)movieExtendedUrl
{
    //https://api.brightcove.com/services/library?command=find_video_by_id&video_id=4072465828001&token=oFwMVv5-Fq9_xbiKByN7Xtw70T4p8rp72xsaykG17LxFw8u9TscquA..&output=json&media_delivery=http&video_fields=id,name,shortDescription,publishedDate,creationDate,videoStillURL,FLVURL
    
    NSString *serviceUrl = @"https://api.brightcove.com/services/library?command=find_video_by_id&video_id=?&token=?&output=json&media_delivery=http&video_fields=FLVURL";
    serviceUrl = [serviceUrl stringByReplacingOccurrencesOfString:@"video_id=?" withString:[NSString stringWithFormat:@"video_id=%@", movieExtendedUrl]];
    serviceUrl = [serviceUrl stringByReplacingOccurrencesOfString:@"token=?" withString:[NSString stringWithFormat:@"token=%@", bCoveAccessToken]];
    
    NSURL *url = [NSURL URLWithString:serviceUrl];
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *response;
    NSError *requestError = [[NSError alloc] init];
    NSInteger success = 1;
    
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response
                                                        error:&requestError];
    
    //if communication was successful
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSError *serializeError = nil;
        NSDictionary *jsonData = [NSJSONSerialization
                                  JSONObjectWithData:urlData
                                  options:NSJSONReadingMutableContainers
                                  error:&serializeError];
        success = [jsonData[@"ERROR"] integerValue];
        
        if (success == 0) {
            //success! do stuff with the jsonData dictionary here
            
            return [jsonData objectForKey:@"FLVURL"];
        }
        else {
            //handle ERROR from server
            [self showAlertView:nil TITLE:[serializeError description] Delegate:nil];
        }
    }
    else {
        //handle error for unsuccessful communication with server
        [self showAlertView:nil TITLE:kServerErrorMessage Delegate:nil];
    }
    return @"";
}

#pragma mark - Sharing message
+ (NSString*)showPostedMessageTwitter
{
    return @"For more content download Melody Now app";
}

+ (NSString*)showPostedMessageDownload
{
    return @"\nFor more movies, series and music videos, download Melody Now app from Apple App Store or Google Play Store";
}

+ (void)addGoogleAnalyticsForView:(NSString *)viewName
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 1;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticCode];
    [tracker set:kGAIScreenName value:viewName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [[AppsFlyerTracker sharedTracker] trackEvent:@"View" withValue:viewName];
}

@end