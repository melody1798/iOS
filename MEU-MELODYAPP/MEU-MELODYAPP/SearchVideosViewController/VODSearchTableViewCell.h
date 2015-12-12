//
//  VODSearchTableViewCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/01/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//
// VOD search table view cell layout.

#import <UIKit/UIKit.h>
#import "SearchLiveNowVideo.h"

@protocol CellSelection;

@interface VODSearchTableViewCell : UITableViewCell
{
    IBOutlet UIImageView*       imgVwVideo;
    IBOutlet UILabel*           lblMovieName;
    IBOutlet UILabel*           lblDuration;
    IBOutlet UILabel*           lblDesc;
    IBOutlet UIButton*          btnTap;
}

@property (strong, nonatomic) IBOutlet UIButton*          btnTap;
@property (weak, nonatomic) id <CellSelection>  delegate;
- (void)setVODSearchValue:(SearchLiveNowVideo*)objSearchLiveNowVideo;
- (IBAction)btnTap:(id)sender;

@end

@protocol CellSelection <NSObject>
- (void)searchCellSelected:(NSInteger)row;
@end
