//
//  popoverBackgroundView.m
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 18/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "popoverBackgroundView.h"
#import "Constant.h"

#define CONTENT_INSET 10.0
#define CAP_INSET 25.0
#define ARROW_BASE 25.0
#define ARROW_HEIGHT 25.0

@implementation popoverBackgroundView

@synthesize _borderImageName;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _borderImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:kPopOverImage] resizableImageWithCapInsets:UIEdgeInsetsMake(CAP_INSET,CAP_INSET,CAP_INSET,CAP_INSET)]];
        DLog(@"%@", NSStringFromCGRect(_borderImageView.frame));
          
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
        
      //  [self addSubview:_borderImageView];
     //   [self addSubview:_arrowView];
    }
    return self;
}

+ (BOOL)wantsDefaultContentAppearance {
    return NO;
}

- (void)setBorderImage:(NSString*)borderImageName
{
    _borderImageName = borderImageName;
    [_borderImageView setImage:[UIImage imageNamed:borderImageName]];
}

- (CGFloat) arrowOffset {
    return _arrowOffset;
}

- (void) setArrowOffset:(CGFloat)arrowOffset {
    _arrowOffset = arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
}

+(UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

+(CGFloat)arrowHeight{
    return ARROW_HEIGHT;
}

+(CGFloat)arrowBase{
    return ARROW_BASE;
}

-  (void)layoutSubviews {
    [super layoutSubviews];
    
    DLog(@"%@", NSStringFromCGRect(self.frame));
    
//   CGFloat _height = self.frame.size.height;
//    CGFloat _width = self.frame.size.width;
//    CGFloat _left = 0.0;
//    CGFloat _top = 0.0;
    CGFloat _coordinate = 0.0;
    CGAffineTransform _rotation = CGAffineTransformIdentity;
    
    DLog(@"%d", self.arrowDirection);
    
   // _top += ARROW_HEIGHT;
   // _height -= ARROW_HEIGHT;
    _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
    _arrowView.frame = CGRectMake(_coordinate, 0, ARROW_BASE, ARROW_HEIGHT);

    
    /*switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            _top += ARROW_HEIGHT;
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            _arrowView.frame = CGRectMake(_coordinate, 0, ARROW_BASE, ARROW_HEIGHT);
            break;
            
            
        case UIPopoverArrowDirectionDown:
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            _arrowView.frame = CGRectMake(_coordinate, _height, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI );
            break;
            
        case UIPopoverArrowDirectionLeft:
            _left += ARROW_BASE;
            _width -= ARROW_BASE;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset) - (ARROW_HEIGHT/2);
            _arrowView.frame = CGRectMake(0, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( -M_PI_2 );
            break;
            
        case UIPopoverArrowDirectionRight:
            _width -= ARROW_BASE;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset)- (ARROW_HEIGHT/2);
            _arrowView.frame = CGRectMake(_width, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI_2 );
            
            break;
            
    } */
    
//    /_borderImageView.frame =  CGRectMake(_left, _top, popOverFrame.size.width, popOverFrame.size.height);
    
    
    [_arrowView setTransform:_rotation];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
