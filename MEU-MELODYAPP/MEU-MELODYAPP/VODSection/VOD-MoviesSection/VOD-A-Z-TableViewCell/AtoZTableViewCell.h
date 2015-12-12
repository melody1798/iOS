//
//  AtoZTableViewCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Custom cells A-Z movies.

#import <UIKit/UIKit.h>
#import "MusicSinger.h"

@interface AtoZTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel*   lblMovieName;
@property (weak, nonatomic) IBOutlet UILabel*   lblMovieDuration;
@property (weak, nonatomic) IBOutlet UILabel*   lblMovieType;

- (NSAttributedString*)setDurationText:(NSString*)str;
- (void)setMusicatoZCellValues:(MusicSinger*)objMusicSinger;

@end

