//
//  GenresView.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//  Movies/music/series view in a particulasr genre.

#import <UIKit/UIKit.h>
#import "DetailGenres.h"
#import "DetailGenre.h"

@protocol genreMovieSelectedDelegate;

@interface GenresView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView*      tblVwGenreListing;
    DetailGenres*              objDetailGenres;
    NSString*                  strGenreType;
}

@property (strong, nonatomic) IBOutlet UITableView*      tblVwGenreListing;
@property (nonatomic,retain) NSMutableDictionary*        dictSections;
@property (strong, nonatomic) IBOutlet UILabel*          lblGenreName;
@property (weak, nonatomic) id <genreMovieSelectedDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel*            lblNoVideoFoundText;
@property (strong, nonatomic) NSString*                  strGenreName;
@property (strong, nonatomic) NSString*                  strGenreName_ar;
@property (strong, nonatomic) NSMutableArray*            arrGenresMovies;
@property (strong, nonatomic) NSMutableArray*            arrAlphabets;

+ (id)customView;
- (void)fetchAllGenres:(NSString*)genreId genreName_en:(NSString*)genreName_en genreName_ar:(NSString*)genreName_ar genreType:(NSString*)genreType;
- (void)reloadGenresTableViewData;

@end

@protocol genreMovieSelectedDelegate <NSObject>

@optional
- (void)playGenreSelectedMovie:(NSString*)movieID;
- (void)fetchEpisodesGenreSelectedSeries:(NSString*)seriesID seriesThumb:(NSString*)seriesThumb seriesName_en:(NSString*)seriesName_en seriesName_ar:(NSString*)seriesName_ar;

@end
