//
//  RelatedSingerViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 28/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "RelatedSingerViewController.h"
#import "SingerVideos.h"
#import "SingerVideo.h"
#import "CollectionsDetailCustomCell.h"
#import "UIImageView+WebCache.h"
#import "CustomControls.h"
#import "MoviesDetailViewController.h"
#import "CommonFunctions.h"

@interface RelatedSingerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView*        collectionVw;
}

@property (strong, nonatomic) NSArray*      arrRelatedSingerVideos;

@end

@implementation RelatedSingerViewController

@synthesize singerId;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    
    [self registerCollectionViewCell];
    
    SingerVideos *objSingerVideos = [SingerVideos new];
    NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:singerId forKey:@"singerId" ];
    [objSingerVideos fetchSingerVideos:self selector:@selector(singerVideosServerResponse:) parameters:dictParameters];
}

- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Register Collection view cell
-(void) registerCollectionViewCell
{
    [collectionVw registerNib:[UINib nibWithNibName:@"CollectionsDetailCustomCell" bundle:Nil] forCellWithReuseIdentifier:@"CollectionsDetailCustomCellReuse"];
}

- (void)singerVideosServerResponse:(NSArray*)arrResponse
{
    self.arrRelatedSingerVideos = [[NSArray alloc] initWithArray:arrResponse];
    [collectionVw reloadData];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrRelatedSingerVideos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"CollectionsDetailCustomCellReuse";
    CollectionsDetailCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionsDetailCustomCell" owner:self options:nil] firstObject];
    
    [cell setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
    
    SingerVideo *objSingerVideo = [self.arrRelatedSingerVideos objectAtIndex:indexPath.row];
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objSingerVideo.movieThumb] placeholderImage:[UIImage imageNamed:@""]];
    cell.lblName.text = [CommonFunctions isEnglish]?objSingerVideo.movieName_en:objSingerVideo.movieName_ar;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SingerVideo *objSingerVideo = [self.arrRelatedSingerVideos objectAtIndex:indexPath.row];

    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[MoviesDetailViewController class]]) {
            
            if ([delegate respondsToSelector:@selector(fetchMovieDetailFromRelatedSinger:)]) {
                [delegate fetchMovieDetailFromRelatedSinger:objSingerVideo.movieID];
            }
            
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end