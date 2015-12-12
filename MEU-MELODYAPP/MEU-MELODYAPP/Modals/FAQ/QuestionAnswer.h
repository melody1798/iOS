//
//  QuestionAnswer.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionAnswer : NSObject

@property (strong, nonatomic) NSString*     ques_en;
@property (strong, nonatomic) NSString*     ques_ar;
@property (strong, nonatomic) NSString*     ans_en;
@property (strong, nonatomic) NSString*     ans_ar;

- (void)fillDict:(id)info;

@end
