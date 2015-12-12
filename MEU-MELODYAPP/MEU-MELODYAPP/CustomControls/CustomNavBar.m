//
//  CustomNavBar.m
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 17/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CustomNavBar.h"
#import "Constant.h"
#import "CommonFunctions.h"

@implementation CustomNavBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupAppearance];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupAppearance];
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    NSString *imageName = @"";
    
    imageName = [CommonFunctions isIphone] ? kNavigationBarImageNameiPhone:kNavigationBarImageName_ios6;

    if (!IS_IOS7_OR_LATER && ![CommonFunctions isIphone]){
        
        imageName = @"NavBar_ios6_ipad";

        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 0);
        self.layer.shadowOpacity = 0.0;
        self.layer.masksToBounds = YES;
        self.layer.shouldRasterize = NO;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, [CommonFunctions isIphone]? kAppNavBarHeightForIphone :self.frame.size.height)];
    
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setupAppearance {
    
    static BOOL appearanceInitialised = NO;
    
    if (!appearanceInitialised) {
        
        // Update the appearance of this bar to shift the icons back up to their normal position
        
        CGFloat offset = 44 - ([CommonFunctions isIphone] ? kAppNavBarHeightForIphone:kAppNavBarHeight);
        
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundVerticalPositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundVerticalPositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, offset) forBarMetrics:UIBarMetricsDefault];
        
        appearanceInitialised = YES;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    return CGSizeMake(self.superview.frame.size.width, [CommonFunctions isIphone] ? kAppNavBarHeightForIphone:kAppNavBarHeight);
}

- (void)layoutSubviews {
    
    static CGFloat yPosForArrow = -1;
    
    [super layoutSubviews];
    
    // There's no official way to reposition the back button's arrow under iOS 7. It doesn't shift with the title.
    // We have to reposition it here instead.
    
    for (UIView *view in self.subviews) {
        
        // The arrow is a class of type _UINavigationBarBackIndicatorView. We're not calling any private methods, so I think
        // this is fine for the AppStore...
        
        if ([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarBackIndicatorView"]) {
            CGRect frame = view.frame;
            
            if (yPosForArrow < 0) {
                
                // On the first layout we work out what the actual position should be by applying our offset to the default position.
                
                yPosForArrow = frame.origin.y + (44 - ([CommonFunctions isIphone] ? kAppNavBarHeightForIphone:kAppNavBarHeight));
            }
            
            // Update the frame.
            frame.origin.y = -90;
            view.frame = frame;
        }
    }
}

@end