//
//  VODCategoryViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//Category screen to list categories like Movies/Series/Music/Collections.

#import <UIKit/UIKit.h>
@interface VODCategoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UILabel *lblCategories;
    __weak IBOutlet UITableView *tblCategories;
    __weak IBOutlet UIView *vwheader;
    NSMutableArray *arrCategories;
}
@end
