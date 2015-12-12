//
//  CustomPopOverView.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RowSelectionFromPopOverViewDelegate;

@interface CustomPopOverView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView*  tableVw;
@property (weak, nonatomic) IBOutlet UIImageView* imgVwPopOver;
@property (weak, nonatomic) id<RowSelectionFromPopOverViewDelegate> delegate;
+ (id)customView;

@end

@protocol RowSelectionFromPopOverViewDelegate <NSObject>

- (void)returnTableViewSelectedRow:(NSInteger)rowIndex;

@end
