//
//  FeedbackViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 24/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// To send feedback  in settings menu


#import <UIKit/UIKit.h>

@protocol CancelFeedbackFormDelegate <NSObject>
- (void)cancelSendingFeedback;
@end

@interface FeedbackViewController : UIViewController

@property (weak, nonatomic) id <CancelFeedbackFormDelegate> delegate;

@end
