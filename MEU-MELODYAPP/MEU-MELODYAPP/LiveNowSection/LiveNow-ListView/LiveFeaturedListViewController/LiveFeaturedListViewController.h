//
//  LiveFeaturedListViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Live videos show in list view pop over iPad.

#import <UIKit/UIKit.h>

@protocol videoPlayLiveList;

@interface LiveFeaturedListViewController : UIViewController

@property (strong, nonatomic) NSArray*       _arrayLiveVideos;
@property (weak, nonatomic) id <videoPlayLiveList>  delegate;

@end

@protocol videoPlayLiveList <NSObject>

- (void)playVideoOnListView:(NSString*)videoUrl;

@end
