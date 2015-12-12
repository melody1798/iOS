//
//  SingerDetailTableViewCell.m
//  MEU-MELODYAPP
//
//  Created by Amandeep Singh 12 on 22/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SingerDetailTableViewCell.h"

@implementation SingerDetailTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [_lblVideoName1 setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [_lblVideoName2 setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
