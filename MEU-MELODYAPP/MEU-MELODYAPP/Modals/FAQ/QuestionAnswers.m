//
//  QuestionAnswers.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "QuestionAnswers.h"
#import "ServerConnection.h"
#import "Constant.h"
#import "RequestBuilder.h"
#import "QuestionAnswer.h"

@implementation QuestionAnswers

@synthesize arrQuesAns;

- (void)fetchFAQInformation:(id)target selector:(SEL)selector isArb:(NSString*)isArb
{
    _delegate = target;
    _eventHandler = selector;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseUrl, kFAQInfo]];
    
    NSMutableURLRequest *request = [RequestBuilder request:url requestType:@"GET" parameters:nil];
    
    ServerConnection *objServerConnection = [[ServerConnection alloc] init];
    [objServerConnection serverConnection:request target:self selector:@selector(serverFAQInfoResponse:)];
}

- (void)serverFAQInfoResponse:(NSMutableData*)responseData
{
    NSError *error;
    //Convert response data into JSON format.
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    DLog(@"%@", responseDict);
    if ([[responseDict objectForKey:@"Error"] intValue] == 0) {
        
        [self fillInfo:[responseDict objectForKey:@"Response"]];
    }
}

- (void)fillInfo:(NSArray*)arrResponse
{
    self.arrQuesAns = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrResponse count]; i++) {
        QuestionAnswer *objQuestionAnswer = [QuestionAnswer new];
        [objQuestionAnswer fillDict:[arrResponse objectAtIndex:i]];
        
        [self.arrQuesAns addObject:objQuestionAnswer];
    }
    
    [_delegate performSelectorOnMainThread:_eventHandler withObject:self.arrQuesAns waitUntilDone:NO];
}

@end