//
//  VODFeaturedViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//  Animated view for VOD Home screen.

#import <UIKit/UIKit.h>
#import <InfiniteScroll/INFScrollView.h>

@class INFScrollView;

@interface VODFeaturedViewController : UIViewController <INFScrollViewDelegate>
{
    CALayer *transitionLayer;
}

@property (strong, nonatomic) IBOutlet INFScrollView *infiniteScrollView;

@end