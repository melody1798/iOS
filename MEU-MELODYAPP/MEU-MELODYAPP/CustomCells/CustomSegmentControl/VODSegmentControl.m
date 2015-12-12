//
//  VODSegmentControl.m
//  MEU-MELODYAPP
//
//  Created by Bharti Sharma on 13/01/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "VODSegmentControl.h"

@implementation VODSegmentControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    int oldValue = self.selectedSegmentIndex;
//    [super touchesBegan:touches withEvent:event];
//    if (oldValue == self.selectedSegmentIndex )
//        [self sendActionsForControlEvents:UIControlEventValueChanged];
//}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    int oldValue = (int)self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
    if (oldValue == self.selectedSegmentIndex)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
