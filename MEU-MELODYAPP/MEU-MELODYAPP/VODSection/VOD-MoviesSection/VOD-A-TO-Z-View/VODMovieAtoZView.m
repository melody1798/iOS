//
//  VODMovieAtoZView.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODMovieAtoZView.h"
#import "AtoZTableViewCell.h"
#import "AtoZMovie.h"
#import "Constant.h"
#import "CommonFunctions.h"

@implementation VODMovieAtoZView

@synthesize tblVwAllMovie;
@synthesize dictSections;
@synthesize delegate;
@synthesize i;
@synthesize arrAlphabets, arrAllMovies;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)customView
{
    VODMovieAtoZView *customView = [[[NSBundle mainBundle] loadNibNamed:@"VODMovieAtoZView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[VODMovieAtoZView class]])
        return customView;
    else
        return nil;
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.arrAllMovies count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([arrAllMovies count] ==0)
        return 0;
    return [[self.arrAllMovies objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"atozvideocell1";
    AtoZTableViewCell *cell = (AtoZTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (AtoZTableViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"AtoZTableViewCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]];
    }
    
    AtoZMovie *objAtoZMovie = (AtoZMovie*) [[self.arrAllMovies objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        cell.lblMovieName.text = objAtoZMovie.movieName_en;
        cell.lblMovieType.text = objAtoZMovie.movieGenre_en;
    }
    else{
        cell.lblMovieName.text = objAtoZMovie.movieName_ar;
        cell.lblMovieType.text = objAtoZMovie.movieGenre_ar;
    }
    
    if ([objAtoZMovie.movieDuration length]!=0) {
      
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

            cell.lblMovieDuration.text = [NSString stringWithFormat:@"%@ %@", objAtoZMovie.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
        else
        {
            NSString *lbltext = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objAtoZMovie.movieDuration];
            
            cell.lblMovieDuration.attributedText = [cell setDurationText:lbltext];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AtoZMovie *objAtoZMovie = (AtoZMovie*) [[self.arrAllMovies objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([delegate respondsToSelector:@selector(playSelectedMovie:)]) {
        [delegate playSelectedMovie:objAtoZMovie.movieId];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 30)];
    [viewHeader setBackgroundColor:[UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:41.0/255.0 alpha:1.0]];

    UILabel *lblHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 700, 20)];
    [lblHeaderTitle setBackgroundColor:[UIColor clearColor]];
    [lblHeaderTitle setTextColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [lblHeaderTitle setFont:[UIFont fontWithName:kProximaNova_SemiBold size:15.0]];
    
    [lblHeaderTitle setText:[arrAlphabets objectAtIndex:section]];
    [viewHeader addSubview:lblHeaderTitle];

    return viewHeader;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.arrAlphabets;
}

- (void)reloadTableView:(NSArray*)arrResponse arrAlphabets:(NSMutableArray*)arrAlphabetss
{
    self.arrAlphabets = [[NSMutableArray alloc] initWithArray:arrAlphabetss];
    self.arrAllMovies = [[NSMutableArray alloc] initWithArray:arrResponse];
    
    self.lblNoVideoFoundText.hidden = YES;
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    if ([arrResponse count] == 0 && i == 0) {
        self.lblNoVideoFoundText.hidden = NO;
    }
    else{
        i++;
        [tblVwAllMovie reloadData];
    }
}

@end