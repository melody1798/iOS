//
//  SignUpViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate>
{
    __weak IBOutlet UIImageView *imgLogo;
    __weak IBOutlet UIImageView *imgBackground;
    __weak IBOutlet UIButton *btnDatePicker;
    BOOL checkBoxChecked;
    
    __weak IBOutlet UILabel *lblbGender;
    
    __weak IBOutlet UILabel *lblDateOfBirth;
    
}
@end
