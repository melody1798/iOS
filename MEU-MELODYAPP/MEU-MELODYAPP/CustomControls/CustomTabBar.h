//
//  CustomTabBar.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 24/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Custom tab bar for iPad

#import <UIKit/UIKit.h>

@protocol tabbarIndexDelegate;

@interface CustomTabBar : UITabBarController
{
    UISegmentedControl *segmentedControl;
}

//@property (weak, nonatomic) id<tabbarIndexDelegate> delegate;
@property (strong, nonatomic) UISegmentedControl *segmentProperty;

@end

@protocol tabbarIndexDelegate <NSObject>

- (void)setTabBarIndex:(int)selectedSegmentIndex;

@end