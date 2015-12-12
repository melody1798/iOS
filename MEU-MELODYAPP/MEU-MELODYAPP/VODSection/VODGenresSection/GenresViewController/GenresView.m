//
//  GenresView.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "GenresView.h"
#import "AtoZTableViewCell.h"
#import "constant.h"
#import "CommonFunctions.h"

@implementation GenresView

@synthesize tblVwGenreListing;
@synthesize lblGenreName;
@synthesize delegate;
@synthesize strGenreName;
@synthesize strGenreName_ar;
@synthesize arrGenresMovies;
@synthesize arrAlphabets;

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
    GenresView *customView = [[[NSBundle mainBundle] loadNibNamed:@"GenresView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[GenresView class]])
        return customView;
    else
        return nil;
}

- (void)reloadGenresTableViewData
{
    [self.lblNoVideoFoundText setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        [lblGenreName setText:strGenreName];
    }
    else
    {
        [lblGenreName setText:strGenreName_ar];
    }
    
    [tblVwGenreListing reloadData];
}

- (void)fetchAllGenres:(NSString*)genreId genreName_en:(NSString*)genreName_en genreName_ar:(NSString*)genreName_ar genreType:(NSString*)genreType
{
    [self.lblNoVideoFoundText setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];

    strGenreType = [NSString stringWithFormat:@"%@", genreType];
    strGenreName = [NSString stringWithFormat:@"%@", genreName_en];
    strGenreName_ar = [NSString stringWithFormat:@"%@", genreName_ar];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        [lblGenreName setText:strGenreName];
    }
    else
    {
        [lblGenreName setText:strGenreName_ar];
    }

    objDetailGenres = nil;
    [lblGenreName setFont:[UIFont fontWithName:kProximaNova_Bold size:18.0]];
    
    NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:genreId forKey:@"GenereId" ];
    if (objDetailGenres == nil) {
        objDetailGenres = [DetailGenres new];
        [objDetailGenres fetchGenreDetails:self selector:@selector(genresServerResponse:) parameters:dictParameters genreType:genreType];
    }
}

#pragma mark - Server Reponse 
- (void)genresServerResponse:(NSArray*)arrResponse
{    
    self.lblNoVideoFoundText.hidden = YES;
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    if ([arrResponse count] == 0) {
        self.lblNoVideoFoundText.hidden = NO;
    }
//    else{
//        arrGenresMovies = [arrResponse mutableCopy];
//        self.arrAlphabets = [[NSMutableArray alloc] init];
//        arrGenresMovies = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenre:arrGenresMovies arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
//        
//        [tblVwGenreListing reloadData];
//    }
    
    else
    {
        arrGenresMovies = [arrResponse mutableCopy];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
            
            self.arrAlphabets = [CommonFunctions createArabicAlphabetsArrayArabic:self.arrGenresMovies];
            arrGenresMovies = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenreArabic:arrGenresMovies arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
        }
        else
        {
            self.arrAlphabets = [[NSMutableArray alloc] init];
            arrGenresMovies = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenre:arrGenresMovies arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
        }
        [tblVwGenreListing reloadData];
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.arrGenresMovies count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.arrGenresMovies count] ==0)
        return 0;
    return [[self.arrGenresMovies objectAtIndex:section] count];
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
    
    DetailGenre *objDetailGenre = (DetailGenre*)[[self.arrGenresMovies objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        cell.lblMovieName.text = objDetailGenre.movieTitle_en;
    }
    else
    {
        cell.lblMovieName.text = objDetailGenre.movieTitle_ar;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        cell.lblMovieType.text = strGenreName;
    else
        cell.lblMovieType.text = strGenreName_ar;

    if ([objDetailGenre.movieDuration length] != 0) {

        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

            cell.lblMovieDuration.text = [NSString stringWithFormat:@"%@ %@", objDetailGenre.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
        else
        {
            NSString *lbltext = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objDetailGenre.movieDuration];
            
            cell.lblMovieDuration.attributedText = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
        }
    }
    
    if (objDetailGenre.videoType  == 2) {
        cell.lblMovieType.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
        CGRect singerLabelFrame = cell.lblMovieType.frame;
        singerLabelFrame.origin.x = 54;
        singerLabelFrame.origin.y = 30;
        cell.lblMovieType.frame = singerLabelFrame;
        cell.lblMovieType.text = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objDetailGenre.musicVideoSingerName_en:objDetailGenre.musicVideoSingerName_ar;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailGenre *objDetailGenre = (DetailGenre*)[[self.arrGenresMovies objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([strGenreType isEqualToString:@"series"]) {
        
        if ([delegate respondsToSelector:@selector(fetchEpisodesGenreSelectedSeries:seriesThumb:seriesName_en:seriesName_ar:)]) {

            [delegate fetchEpisodesGenreSelectedSeries:objDetailGenre.movieID seriesThumb:objDetailGenre.movieThumbnail seriesName_en:objDetailGenre.movieTitle_en seriesName_ar:objDetailGenre.movieTitle_ar];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(playGenreSelectedMovie:)])
        {
            if ([strGenreType isEqualToString:@"music"])
                [delegate playGenreSelectedMovie:objDetailGenre.movieUrl];
            else
                [delegate playGenreSelectedMovie:objDetailGenre.movieID];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailGenre *objDetailGenre = (DetailGenre*)[[self.arrGenresMovies objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if (objDetailGenre.videoType == 2 && [objDetailGenre.musicVideoSingerName_en length]!=0 && [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        return 50;
    }
    if (objDetailGenre.videoType == 2 && [objDetailGenre.musicVideoSingerName_ar length]!=0 && [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
        return 50;
    }
    return 40;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
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
