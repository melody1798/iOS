//
//  AppDelegate.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GAI.h"
#import "AppsFlyerTracker.h"

@class PlayerOverlay;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{
    int                         iWatchListCounter;
    float                       fImageWidth;
    float                       fImageHeight;
    CLLocationManager*          locationManager;
    NSTimeInterval              videoStartTime;
    
    int intOrientation;
    PlayerOverlay *objPlayerOverlay;
}

@property(nonatomic, strong) PlayerOverlay *objPlayerOverlay;
@property (assign, nonatomic) int intOrientation;

@property (assign, nonatomic) int iWatchListCounter;
@property (assign, nonatomic) float fImageWidth;
@property (assign, nonatomic) float fImageHeight;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController*   navigationController;
@property (strong, nonatomic) UITabBarController*       tabBarController;

@property (readonly, strong, nonatomic) NSMutableArray *arrayOfAlphabets;
@property (readonly, strong, nonatomic) NSMutableArray *arrayOfAlphabets_ar;

@property (assign, nonatomic) BOOL              isEnableOrientation;
@property (assign, nonatomic) BOOL              isFromSearch;
@property (assign, nonatomic) NSString*         channelName;
@property (assign, nonatomic) NSTimeInterval    videoStartTime;
@property (assign, nonatomic) NSTimeInterval    videoTotalTime;

@property (assign, nonatomic) BOOL              isConnectedToDevice;


- (NSURL *)applicationDocumentsDirectory;

-(void)checkOrientation:(int)intOrientation1;

@end
