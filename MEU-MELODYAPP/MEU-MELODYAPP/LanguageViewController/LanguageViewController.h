//
//  LanguageViewController.h
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 15/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Change language English/Arabic.

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomUITabBariphoneViewController.h"
#import "CustomNavBar.h"

@protocol LanguageSelectedDelegate;
@interface LanguageViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    __weak IBOutlet UIImageView *imgBackground;
    __weak IBOutlet NSLayoutConstraint *constraintTopSpaceEnglish;
    __weak IBOutlet NSLayoutConstraint *constraintTopSpaceArabic;
    CLLocationManager*     locationManager;
}

@property (weak, nonatomic) id <LanguageSelectedDelegate>   delegate;
@property (assign, nonatomic) BOOL      isFromSettings;

@end

@protocol LanguageSelectedDelegate <NSObject>

- (void)changeLanguageMethod;

@end
