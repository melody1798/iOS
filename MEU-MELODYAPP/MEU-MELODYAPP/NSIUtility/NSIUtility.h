//
//  NSIUtility.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 29/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIUtility : NSObject

+ (void)showAlertView:(NSString*)title message:(NSString*)message;
+ (BOOL)validateEmailWithString:(NSString*)email;

@end
