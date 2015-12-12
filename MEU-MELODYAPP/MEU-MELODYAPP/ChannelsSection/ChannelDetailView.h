//
//  ChannelDetailView.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Show channel details with live and upcoming programs.

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "SearchVideoViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

@protocol ChannelUrlFullScreenModeDelegate;

@interface ChannelDetailView : UIView <UITableViewDataSource, UITableViewDelegate, UpdateMovieDetailOnLoginDelegate>
{
    IBOutlet UITableView*       tblVwUpcoming;
    IBOutlet UILabel*           lblLiveNowTitle;
    IBOutlet UILabel*           lblChannelName;
    IBOutlet UIImageView*       imgVwChannelLogo;
    NSArray*                    arrUpcomingVideos;
    NSArray*                    arrTodayUpcomingVideos;
    IBOutlet UIWebView*         webVwChannel;
    IBOutlet UILabel*           lblNoUpcomings;
    LoginViewController*        objLoginViewController;
    IBOutlet UIButton*          btnPlayVideo;
    NSMutableArray*             days;
    NSMutableDictionary*        groupedEvents;
    IBOutlet UIImageView*       imgVwMovieLogo;
    IBOutlet UIImageView*       imgVwPlayMovieIcon;
    IBOutlet UILabel*           lblMovieName;
    IBOutlet UILabel*           lblMovieTime;
}

@property (strong, nonatomic) NSString* strChannelName_en;
@property (strong, nonatomic) NSString* strChannelName_ar;
@property (strong, nonatomic) NSString* strLiveMovie_en;
@property (strong, nonatomic) NSString* strLiveMovie_ar;
@property (assign, nonatomic) BOOL      bLiveVideoPlaying;

@property (strong, nonatomic) NSString* strChannelUrl;
@property (weak, nonatomic) id <ChannelUrlFullScreenModeDelegate> delegate;

+ (id)customView;
- (void)setUIAppearance;
- (void)fetchChannelDetails:(Channel*)objChannel;
- (void)fetchChannelDetailsPlayFromSearch:(NSString*)channelName;
- (void)changeLanguageChannelView;
- (void)fetchChannelDetailsAfterSearch:(SearchLiveNowVideo*)objSearchLiveNowVideo;

@end


@protocol ChannelUrlFullScreenModeDelegate <NSObject>
- (void)playChannelUrlInFullScreenMode:(NSString*)channelUrl;
- (void)updateChannelLogoFromSearch:(NSString*)channelLogo;
@end