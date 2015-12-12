//
//  CompanyInfo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyInfo : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
    int         iInfoType;
}

@property (strong, nonatomic) NSString*     companyLogoUrl;
@property (strong, nonatomic) NSString*     companyInfo;

- (void)fetchCompanyInformation:(id)target selector:(SEL)selector isArb:(NSString*)isArb infoType:(int)infoType;
- (void)sendFeedback:(id)target selector:(SEL)selector parmeters:(NSDictionary*)requestParameters;

@end
