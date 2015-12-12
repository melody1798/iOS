//
//  RelatedTableViewCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 16/02/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//
//  Related cell

#import <UIKit/UIKit.h>
#import "Episode.h"
#import "UIImageView+WebCache.h"

@interface RelatedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView*   imgVwRelatedEpisodePrev;
@property (weak, nonatomic) IBOutlet UILabel*       lblEpisodeNumPrev;
@property (weak, nonatomic) IBOutlet UILabel*       lblEpisodeNamePrev;
@property (weak, nonatomic) IBOutlet UIImageView*   imgVwRelatedEpisodeNext;
@property (weak, nonatomic) IBOutlet UILabel*       lblEpisodeNumNext;
@property (weak, nonatomic) IBOutlet UILabel*       lblEpisodeNameNext;
@property (weak, nonatomic) IBOutlet UIButton*      btnPrev;
@property (weak, nonatomic) IBOutlet UIButton*      btnNext;

- (void)setRelatedEpisodesPrev:(Episode*)objEpisode;
- (void)setRelatedEpisodesNext:(Episode*)objEpisode;

@end
