//
//  VODMoviesCollections.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 28/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODMoviesCollections.h"
#import "VODMoviesCollectionsCell.h"
#import "CommonFunctions.h"

@implementation VODMoviesCollections

@synthesize delegate;
@synthesize lblNoCollectionFound;
@synthesize i;

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
    VODMoviesCollections *customView = [[[NSBundle mainBundle] loadNibNamed:@"VODMoviesCollections" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[VODMoviesCollections class]])
        
        return customView;
    else
        return nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

#pragma mark - Register CollectionView Cell
- (void)registerCollectionVwCell
{
    [collectionVwCollections registerNib:[UINib nibWithNibName:@"VODMoviesCollectionsCell" bundle:nil] forCellWithReuseIdentifier:@"collectioncell"];
}

- (void)reloadCollectionView:(NSArray*)arrResponse
{
    self.arrCollections = [[NSArray alloc] initWithArray:arrResponse];
    
    self.lblNoCollectionFound.hidden = YES;
    self.lblNoCollectionFound.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    if ([self.arrCollections count] == 0  && i == 0) {
        self.lblNoCollectionFound.hidden = NO;
    }
    [collectionVwCollections reloadData];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrCollections count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VODMoviesCollectionsCell *cell = [collectionVwCollections dequeueReusableCellWithReuseIdentifier:@"collectioncell" forIndexPath:indexPath];
    
    [cell setCellValues:(MoviesCollection*)[self.arrCollections objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate respondsToSelector:@selector(collectionVwSelectedItem:)]) {
        [delegate performSelector:@selector(collectionVwSelectedItem:) withObject:[self.arrCollections objectAtIndex:indexPath.row]];
    }
}

@end