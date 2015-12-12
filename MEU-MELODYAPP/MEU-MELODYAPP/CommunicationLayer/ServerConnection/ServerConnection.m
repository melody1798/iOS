//
//  ServerConnection.m
//  MVCDemo
//
//  Created by Nancy Kashyap on 1/15/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "ServerConnection.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"

@implementation ServerConnection

@synthesize responseData;

- (void)serverConnection:(NSMutableURLRequest*)request target:(id)target selector:(SEL)selector
{
    _delegate = target;
    _handler = selector;
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [MBProgressHUD hideAllHUDsForView:objAppdelegate.navigationController.visibleViewController.view animated:YES];
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
        return;
    }
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                            delegate:self];
    [conn start];
    objAppdelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:objAppdelegate.navigationController.visibleViewController.view animated:YES];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [MBProgressHUD hideAllHUDsForView:objAppdelegate.navigationController.visibleViewController.view animated:YES];
    [_delegate performSelector:_handler withObject:responseData afterDelay:0.0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:objAppdelegate.navigationController.visibleViewController.view animated:YES];
    [CommonFunctions showAlertView:kServerErrorMessage TITLE:kEmptyString Delegate:Nil];
}

@end