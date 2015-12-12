//
//  FlickrInfiniteScrollViewTile.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFNetworkImageScrollViewTile.h"
#import "INFNetworkImage.h"
#import <QuartzCore/QuartzCore.h>

#define BORDER_WIDTH        7

@interface INFNetworkImageScrollViewTile()

@property (nonatomic, readwrite, strong) INFNetworkImage *networkImage;
@property (nonatomic, strong) UIImageView*   imageView;
@property (nonatomic, readwrite, strong) UILabel*       lblMovieName;
@property (nonatomic, strong) UIImageView*   imgVwTitleBg;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIButton *btnTap;

@end

@implementation INFNetworkImageScrollViewTile

@synthesize imageView = _imageView;
@synthesize networkImage = _networkImage;
@synthesize movieName;

- (id)init
{
    if (self = [super init])
    {
        //147, 155
        [_imageView removeFromSuperview];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 174)];
        _imageView.image = [UIImage imageNamed:@"blackPlaceholder"];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        super.layer.borderColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0].CGColor;
        super.layer.borderWidth = BORDER_WIDTH;
        super.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.exclusiveTouch = YES;
        
        [self addSubview:_imageView];
        
        [_imgVwTitleBg removeFromSuperview];
        _imgVwTitleBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 130, 280, 35)];
        _imgVwTitleBg.image = [UIImage imageNamed:@"movies_featured_title_bg.png"];
        _imgVwTitleBg.backgroundColor = [UIColor clearColor];
        [self addSubview:_imgVwTitleBg];
        
        [_lblMovieName removeFromSuperview];
        _lblMovieName = [[UILabel alloc] initWithFrame:CGRectMake(15, 128, 275, 40)];
        _lblMovieName.backgroundColor = [UIColor clearColor];
        _lblMovieName.textColor = [UIColor whiteColor];
        _lblMovieName.numberOfLines = 2;
        
        _lblMovieName.font = [UIFont fontWithName:@"ProximaNova-Bold" size:16.0];
        [self addSubview:_lblMovieName];
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPrevious:)];
        _tap.delegate = self;
        _tap.numberOfTapsRequired = 1;
        _tap.numberOfTouchesRequired = 1;
        _tap.cancelsTouchesInView = NO;
        
        [_imageView addGestureRecognizer:_tap];
        //    [super setUserInteractionEnabled:YES];
    }
    return self;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    
//    return YES;
//}

- (void)goToPrevious:(UITapGestureRecognizer*)recognizer
{
    if ([_delegate respondsToSelector:@selector(selectedImage:)]) {
        [_delegate selectedImage:(int)recognizer.view.tag];
    }
}

- (void)fillTileWithNetworkImage:(INFNetworkImage *)networkImage tag:(NSInteger)tag title:(NSAttributedString*)title
{
    self.imageView.tag = tag;
    _imageView.image = [UIImage imageNamed:@"blackPlaceholder"];
    _lblMovieName.text = @"";
    self.networkImage = networkImage;
    _lblMovieName.attributedText = title;
    [self.imageView setUserInteractionEnabled:YES];
    self.imageView.exclusiveTouch = YES;
    
    for (UIGestureRecognizer * gestureRecognizer in [self gestureRecognizers]) {
		if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            
			[gestureRecognizer setEnabled:YES];
		}
	}
    _tap.enabled = YES;
}

- (void)setNetworkImage:(INFNetworkImage *)networkImage
{
    [self.networkImage unhookImageConsumer:self];
    _networkImage = networkImage;
    [networkImage fetchImageForImageConsumer:self];
}

- (void)consumeImage:(UIImage *)image animated:(BOOL)animated
{
    if (self.networkImage.image != image)
    {
        return;
    }

//    if (image && self.imageView.alpha != (!animated))
//    {
//        self.imageView.alpha = !animated;
//    }
    _imageView.image = [UIImage imageNamed:@"blackPlaceholder"];

    self.imageView.image = image;
//    if (animated && self.imageView.alpha != 1.0)
//    {
//        [UIView animateWithDuration:.4 animations:^
//        {
//            self.imageView.alpha = 1.0;
//        }];
//    }
}

- (CGSize)requestingSize
{
    return self.imageView.image.size;
}

- (BOOL)isSelectable
{
   // return self.imageView.image != nil;
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//}

@end