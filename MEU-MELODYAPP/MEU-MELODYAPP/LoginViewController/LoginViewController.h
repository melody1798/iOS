//
//  LoginViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Login functionality on MEU/login with facebook

#import <UIKit/UIKit.h>

@protocol UpdateMovieDetailOnLoginDelegate;

@interface LoginViewController : UIViewController
{
    __weak IBOutlet UILabel *lblOr;
}
@property (nonatomic) id delegate;
@property (nonatomic) SEL selector;
@property (weak, nonatomic) id <UpdateMovieDetailOnLoginDelegate> delegateUpdateMovie;

@end

@protocol UpdateMovieDetailOnLoginDelegate <NSObject>
@optional
- (void)updateMovieDetailViewAfterLogin;
@end
