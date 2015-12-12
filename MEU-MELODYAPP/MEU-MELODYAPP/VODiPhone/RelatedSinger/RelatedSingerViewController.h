//
//  RelatedSingerViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 28/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
//To set related data for Music/Episodes.

#import <UIKit/UIKit.h>

@protocol MovieDetailFromRelatedSingers <NSObject>
- (void)fetchMovieDetailFromRelatedSinger:(NSString*)movieId;
@end

@interface RelatedSingerViewController : UIViewController

@property (strong, nonatomic) NSString*     singerId;
@property (weak, nonatomic) id <MovieDetailFromRelatedSingers> delegate;

@end
