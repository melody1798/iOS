//
//  LoginUserInfo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 29/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUserInfo : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
    NSString*   accessToken;
    NSString*   email;
    NSString*   firstName;
    NSString*   lastName;
    NSString*   userId;
}

@property (strong, nonatomic) NSString*   accessToken;
@property (strong, nonatomic) NSString*   email;
@property (strong, nonatomic) NSString*   firstName;
@property (strong, nonatomic) NSString*   lastName;
@property (strong, nonatomic) NSString*   userId;

- (void)loginUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;
- (void)ForgotPassword:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;
- (void)logoutUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;
-(void) fillNSUserDefaults:(NSDictionary*)dictResponse;
@end
