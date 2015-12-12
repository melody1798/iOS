//
//  VODSearchViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Show VOD search result content.

#import <UIKit/UIKit.h>

@interface VODSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    __weak IBOutlet UITableView *tblSearch;
    __weak IBOutlet UITextField *txtSearch;
    __weak IBOutlet UIView *searchView;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UILabel *lblHeaderSearch;
    __weak IBOutlet UILabel *lblNoVideoFound;
    __weak IBOutlet UILabel *lblCancel;
    NSMutableArray *arrSearch;
    NSMutableArray *arrAlphabets;
    UITextField *txt;
}
@end
