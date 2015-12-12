//
//  LastViewedCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Last viewed custom cell.

#import <UIKit/UIKit.h>
#import "LastViewedMovie.h"

@interface LastViewedCell : UICollectionViewCell
{   
    IBOutlet UIImageView*       imgVwThumb;
    IBOutlet UILabel*            lblMovieName;
}

- (void)setCellValues:(LastViewedMovie*)objLastViewedMovie;

@end
