//
//  GenreDetailCustomCell.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenreDetailCustomCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIImageView *imgBackground;
@property(nonatomic,retain) IBOutlet UIImageView *imgMovies;
@property(nonatomic,retain) IBOutlet UILabel *lblTime;
@property(nonatomic,retain) IBOutlet UILabel *lblName;
@property(nonatomic,retain) IBOutlet UILabel *lblAbbr;
@end
