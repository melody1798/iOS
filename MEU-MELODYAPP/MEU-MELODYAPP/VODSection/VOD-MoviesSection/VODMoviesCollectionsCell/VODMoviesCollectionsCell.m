//
//  VODMoviesCollectionsCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 28/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODMoviesCollectionsCell.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@implementation VODMoviesCollectionsCell

@synthesize lblCollectionName;
@synthesize imgVwCollection;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellValues:(MoviesCollection*)objMoviesCollection
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.fImageWidth = self.imgVwCollection.frame.size.width;
    appdelegate.fImageHeight = self.imgVwCollection.frame.size.height;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblCollectionName.text = objMoviesCollection.collectionName_en;
    else
        lblCollectionName.text = objMoviesCollection.collectionName_ar;

    lblCollectionName.textColor = [UIColor whiteColor];
    lblCollectionName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
    [imgVwCollection sd_setImageWithURL:[NSURL URLWithString:objMoviesCollection.collectionThumb] placeholderImage:nil];
}

#pragma -mark Calculate The Width Of label
- (CGRect) getTextWidth:(NSString*)str atFont:(UIFont*)font AndFrame:(CGRect)frame
{
    CGSize constrainedSize = CGSizeMake(9999,frame.size.height);
    CGRect textRect = [str boundingRectWithSize:constrainedSize
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:font }
                                        context:nil];
    CGSize requiredHeight = textRect.size;
    
    int reqHeight=requiredHeight.width;
    int orignalHeight=frame.size.width;
    
    CGRect newFrame =frame;
    
    if (reqHeight> orignalHeight){
        requiredHeight = CGSizeMake(frame.size.width, requiredHeight.height);
        newFrame=CGRectMake(frame.origin.x, frame.origin.y,requiredHeight.width, requiredHeight.height);
    }
    
    DLog(@"%@", NSStringFromCGRect(newFrame));
    
    return  newFrame;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

@end