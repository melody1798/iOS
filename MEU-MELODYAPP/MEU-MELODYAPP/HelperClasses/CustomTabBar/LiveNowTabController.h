//
//  LiveNowTabController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/02/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUITabBariphoneViewController.h"

@interface LiveNowTabController : UITabBarController <UITabBarControllerDelegate>
{
    __weak IBOutlet UITabBar *tabBar;
    UISegmentedControl *segmentedControl;
}

@end
