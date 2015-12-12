//
//  NSIUtility.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 29/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "NSIUtility.h"
#import "CommonFunctions.h"

@implementation NSIUtility

+ (void)showAlertView:(NSString*)title message:(NSString*)message
{
    UIAlertView *alertVw = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"ok" value:@"" table:nil] otherButtonTitles:nil, nil];
    [alertVw show];
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
