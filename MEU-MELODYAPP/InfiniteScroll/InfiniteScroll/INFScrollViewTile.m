//
//  InfiniteScrollViewTile.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFScrollViewTile.h"

@implementation INFScrollViewTile

@synthesize senderTag;

- (id)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)settag:(NSInteger)tag
{
    senderTag = tag;
}

- (CGSize)requestingSize
{
    return CGSizeZero;
}

- (BOOL)isSelectable
{
    return YES;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}

@end