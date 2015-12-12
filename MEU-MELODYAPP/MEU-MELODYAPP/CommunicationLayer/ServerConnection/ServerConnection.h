//
//  ServerConnection.h
//  MVCDemo
//
//  Created by Nancy Kashyap on 1/15/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface ServerConnection : NSObject <NSURLConnectionDelegate>
{
    id              _delegate;
    SEL             _handler;
    NSMutableData*  responseData;
    AppDelegate *objAppdelegate;
}

@property (retain, nonatomic) NSMutableData*  responseData;

//Methods
- (void)serverConnection:(NSMutableURLRequest*)connection target:(id)target selector:(SEL)selector;

@end
