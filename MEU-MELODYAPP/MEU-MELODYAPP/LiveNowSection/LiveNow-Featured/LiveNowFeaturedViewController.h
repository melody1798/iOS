//
//  LiveNowFeaturedViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Live TV class to show live and upcoming events in iPhone, iPad.

#import <UIKit/UIKit.h>
#import "LiveNowFeaturedVideo.h"


@class CustomUITabBariphoneViewController;

@interface LiveNowFeaturedViewController : UIViewController <UITextFieldDelegate,UIWebViewDelegate>
{
    __weak IBOutlet UILabel *lblChannel;
    __weak IBOutlet UITableView *tblLiveNow;
    __weak IBOutlet UIImageView *imgLiveNow;
    __weak IBOutlet UIView *vwLiveNowHeader;
    __weak IBOutlet UILabel *lblLiveNowHeaderText;
    __weak IBOutlet UILabel *lblLiveNowSearch;
    __weak IBOutlet UILabel *lblUpcomingSearch;
    __weak IBOutlet UILabel *lblSearch;
    __weak IBOutlet UIView *vwchannel;
    __weak IBOutlet UIView *vwSearch;
    __weak IBOutlet UIButton *btnLiveNow;
    __weak IBOutlet UIButton *btnUpcoming;
    __weak IBOutlet UIButton *btnSearch;
    __weak IBOutlet UITextField *txtSearch;
    __weak IBOutlet UILabel *lblNoChannels;
    __weak IBOutlet UILabel *lblSearchNoVideos;
    __weak IBOutlet UIWebView *wbVwVideo;
    __weak IBOutlet UIView *channelHeaderView;
    __weak IBOutlet UIView *searchHeaderView;
    __weak IBOutlet UIImageView *channelImage;
    __weak IBOutlet UIButton *userLoggedInButton;
    __weak IBOutlet UIImageView *imgVwLiveMovie;
    __weak IBOutlet UILabel *lblMovieName;
    __weak IBOutlet UILabel *lblMovieTime;

    UITextField *txt;
    BOOL selectedChannel;
    NSMutableArray *arrChannels;
    NSMutableArray *arrChannelVideos;
    NSMutableArray *arrsearchLiveNowVideos;
    NSMutableArray *arrDates;
    BOOL playingSearchVideo;
    BOOL upComingSelected;
    NSString *channelURL;
    int lastSelectedIndex;
    BOOL searchDetail;
    NSMutableArray*             days;       //Handle grouped data in sections.
    NSMutableDictionary*        groupedEvents;
    NSMutableArray*             daysForSearch;
    NSMutableDictionary*        groupedEventsSearch; //Handle data for channel search.
    
    NSString *strChannelLogoUrl;
    UIImageView *imgVwChannelLogo;
}

+ (void)popFromVodSection;

@end

@protocol SearchTextHandleDelegate <NSObject>
- (void)handleSearchTextInSearchController:(NSString*)searchText;
@end
