//
//  RequestBuilder.h
//  MVCDemo
//
//  Created by Nancy Kashyap on 1/15/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestBuilder : NSObject


+ (NSMutableURLRequest*)request:(NSURL*)requestUrl requestType:(NSString*)requestType parameters:(NSString*)parameterStr;

@end
