//
//  MoviesDetailViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Show movie/series/episodes detail content.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class LoginViewController;
@interface MoviesDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    __weak IBOutlet UILabel *lblMovie;
    __weak IBOutlet UISegmentedControl *segmentControl;
    __weak IBOutlet UITableView *tblCastAndCrew;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UIView *previewView;
    __weak IBOutlet UIView *previewSubView;
    __weak IBOutlet UILabel *lblMovieName;
    __weak IBOutlet UILabel *lblMovieDuration;
    __weak IBOutlet UILabel *lblMovieDurationMiddle;
    __weak IBOutlet UILabel *lblMovieDurationRight;
    __weak IBOutlet UIButton *btnAddtoWatchList;
    __weak IBOutlet UIButton *btnPlay;
    __weak IBOutlet UIButton *btnRelated;

    NSMutableArray *arrProducers;
    NSMutableArray *arrCastAndCrew;
    NSString *description;
    LoginViewController*    objLoginViewController;
    int numberOfSections;
    int loginCheck;
}

@property(nonatomic,retain)  IBOutlet UIWebView *wbVwMovie;
@property (nonatomic,retain) IBOutlet UIImageView *imgMovieName;
@property (nonatomic,retain) NSString *movieId;
@property (nonatomic,retain) NSString *movieName;
@property (nonatomic,retain) NSString *movieThumbnail;
@property (nonatomic,retain) NSString *_episodeDesc;
@property (strong, nonatomic) NSString*     strMovieUrl;
@property (strong, nonatomic) NSString*     strEpisodeDuration;
@property (strong, nonatomic) NSString*     strSingerId;
@property (strong, nonatomic) NSString*     strEpisodeId;
@property (strong, nonatomic) NSString*     strSeasonNum;
@property (strong, nonatomic) NSString*     strSeriesName;

@property (strong, nonatomic) NSArray*      _arrEpisodes;
@property (assign, nonatomic) NSInteger     selectedEpisodeIndex;
@property (assign, nonatomic) NSInteger     videoType;

@property (assign, nonatomic) BOOL          relatedCheckFromWatchList;
@property (assign, nonatomic) BOOL          isFromCollection;
@property (assign, nonatomic) BOOL          isFromSearch;

@property (nonatomic) int typeOfDetail;
@property (assign, nonatomic) BOOL isMusic;
@property (assign, nonatomic) BOOL isSeries;

@end