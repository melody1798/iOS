//
//  QuestionAnswer.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 20/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "QuestionAnswer.h"

@implementation QuestionAnswer

@synthesize ques_en, ques_ar;
@synthesize ans_en, ans_ar;

- (void)fillDict:(id)info
{
    ques_en = [info objectForKey:@"DescriptionEng"];
    ques_ar = [info objectForKey:@"DescriptionArabic"];
    ans_en = [[[info objectForKey:@"FAQAnswers"] objectAtIndex:0] objectForKey:@"DescriptionEng"];
    ans_ar = [[[info objectForKey:@"FAQAnswers"] objectAtIndex:0] objectForKey:@"DescriptionArabic"];
}

@end
