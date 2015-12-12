//
//  CustomUITabBariphoneViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;
@class SettingViewController;
@interface CustomUITabBariphoneViewController : UITabBarController<UITabBarControllerDelegate>
{
    __weak IBOutlet UITabBar *tabBar;
    LoginViewController *objLoginViewController;
    int lastSelectedIndex;
    UITabBarController*             tabController;
    UISegmentedControl *segmentedControl;
    UITabBarController*             tabControllerLiveNow;
}

- (void)setTabItemsText;

@end
