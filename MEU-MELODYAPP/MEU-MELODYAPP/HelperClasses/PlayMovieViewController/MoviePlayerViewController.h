//
//  MoviePlayerViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ConnectSDK/ConnectSDK.h>
#import <ConnectSDK/AirPlayService.h>

@interface MoviePlayerViewController : UIViewController <DevicePickerDelegate, ConnectableDeviceDelegate>
{
    DiscoveryManager *_discoveryManager;
    ConnectableDevice *_device;
}

@property(nonatomic,retain) IBOutlet UIBarButtonItem *barButtonItem;
@property (strong, nonatomic) NSString*     strVideoUrl;
@property (strong, nonatomic) NSString*     strVideoId;

@end
