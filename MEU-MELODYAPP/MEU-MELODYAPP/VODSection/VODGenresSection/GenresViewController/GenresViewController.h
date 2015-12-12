//
//  GenresViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
// Show genres movies/series/music.

#import <UIKit/UIKit.h>

@protocol genreSelectedDelegate;

@interface GenresViewController : UIViewController

@property (strong, nonatomic) NSString*         strSectionType;
@property (weak, nonatomic) id<genreSelectedDelegate> delegate;
@property (strong, nonatomic) NSArray*          arrGenresList;
@end

@protocol genreSelectedDelegate <NSObject>

- (void)genreIDSelected:(NSString*)genreID genreName_en:(NSString*)genreName_en genreName_ar:(NSString*)genreName_ar;

@end
