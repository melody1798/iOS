//
//  CompanyInfoViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//For terms and conditions/privacy policy in settings menu

#import <UIKit/UIKit.h>

@interface CompanyInfoViewController : UIViewController

@property (assign, nonatomic) int      iInfoType;       //Whether privacy policy/terms of conditions

- (void)changeLanguageFromLiveNow;

@end
