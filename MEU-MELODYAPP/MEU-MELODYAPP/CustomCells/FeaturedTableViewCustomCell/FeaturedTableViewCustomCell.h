//
//  FeaturedTableViewCustomCell.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedTableViewCustomCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIImageView *imgMovie;
@property(nonatomic,retain) IBOutlet UILabel *lblMovieName;
@property(nonatomic,retain) IBOutlet UILabel *lblEpisodeName;
@property (weak, nonatomic) IBOutlet UILabel *lblSeperator;

@end
