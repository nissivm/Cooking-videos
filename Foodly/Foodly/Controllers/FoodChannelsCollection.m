//
//  FoodChannelsCollection.m
//  Foodly
//
//  Created by ALTRAN on 09/07/2018.
//  Copyright © 2018 Nissi Vieira Miranda. All rights reserved.
//

#import "FoodChannelsCollection.h"
#import "UIImageView+ImageLoader.h"
#import "ChannelVideosCollection.h"
#import "UIColor+FoodlyColors.h"

@interface FoodChannelsCollection()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *showAllFavoritesButton;

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorBack;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIView *fetchFailAlert;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;

@property (weak, nonatomic) IBOutlet UIView *noResultsAlert;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton_;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fetchFailAlertBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noResultsAlertBottomConstraint;

@end

@implementation FoodChannelsCollection {
    
    // Private variables:
    
    NSMutableArray *channels;
    
    NSMutableArray *allFavorites;
    NSMutableArray *newFavs;
    NSMutableArray *deletedFavs; // Only the ones added in previous sessions
    
    NSMutableArray *flippedIndexPathes;
    
    NSNotificationCenter *center;
    bool isInFavoriteMode;
    bool startedNewSearch;
    Channel *tappedChannel;
}

@synthesize collectionView;
@synthesize showAllFavoritesButton;
@synthesize activityIndicatorBack;
@synthesize activityIndicatorContainer;
@synthesize activityIndicator;
@synthesize fetchFailAlert;
@synthesize tryAgainButton;
@synthesize noResultsAlert;
@synthesize tryAgainButton_;

@synthesize backgroundTopConstraint;
@synthesize backgroundBottomConstraint;
@synthesize fetchFailAlertBottomConstraint;
@synthesize noResultsAlertBottomConstraint;

//----------------------------------------------------------------------//
// MARK: Initialization / Deinitialization
//----------------------------------------------------------------------//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    center = [NSNotificationCenter defaultCenter];
    
    [center addObserver: self
               selector: @selector(appDidEnterBackground:)
                   name: UIApplicationDidEnterBackgroundNotification
                 object: nil];
    
    channels = [NSMutableArray new];
    allFavorites = [NSMutableArray new];
    newFavs = [NSMutableArray new];
    deletedFavs = 0;
    flippedIndexPathes = [NSMutableArray new];
    isInFavoriteMode = false;
    startedNewSearch = false;
    
    showAllFavoritesButton.layer.cornerRadius = 10.0;
    activityIndicatorContainer.layer.cornerRadius = 10.0;
    fetchFailAlert.layer.cornerRadius = 20.0;
    tryAgainButton.layer.cornerRadius = 10.0;
    noResultsAlert.layer.cornerRadius = 20.0;
    tryAgainButton_.layer.cornerRadius = 10.0;
    
    self.view.backgroundColor = UIColor.lightOrange;
    showAllFavoritesButton.backgroundColor = UIColor.darkOrange;
    activityIndicatorContainer.backgroundColor = UIColor.darkOrange;
    
    [YouTubeDataAPI getInstance].delegate = self;
    [self startFetchingFirstChannelsBatch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    [YouTubeDataAPI getInstance].delegate = self;
}

- (void)dealloc
{
    [center removeObserver: self];
}

//-------------------------------------------------------------------------//
// MARK: NSNotification
//-------------------------------------------------------------------------//

- (void) appDidEnterBackground:(NSNotification *)notification
{
    RLMRealm *realm;
    RLMResults *results;
    
    if (([newFavs count] > 0) || (deletedFavs > 0))
    {
        realm = [RLMRealm defaultRealm];
        results = [Channel allObjects];
        [realm beginWriteTransaction];
    }
    
    if ([newFavs count] > 0)
    {
        for (NSIndexPath *idxPath in newFavs)
        {
            Channel *ch = channels[idxPath.item];
            ch.isFavorite = true;
            ch.isNewFavorite = false;
            channels[idxPath.item] = ch;
            
            [Channel createInRealm: realm withValue: ch];
        }
        
        [newFavs removeAllObjects];
    }
    
    if (deletedFavs > 0)
    {
        NSMutableArray *arr = [NSMutableArray new];
        
        for (NSIndexPath *idxPath in deletedFavs)
        {
            Channel *ch = channels[idxPath.item];
            ch.isFavorite = false;
            ch.isToDelete = false;
            channels[idxPath.item] = ch;
            
            for (Channel *favCh in results)
            {
                if ([favCh.channelId isEqualToString: ch.channelId])
                {
                    [arr addObject: favCh];
                    break;
                }
            }
        }
        
        [realm deleteObjects: arr];
        [deletedFavs removeAllObjects];
    }
    
    if (realm != nil)
    {
        [realm commitWriteTransaction];
        [self filterFavoriteChannels];
        
        if ([flippedIndexPathes count] > 0)
        {
            [flippedIndexPathes removeAllObjects];
        }
        
        [collectionView reloadData];
    }
}

//-------------------------------------------------------------------------//
// MARK: IBActions
//-------------------------------------------------------------------------//

- (IBAction)showAllFavoritesButtonTapped:(UIButton *)sender
{
    [activityIndicatorBack setHidden: false];
    
    [UIView animateWithDuration: 0.5 delay: 0
    options: UIViewAnimationOptionCurveEaseOut
    animations:^{
        
        if (!self->isInFavoriteMode)
        {
            self.view.backgroundColor = [UIColor whiteColor]; // Going to favorite mode, then
        }
        else
        {
            self.view.backgroundColor = UIColor.lightOrange;
        }
        
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished)
    {
        if (!self->isInFavoriteMode)
        {
            self->isInFavoriteMode = true;
            [self->showAllFavoritesButton setTitle: @"Show all" forState: UIControlStateNormal];
        }
        else
        {
            self->isInFavoriteMode = false;
            [self->showAllFavoritesButton setTitle: @"Show favorites" forState: UIControlStateNormal];
        }
        
        [self->activityIndicatorBack setHidden: true];
        
        if ([self->flippedIndexPathes count] > 0)
        {
            [self->flippedIndexPathes removeAllObjects];
        }
        
        [self->collectionView reloadData];
    }];
}

//-------------------------------------------------------------------------//
// MARK: ChannelCellDelegate
//-------------------------------------------------------------------------//

- (void)tappedFavoriteButton:(NSIndexPath *)indexPath
{
    Channel *channel = channels[indexPath.item];
    
    if (channel.isFavorite)
    {
        channel.isToDelete = channel.isToDelete ? false : true;
        
        if (channel.isToDelete)
        {
            [deletedFavs addObject: indexPath];
        }
        else
        {
            [deletedFavs removeObject: indexPath];
        }
    }
    else
    {
        channel.isNewFavorite = channel.isNewFavorite ? false : true;
        
        if (channel.isNewFavorite)
        {
            [newFavs addObject: indexPath];
        }
        else
        {
            [newFavs removeObject: indexPath];
        }
    }
    
    channels[indexPath.item] = channel;
    [self filterFavoriteChannels];
    [collectionView reloadData];
}

- (void)tappedCheckNextChannel:(NSIndexPath *)indexPath
{
    tappedChannel = channels[indexPath.item];
    
    if (tappedChannel.subscribersCount == nil)
    {
        [self showActivity: true];
        [[YouTubeDataAPI getInstance] fetchChannelsInfo: tappedChannel];
    }
    else
    {
        [self performSegueWithIdentifier: @"ShowChannelVideos" sender: self];
    }
}

//-------------------------------------------------------------------------//
// MARK: YouTubeDataAPIDelegate
//-------------------------------------------------------------------------//

- (void)getFirstChannelsBatch:(NSArray *)firstChannelsBatch
{
    if (firstChannelsBatch == nil)
    {
        [self showActivity: false];
        [self handleFirstChannelBatchFetchFail];
        return;
    }
    
    if ([firstChannelsBatch count] == 0)
    {
        [self showActivity: false];
        [self handleFirstChannelBatchFetchZeroResults];
        return;
    }
    
    [channels addObjectsFromArray: firstChannelsBatch];
    [self filterFavoriteChannels];
    [collectionView reloadData];
    [self showActivity: false];
    
    int height = [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration: 0.8 delay: 0.3
    options: UIViewAnimationOptionCurveEaseOut
    animations:^{
        
        self->backgroundTopConstraint.constant = height * 1.5;
        self->backgroundBottomConstraint.constant = (height * 1.5) * -1;
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished) {}];
}

- (void)getNextChannelsBatch:(NSArray *)nextChannelsBatch
{
    [self showActivity: false];
    startedNewSearch = false;
    
    if (nextChannelsBatch == nil) { return; }
    
    if ([nextChannelsBatch count] == 0) { return; }
    
    for (Channel *channel in nextChannelsBatch)
    {
        Boolean found = false;
        
        for (Channel *channel_ in channels)
        {
            if ([channel.channelId isEqualToString: channel_.channelId] ||
                [channel.channelTitle isEqualToString: channel_.channelTitle] ||
                [channel.thumbnailUrl isEqualToString: channel_.thumbnailUrl])
            {
                found = true;
                break;
            }
        }
        
        if (!found)
        {
            [channels addObject: channel];
        }
    }
    
    [self filterFavoriteChannels];
    [collectionView reloadData];
}

- (void)getChannelInfo:(Channel *)channel
{
    if (channel != nil)
    {
        tappedChannel = channel;
        int counter = 0;
        
        for (Channel *c in channels)
        {
            if (c.channelId == tappedChannel.channelId)
            {
                channels[counter] = tappedChannel;
                break;
            }
            
            counter++;
        }
    }
    
    [self showActivity: false];
    [self performSegueWithIdentifier: @"ShowChannelVideos" sender: self];
}

//-------------------------------------------------------------------------//
// MARK: UIScrollViewDelegate
//-------------------------------------------------------------------------//

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (isInFavoriteMode) { return; }
    
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (((scrollOffset + scrollViewHeight) == scrollContentSizeHeight) && (!startedNewSearch))
    {
        startedNewSearch = true;
        [self showActivity: true];
        RLMResults *results = [Channel allObjects];
        [[YouTubeDataAPI getInstance] fetchNextChannelsBatch: results];
    }
}

//-------------------------------------------------------------------------//
// MARK: UICollectionViewDelegate
//-------------------------------------------------------------------------//

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *cell = (ChannelCell *)[collectionView cellForItemAtIndexPath: indexPath];
    
    int index = [self isFlipped: indexPath];
    BOOL isFlipped = index >= 0 ? true : false;
    
    if (isFlipped)
    {
        [flippedIndexPathes removeObjectAtIndex: index];
    }
    else
    {
        [flippedIndexPathes addObject: indexPath];
    }
    
    [cell animateCell: isFlipped];
}

//-------------------------------------------------------------------------//
// MARK: UICollectionViewDelegateFlowLayout
//-------------------------------------------------------------------------//

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int collWidth = collectionView.bounds.size.width;
    CGFloat cellWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        cellWidth = (collWidth - 20)/3;
    }
    else
    {
        cellWidth = (collWidth - 10)/2;
    }
    
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

//-------------------------------------------------------------------------//
// MARK: UICollectionViewDataSource
//-------------------------------------------------------------------------//

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!isInFavoriteMode)
    {
        return [channels count];
    }
    else
    {
        return [allFavorites count];
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    Channel *channel;
    
    if (!isInFavoriteMode)
    {
        channel = channels[indexPath.item];
    }
    else
    {
        channel = allFavorites[indexPath.item];
    }
    
    BOOL isFlipped = [self isFlipped: indexPath] >= 0 ? true : false;
    
    ChannelCell *cell = (ChannelCell *)[collectionView dequeueReusableCellWithReuseIdentifier: @"ChannelCell" forIndexPath: indexPath];
    [cell.thumbnail setImageWithUrl: channel.thumbnailUrl usingPlaceholder: @"Placeholder"];
    [cell.channelTitle setText: channel.channelTitle];
    
    cell.container.layer.cornerRadius = 20.0;
    cell.container.backgroundColor = UIColor.darkOrange;
    
    cell.checkChannelButton.backgroundColor = UIColor.darkOrange;
    
    cell.thumbnail.layer.cornerRadius = 20.0;
    cell.thumbnail.layer.borderWidth = 3.0;
    
    [cell detectedIpadForChannelCell];
    
    if (isFlipped)
    {
        [cell.container setHidden: false];
        [cell.thumbnail setHidden: true];
    }
    else
    {
        [cell.container setHidden: true];
        [cell.thumbnail setHidden: false];
    }
    
    if (!isInFavoriteMode)
    {
        UIImage *img;
        
        if ([self isFavorite: channel])
        {
            img = [UIImage imageNamed: @"RedHeart"];
        }
        else
        {
            img = [UIImage imageNamed: @"WhiteHeart"];
        }
        
        [cell.favoriteButton setImage: img
                             forState: UIControlStateNormal];
        
        cell.thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.favoriteButton setHidden: false];
    }
    else
    {
        cell.thumbnail.layer.borderColor = UIColor.darkOrange.CGColor;
        [cell.favoriteButton setHidden: true];
    }
    
    cell.idxPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

//-------------------------------------------------------------------------//
// MARK: Is flipped
//-------------------------------------------------------------------------//

- (int)isFlipped:(NSIndexPath *)indexPath
{
    BOOL isFlipped = false;
    int counter = 0;
    
    if ([flippedIndexPathes count] > 0)
    {
        for (NSIndexPath *idxPath in flippedIndexPathes)
        {
            if ([indexPath isEqual: idxPath])
            {
                isFlipped = true;
                break;
            }
            
            counter++;
        }
        
        if (!isFlipped)
        {
            counter = -1;
        }
    }
    else { counter = -1; }
    
    return counter;
}

//-------------------------------------------------------------------------//
// MARK: Is a favorite
//-------------------------------------------------------------------------//

- (BOOL)isFavorite:(Channel *)channel
{
    return (channel.isFavorite || channel.isNewFavorite) && !channel.isToDelete;
}

//-------------------------------------------------------------------------//
// MARK: Start fetching first channels batch
//-------------------------------------------------------------------------//

- (void)startFetchingFirstChannelsBatch
{
    [self showActivity: true];
    
    RLMResults *results = [Channel allObjects];
    [[YouTubeDataAPI getInstance] fetchFirstChannelsBatch: results];
}

//-------------------------------------------------------------------------//
// MARK: First channel batch fetch fail
//-------------------------------------------------------------------------//

- (void)handleFirstChannelBatchFetchFail
{
    int height = [UIScreen mainScreen].bounds.size.height;
    CGFloat alertHeight = 150.0;
    CGFloat newConst = (height - alertHeight)/2;
    
    [UIView animateWithDuration: 0.5 delay: 0.5
    options: UIViewAnimationOptionCurveEaseIn
    animations:^{
                         
        self->fetchFailAlertBottomConstraint.constant = newConst;
        [self->fetchFailAlert setAlpha: 1.0];
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished) {}];
}

//-------------------------------------------------------------------------//
// MARK: First channel batch fetch zero results
//-------------------------------------------------------------------------//

- (void)handleFirstChannelBatchFetchZeroResults
{
    int height = [UIScreen mainScreen].bounds.size.height;
    CGFloat alertHeight = 240.0;
    CGFloat newConst = (height - alertHeight)/2;
    
    [UIView animateWithDuration: 0.5 delay: 0.5
    options: UIViewAnimationOptionCurveEaseIn
    animations:^{
        
        self->noResultsAlertBottomConstraint.constant = newConst;
        [self->noResultsAlert setAlpha: 1.0];
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished) {}];
}

//-------------------------------------------------------------------------//
// MARK: Try again buttons action
//-------------------------------------------------------------------------//

- (IBAction)tryAgainButtonTapped:(UIButton *)sender
{
    Boolean failAlertShowing = fetchFailAlert.alpha == 1.0;
    
    [UIView animateWithDuration: 0.5 delay: 0
    options: UIViewAnimationOptionCurveEaseOut
    animations:^{
                         
        if (failAlertShowing)
        {
            self->fetchFailAlertBottomConstraint.constant = -500.0;
            [self->fetchFailAlert setAlpha: 0.0];
        }
        else
        {
            self->noResultsAlertBottomConstraint.constant = -500.0;
            [self->noResultsAlert setAlpha: 0.0];
        }
        
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished)
    {
        [self startFetchingFirstChannelsBatch];
     }];
}

//-------------------------------------------------------------------------//
// MARK: Toggle Activity
//-------------------------------------------------------------------------//

- (void)showActivity:(Boolean)show
{
    if (show)
    {
        [activityIndicatorBack setHidden: false];
        [activityIndicatorContainer setHidden: false];
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicatorBack setHidden: true];
        [activityIndicatorContainer setHidden: true];
        [activityIndicator stopAnimating];
    }
}

//-------------------------------------------------------------------------//
// MARK: Filter favorite channels
//-------------------------------------------------------------------------//

- (void)filterFavoriteChannels
{
    RLMResults *results = [Channel allObjects];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"SELF.isFavorite == %@", [NSNumber numberWithBool: true]];
    
    allFavorites = [NSMutableArray arrayWithArray: [channels filteredArrayUsingPredicate: pred]];
    
    if ([results count] > 0)
    {
        if ([allFavorites count] > 0)
        {
            for (Channel *ch in results)
            {
                BOOL found = false;
                
                for (Channel *ch_ in allFavorites)
                {
                    if ([ch.channelId isEqualToString: ch_.channelId])
                    {
                        found = true;
                        break;
                    }
                }
                
                if (!found)
                {
                    [allFavorites addObject: ch];
                }
            }
        }
        else
        {
            for (Channel *ch in results)
            {
                [allFavorites addObject: ch];
            }
        }
    }
    
    NSPredicate *pred_ = [NSPredicate predicateWithFormat: @"SELF.isNewFavorite == %@", [NSNumber numberWithBool: true]];
    
    NSArray *newFavorites = [channels filteredArrayUsingPredicate: pred_];
    allFavorites = [NSMutableArray arrayWithArray: [allFavorites arrayByAddingObjectsFromArray: newFavorites]];
    
    if ([allFavorites count] > 0)
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat: @"SELF.isToDelete == %@", [NSNumber numberWithBool: false]];
        
        allFavorites = [NSMutableArray arrayWithArray: [allFavorites filteredArrayUsingPredicate: pred]];
    }
    
    // Checking favorites button:
    
    if ([allFavorites count] > 0)
    {
        [showAllFavoritesButton setAlpha: 1.0];
        [showAllFavoritesButton setEnabled: true];
    }
    else
    {
        [showAllFavoritesButton setAlpha: 0.4];
        [showAllFavoritesButton setEnabled: false];
    }
}

//-------------------------------------------------------------------------//
// MARK: Prepare for segue
//-------------------------------------------------------------------------//

- (void)prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender
{
    ChannelVideosCollection *vc = (ChannelVideosCollection *) [segue destinationViewController];
    vc.channel = tappedChannel;
    vc.isFavorite = isInFavoriteMode;
}

//-------------------------------------------------------------------------//
// MARK: Memory Warning
//-------------------------------------------------------------------------//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
