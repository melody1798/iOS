//
//  CompanyInfo.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CompanyInfo.h"
#import "ServerConnection.h"
#import "RequestBuilder.h"
#import "NSIUtility.h"

@implementation CompanyInfo

@synthesize companyInfo;
@synthesize companyLogoUrl;

- (void)fetchCompanyInformation:(id)target selector:(SEL)selector isArb:(NSString*)isArb infoType:(int)infoType
{
    iInfoType = infoType;
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?isArb=%@", kBaseUrl, kCompanyInfo, isArb]];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverCompanyInfoResponse:)];
}

- (void)serverCompanyInfoResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
        if ([[responseDict objectForKey:@"Response"] objectForKey:@"LogoUrl"] == (id)[NSNull null])
            
            self.companyLogoUrl = @"";
        else
            self.companyLogoUrl = [[responseDict objectForKey:@"Response"] objectForKey:@"LogoUrl"];
        
        
        if (iInfoType == (int)companyPrivacyPolicy)
        {
            if ([[responseDict objectForKey:@"Response"] objectForKey:@"PrivacyPolicy"] == (id) [NSNull null])
                
                self.companyInfo = @"";
            else
                self.companyInfo = [[responseDict objectForKey:@"Response"] objectForKey:@"PrivacyPolicy"];
        }
        
        else{
            if ([[responseDict objectForKey:@"Response"] objectForKey:@"TermsConditions"] == (id) [NSNull null])
                
                self.companyInfo = @"";
            else
                self.companyInfo = [[responseDict objectForKey:@"Response"] objectForKey:@"TermsConditions"];
        }
    }
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self waitUntilDone:NO];
}

- (void)sendFeedback:(id)target selector:(SEL)selector parmeters:(NSDictionary*)requestParameters
{
    _delegate = target;
    _eventHandler = selector;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kBaseUrl, kSendFeedback];
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:requestParameters
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"POST" parameters:jsonString];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverFeedbackResponse:)];
}

- (void)serverFeedbackResponse:(NSMutableData*)responseData
{
    NSError *error;
    
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    
    if ([[responseDict objectForKey:@"Error"] integerValue] == 0) {
        [NSIUtility showAlertView:nil message:@"Feedback sent successfully"];
    }
    [_delegate performSelectorOnMainThread:_eventHandler withObject:[responseDict objectForKey:@""] waitUntilDone:NO];
}

@end