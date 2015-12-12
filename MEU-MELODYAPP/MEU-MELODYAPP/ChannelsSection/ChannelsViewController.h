//
//  ChannelsViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// List of channels

#import <UIKit/UIKit.h>
#import "Channel.h"

@protocol RowSelectionFromPopOverViewDelegate;

@interface ChannelsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<RowSelectionFromPopOverViewDelegate> delegate;

@end

@protocol RowSelectionFromPopOverViewDelegate <NSObject>
- (void)returnTableViewSelectedRow:(Channel*)objChannel;
@end