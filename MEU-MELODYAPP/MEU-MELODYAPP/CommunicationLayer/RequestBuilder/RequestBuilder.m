//
//  RequestBuilder.m
//  MVCDemo
//
//  Created by Nancy Kashyap on 1/15/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "RequestBuilder.h"
#import "Constant.h"

@implementation RequestBuilder

+ (NSMutableURLRequest*)request:(NSURL*)requestUrl requestType:(NSString*)requestType parameters:(NSString*)parameterStr
{
   // NSURL *url=[NSURL URLWithString:requestUrl];
    
    DLog(@"Url %@", url);
    DLog(@"%@", parameterStr);
    
    NSString *postLength=@"";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:requestUrl];
    
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults]valueForKey:kAccessTokenKey];
    
    [request setValue:accessToken forHTTPHeaderField:@"AuthToken"];
    
    [request setValue:@"Fiddler" forHTTPHeaderField:@"User-Agent"];
    [request setValue:KApiBaseurl forHTTPHeaderField:@"Host"];
    
    [request setValue:@"c5439ABc-61c5-492e-b24o-99887399d80b" forHTTPHeaderField:@"appcode"];
    
    if([requestType isEqualToString:@"POST"])
    {
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

        NSData *postData = [parameterStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
      //  postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
    }
    else
    {
        [request setHTTPMethod:@"GET"];
    }
    [request setValue:@"Origin" forHTTPHeaderField:@"Origin"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

@end