//
//  SettingViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 09/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Show settings menu.

#import <UIKit/UIKit.h>

@protocol SettingsDelegate;
@class LoginViewController;
@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblSettings;
    __weak IBOutlet UILabel *lblHeader;
    LoginViewController *objLoginViewController;
}

@property (weak, nonatomic) id <SettingsDelegate> delegate;
@end

@protocol SettingsDelegate <NSObject>

@optional
- (void)userSucessfullyLogout;
- (void)changeLanguage;
- (void)loginUser;
- (void)companyInfoSelected:(int)infoType;
- (void)sendFeedback;
- (void)FAQCallBackMethod;

@end
