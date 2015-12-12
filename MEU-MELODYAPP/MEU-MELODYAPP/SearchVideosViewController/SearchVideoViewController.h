//
//  SearchVideoViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//  VOD search.

#import <UIKit/UIKit.h>
#import "LiveNowFeaturedVideo.h"
#import "SearchLiveNowVideo.h"

@protocol ChannelProgramPlay;

@interface SearchVideoViewController : UIViewController

@property (assign, nonatomic) NSInteger               iSectionType;  //Type of search(channel-live,upcoming/VOD)
@property (weak, nonatomic) id <ChannelProgramPlay>   delegate;

- (void)handleSearchText:(NSString*)searchString searchCat:(int)searchCat;
-(void)searchInLiveNowFeatured:(NSString*)searchString arrToSearch:(NSArray*)arrLiveNowFeatured;

@end

//To handle search result in viewcontrollers.
@protocol ChannelProgramPlay <NSObject>
@optional
- (void)playSelectedChannelProgram:(NSString*)channelName channelLogo:(NSString*)channelLogo;
- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype;
- (void)playSelectedLiveNowMovie:(NSString*)videoId;
- (void)playSelectedUpcomingChannel:(SearchLiveNowVideo*)objSearchLiveNowVideo;

@end
