//
//  MusicSingerView.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MusicSingerView.h"
#import "VODFeaturedCollectionCell.h"
#import "MusicSinger.h"
#import "CommonFunctions.h"
#import "AtoZTableViewCell.h"
#import "MBProgressHUD.h"

@implementation MusicSingerView

@synthesize delegate;
@synthesize arrMusicSingers;

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
    MusicSingerView *customView = [[[NSBundle mainBundle] loadNibNamed:@"MusicSingerView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[MusicSingerView class]])
        return customView;
    else
        return nil;
}

- (void)fetchMusicSingers
{
    self.lblNoVideoFoundText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];

    if (![kCommonFunction checkNetworkConnectivity])
    {
        self.lblNoVideoFoundText.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        MusicSingers *objMusicSingers = [MusicSingers new];
        [objMusicSingers fetchMusicSingers:self selector:@selector(musicServerResponse:)];
    }
}

- (void)fetchMusicSingersAfterLanguageChange
{
    self.lblNoVideoFoundText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    MusicSingers *objMusicSingers = [MusicSingers new];
    [objMusicSingers fetchMusicSingers:self selector:@selector(musicServerResponse:)];
}

- (void)reloadSingersTableView
{
   // [collectionVw reloadData];
    [tblVw reloadData];
}

- (void)musicServerResponse:(NSArray*)arrResponse
{
    //arrMusicSingers = [[NSArray alloc] initWithArray:arrResponse];
    
    self.lblNoVideoFoundText.hidden = YES;
    if ([arrResponse count] == 0) {
        self.lblNoVideoFoundText.hidden = NO;
    }
    else
    {
        self.arrMusicSingers = [arrResponse mutableCopy];
        self.arrAlphabets = [[NSMutableArray alloc] init];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
            
            self.arrAlphabets = [CommonFunctions createArabicAlphabetsArrayMusicArabic:self.arrMusicSingers];
            self.arrMusicSingers = [CommonFunctions returnArrayOfRecordForParticularAlphabetForMusicArabic:self.arrMusicSingers arrayOfAphabetsToDisplay:self.arrAlphabets];
        }
        else
            self.arrMusicSingers = [[CommonFunctions returnArrayOfRecordForMusicSingersParticularAlphabet:self.arrMusicSingers arrayOfAphabetsToDisplay:self.arrAlphabets] mutableCopy];
    }
   // [collectionVw reloadData];
    [tblVw reloadData];
    
    [MBProgressHUD hideHUDForView:self animated:YES];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.arrMusicSingers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.arrMusicSingers count] ==0)
        return 0;
    return [[self.arrMusicSingers objectAtIndex:section] count];
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

    MusicSinger *objMusicSinger = (MusicSinger*) [[self.arrMusicSingers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setMusicatoZCellValues:objMusicSinger];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        cell.lblMovieName.text = objMusicSinger.musicVideoName_en;
        cell.lblMovieType.text = objMusicSinger.singerName_en;
    }
    else{
        cell.lblMovieName.text = objMusicSinger.musicVideoName_ar;
        cell.lblMovieType.text = objMusicSinger.singerName_ar;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicSinger *objMusicSinger = (MusicSinger*) [[self.arrMusicSingers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish] && [objMusicSinger.singerName_en length] == 0) {
        return 40;
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic] && [objMusicSinger.singerName_ar length] == 0)
    {
        return 40;
    }
    
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicSinger *objMusicSinger = (MusicSinger*) [[self.arrMusicSingers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([delegate respondsToSelector:@selector(musicSingerSelected:singerName_en:singerName_ar:)]) {
        [delegate musicSingerSelected:objMusicSinger.musicVideoUrl singerName_en:objMusicSinger.singerName_en singerName_ar:objMusicSinger.singerName_ar];
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
    
    [lblHeaderTitle setText:[self.arrAlphabets objectAtIndex:section]];
    [viewHeader addSubview:lblHeaderTitle];
    
    return viewHeader;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.arrAlphabets;
}

/*
#pragma mark - Register CollectionView Cell
- (void)registerCollectionViewCell
{
    [collectionVw registerNib:[UINib nibWithNibName:@"VODFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"vodfeaturecell"];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrMusicSingers count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VODFeaturedCollectionCell *cell = [collectionVw dequeueReusableCellWithReuseIdentifier:@"vodfeaturecell" forIndexPath:indexPath];
    [cell setCellValuesForSingers:[self.arrMusicSingers objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MusicSinger *objMusicSinger = (MusicSinger*) [self.arrMusicSingers objectAtIndex:indexPath.row];
    if ([delegate respondsToSelector:@selector(musicSingerSelected:singerName_en:singerName_ar:)]) {
        [delegate musicSingerSelected:objMusicSinger.singerId singerName_en:objMusicSinger.singerName_en singerName_ar:objMusicSinger.singerName_ar];
    }
}
*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end