//
//  FlickrInfiniteScrollViewTile.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFScrollViewTile.h"
@class INFNetworkImage;

@protocol ImageConsumer <NSObject>
@optional
- (void)consumeImage:(UIImage *)image animated:(BOOL)animated;
- (void)selectedImage:(int)sender;

@end

@interface INFNetworkImageScrollViewTile : INFScrollViewTile <ImageConsumer, UIGestureRecognizerDelegate>

@property (strong, nonatomic) id <ImageConsumer> delegate;
@property (strong, nonatomic) NSString *movieName;


- (id)init;
- (void)fillTileWithNetworkImage:(INFNetworkImage *)networkImage tag:(NSInteger)tag title:(NSAttributedString*)title;
- (void)consumeImage:(UIImage *)image animated:(BOOL)animated;

@end


