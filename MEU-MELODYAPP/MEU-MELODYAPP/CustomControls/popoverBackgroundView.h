//
//  popoverBackgroundView.h
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 18/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Pop over background For Genres/Channels/Search/Settings etc.

#import <UIKit/UIKit.h>

@interface popoverBackgroundView : UIPopoverBackgroundView
{
    UIImageView *_borderImageView;
    UIImageView *_arrowView;
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
    CGRect popOverFrame;
}

@property (strong, nonatomic) NSString*    _borderImageName;

- (void)setBorderImage:(NSString*)borderImageName;

@end
