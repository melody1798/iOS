//
//  LoginUserInfo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 29/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LoginUserInfo.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "ServerConnection.h"
#import "NSIUtility.h"

@implementation LoginUserInfo

@synthesize email, userId, accessToken,firstName, lastName;

- (void)loginUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseUrl, kLoginService]];
    
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

- (void)ForgotPassword:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseUrl, kForgorPasswordService]];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConn = [[ServerConnection alloc] init];
    [objServerConn serverConnection:request target:self selector:@selector(passwordServerResponse:)];
}

- (void)logoutUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseUrl, kLogoutService]];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConn = [[ServerConnection alloc] init];
    [objServerConn serverConnection:request target:self selector:@selector(logoutServerResponse:)];
}

- (void)logoutServerResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
     if ([[responseDict objectForKey:@"Error"] intValue] == 0) {

         [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
     }
     else {
         
         if([[responseDict valueForKey:@"Message"] rangeOfString:@"doest not exist"].location != NSNotFound) {
             [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
         }
     }
}

- (void)passwordServerResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    // if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
    [NSIUtility showAlertView:nil message:[responseDict objectForKey:@"Message"]];
    // }
}

- (void)serverResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        [self fillUserInfo:[responseDict objectForKey:@"Response"]];
    }
    else{
        [NSIUtility showAlertView:nil message:[responseDict objectForKey:@"Message"]];
        [_delegate performSelectorOnMainThread:_eventHandler withObject:responseDict waitUntilDone:NO];
    }
}

- (void)fillUserInfo:(NSDictionary*)dictResponse
{
    self.email = [dictResponse objectForKey:@"Email"];
    self.firstName = [dictResponse objectForKey:@"FirstName"];
    self.lastName = [dictResponse objectForKey:@"LastName"];
    self.userId = [dictResponse objectForKey:@"UserID"];
    self.accessToken = [dictResponse objectForKey:@"AccessToken"];
    
    [self fillNSUserDefaults:dictResponse];
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:dictResponse waitUntilDone:NO];
}


#pragma mark - Fill NSUserdefaults
-(void) fillNSUserDefaults:(NSDictionary*)dictResponse
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[dictResponse objectForKey:@"AccessToken"] forKey:kAccessTokenKey];
    [defaults setObject:[dictResponse objectForKey:@"UserID"] forKey:kUserIDKey];
    [defaults setObject:[NSString stringWithFormat:@"%@ %@",[dictResponse objectForKey:@"FirstName"],[dictResponse objectForKey:@"LastName"]] forKey:kUserNameKey];
    
    [defaults synchronize];
}

@end