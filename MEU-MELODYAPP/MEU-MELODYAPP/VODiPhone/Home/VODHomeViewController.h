//
//  VODHomeViewController.h
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//VOD featured section movies list.

#import <UIKit/UIKit.h>

@interface VODHomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblVideos;
    __weak IBOutlet UILabel *lblNoVideoFound;
    NSMutableArray *arrRecords;
    
    int intStateChanged;
}
@end
