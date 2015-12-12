//
//  SignUpUser.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 29/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SignUpUser.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "NSIUtility.h"
#import "LoginUserInfo.h"

@implementation SignUpUser

- (void)signUpUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseUrl, kSignUpService]];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];

    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverResponse:)];
}

- (void)serverResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
       // [self fillUserInfo:[responseDict objectForKey:@"Response"]];
        [NSIUtility showAlertView:nil message:[responseDict objectForKey:@"Message"]];
        [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
    }
    else{
        [NSIUtility showAlertView:nil message:[responseDict objectForKey:@"Message"]];
        [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
    }
}

- (void)fillUserInfo:(NSDictionary*)dictResponse
{
    LoginUserInfo *objLoginUserInfo = [LoginUserInfo new];
    objLoginUserInfo.email = [dictResponse objectForKey:@"Email"];
    objLoginUserInfo.firstName = [dictResponse objectForKey:@"FirstName"];
    objLoginUserInfo.lastName = [dictResponse objectForKey:@"LastName"];
    objLoginUserInfo.userId = [dictResponse objectForKey:@"UserID"];
    objLoginUserInfo.accessToken = [dictResponse objectForKey:@"AccessToken"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kAccessTokenKey])
    {
        [objLoginUserInfo fillNSUserDefaults:dictResponse];
    }

    [_delegate performSelectorOnMainThread:_eventHandler withObject:dictResponse waitUntilDone:NO];
}

- (void)signUpFacebookUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseUrl, kSignUpService]];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
        
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConn = [[ServerConnection alloc] init];
    [objServerConn serverConnection:request target:self selector:@selector(serverResponseFacebook:)];
}

- (void)serverResponseFacebook:(NSMutableData*)responseData
{
    NSError *error;
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0 && [responseDict objectForKey:@"Response"] != (id)[NSNull null]) {
        [self fillUserInfo:[responseDict objectForKey:@"Response"]];
    }
    else{
        [NSIUtility showAlertView:nil message:[responseDict objectForKey:@"Message"]];
        [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
    }
}

@end