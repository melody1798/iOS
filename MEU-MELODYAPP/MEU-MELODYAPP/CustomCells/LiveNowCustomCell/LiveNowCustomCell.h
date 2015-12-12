//
//  LiveNowCustomCell.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveNowCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgLiveNowChannel;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblChannelName;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@end
