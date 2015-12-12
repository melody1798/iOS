//
//  MelodyHitsCustomCell.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 20/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MelodyHitsCustomCell.h"
#import "CommonFunctions.h"

@implementation MelodyHitsCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    [self setFont];
}

#pragma mark - Setfonts
-(void) setFont
{
    [_lblChannelName setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [_lblTime setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [self setBackgroundColor:color_Background];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChannelSetValue:(UpcomingVideo*)objUpcomingVideo
{
    NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objUpcomingVideo.upcomingDay];
    
    self.lblTime.text = [convertedTime uppercaseString];
    
    if ([CommonFunctions isEnglish])
        self.lblChannelName.text = objUpcomingVideo.upcomingVideoName_en;
    
    else
        self.lblChannelName.text = objUpcomingVideo.upcomingVideoName_ar;
}

@end
