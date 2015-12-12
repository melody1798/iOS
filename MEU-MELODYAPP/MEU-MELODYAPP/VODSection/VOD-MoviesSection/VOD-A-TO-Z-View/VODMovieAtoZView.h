//
//  VODMovieAtoZView.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//  Movies A-Z view

#import <UIKit/UIKit.h>

@protocol AtoZMovieSeleted;

@interface VODMovieAtoZView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView*      tblVwAllMovie;
    int i;
}

@property (strong, nonatomic) IBOutlet UITableView*    tblVwAllMovie;
@property (weak, nonatomic) IBOutlet UILabel*          lblNoVideoFoundText;
@property (strong, nonatomic) NSMutableArray*          arrAlphabets;
@property (strong, nonatomic) NSMutableArray*          arrAllMovies;

@property (nonatomic,retain) NSMutableDictionary *dictSections;
@property (weak, nonatomic) id <AtoZMovieSeleted>   delegate;
@property (assign, nonatomic) int i;

+ (id)customView;
- (void)reloadTableView:(NSArray*)arrResponse arrAlphabets:(NSMutableArray*)arrAlphabets;

@end

@protocol AtoZMovieSeleted <NSObject>

- (void)playSelectedMovie:(NSString*)movieID;

@end

