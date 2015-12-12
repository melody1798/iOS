//
//  QuestionAnswers.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionAnswers : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
    int         iInfoType;
}

@property (strong, nonatomic) NSMutableArray*   arrQuesAns;

- (void)fetchFAQInformation:(id)target selector:(SEL)selector isArb:(NSString*)isArb;

@end
