//
//  SignUpUser.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 29/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignUpUser : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

- (void)signUpUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;
- (void)signUpFacebookUser:(id)target selector:(SEL)selector parameters:(NSDictionary*)requestParameters;

@end
