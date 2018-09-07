//
//  ChannelVideosCollection.m
//  Foodly
//
//  Created by ALTRAN on 20/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "ChannelVideosCollection.h"
#import "UIImageView+ImageLoader.h"
#import "Video.h"
#import "VideoCell.h"
#import "VideoPlayer.h"
#import "AppDelegate.h"
#import "UIColor+FoodlyColors.h"

@interface ChannelVideosCollection()

@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UILabel *channelName;
@property (weak, nonatomic) IBOutlet UIView *subheader;
@property (weak, nonatomic) IBOutlet UILabel *subscribersLabel;
@property (weak, nonatomic) IBOutlet UILabel *videosLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorBack;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ChannelVideosCollection {
    
    // Private variables:
    
    NSMutableArray *videos;
    bool startedNewSearch;
    Video *tappedVideo;
}

@synthesize channel;
@synthesize isFavorite;
@synthesize header;
@synthesize channelName;
@synthesize subheader;
@synthesize subscribersLabel;
@synthesize videosLabel;
@synthesize collectionView;
@synthesize errorMessage;
@synthesize tryAgainButton;
@synthesize backButton;
@synthesize activityIndicatorBack;
@synthesize activityIndicatorContainer;
@synthesize activityIndicator;

//----------------------------------------------------------------------//
// MARK: Initialization / Deinitialization
//----------------------------------------------------------------------//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videos = [NSMutableArray new];
    startedNewSearch = false;
    
    activityIndicatorContainer.layer.cornerRadius = 10.0;
    header.layer.cornerRadius = 20.0;
    subheader.layer.cornerRadius = 10.0;
    tryAgainButton.layer.cornerRadius = 10.0;
    backButton.layer.cornerRadius = 10.0;
    [channelName setText: channel.channelTitle];
    
    self.view.backgroundColor = UIColor.lightOrange;
    header.backgroundColor = UIColor.darkOrange;
    backButton.backgroundColor = UIColor.darkOrange;
    activityIndicatorContainer.backgroundColor = UIColor.darkOrange;
    
    if (isFavorite)
    {
        self.view.backgroundColor = UIColor.whiteColor;
        header.backgroundColor = UIColor.whiteColor;
        header.layer.borderColor = UIColor.darkOrange.CGColor;
        header.layer.borderWidth = 3.0;
        subheader.layer.borderColor = UIColor.darkOrange.CGColor;
        subheader.layer.borderWidth = 3.0;
        channelName.textColor = UIColor.darkOrange;
    }
    
    if (channel.subscribersCount != nil)
    {
        [subscribersLabel setText: channel.subscribersCount];
    }
    
    if (channel.videosCount != nil)
    {
        [videosLabel setText: channel.videosCount];
    }
    
    [YouTubeDataAPI getInstance].delegate = self;
    [self showActivity: true];
    [[YouTubeDataAPI getInstance] fetchFirstVideosBatch: channel.channelId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate lockOrientation: UIInterfaceOrientationMaskPortrait andRotateTo: UIInterfaceOrientationPortrait];
}

//----------------------------------------------------------------------//
// MARK: IBAction
//----------------------------------------------------------------------//

- (IBAction)tryAgainButtonTapped:(UIButton *)sender
{
    [errorMessage setHidden: true];
    [tryAgainButton setHidden: true];
    [collectionView setHidden: false];
    [self showActivity: true];
    [[YouTubeDataAPI getInstance] fetchFirstVideosBatch: channel.channelId];
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated: true];
}

//-------------------------------------------------------------------------//
// MARK: YouTubeDataAPIDelegate
//-------------------------------------------------------------------------//

- (void)getFirstVideosBatch:(NSArray *)firstVideosBatch
{
    [self showActivity: false];
    
    if (firstVideosBatch == nil)
    {
        [errorMessage setHidden: false];
        [tryAgainButton setHidden: false];
        [collectionView setHidden: true];
        return;
    }
    
    if ([firstVideosBatch count] == 0)
    {
        [errorMessage setHidden: false];
        [tryAgainButton setHidden: false];
        [collectionView setHidden: true];
        return;
    }
    
    [videos addObjectsFromArray: firstVideosBatch];
    [collectionView reloadData];
}

- (void)getNextVideosBatch:(NSArray *)nextVideosBatch
{
    [self showActivity: false];
    startedNewSearch = false;
    
    if (nextVideosBatch == nil) { return; }
    
    if ([nextVideosBatch count] == 0) { return; }
    
    for (Video *video in nextVideosBatch)
    {
        Boolean found = false;
        
        for (Video *video_ in videos)
        {
            if ([video.videoId isEqualToString: video_.videoId] ||
                [video.videoTitle isEqualToString: video_.videoTitle] ||
                [video.thumbnailUrl isEqualToString: video_.thumbnailUrl])
            {
                //NSLog(@"\n Found \n");
                found = true;
                break;
            }
        }
        
        if (!found)
        {
            [videos addObject: video];
        }
    }
    
    [collectionView reloadData];
}

//-------------------------------------------------------------------------//
// MARK: UIScrollViewDelegate
//-------------------------------------------------------------------------//

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (((scrollOffset + scrollViewHeight) == scrollContentSizeHeight) && (!startedNewSearch))
    {
        startedNewSearch = true;
        [self showActivity: true];
        [[YouTubeDataAPI getInstance] fetchNextVideosBatch: channel.channelId];
    }
}//-------------------------------------------------------------------------//
// MARK: UICollectionViewDelegate
//-------------------------------------------------------------------------//

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    tappedVideo = videos[indexPath.item];
    [self performSegueWithIdentifier: @"ShowVideoPlayer" sender: self];
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
        cellWidth = (collWidth - 10)/2;
    }
    else
    {
        cellWidth = collWidth;
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
    return [videos count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    Video *video = videos[indexPath.item];
    
    VideoCell *cell = (VideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier: @"VideoCell" forIndexPath: indexPath];
    [cell.videoThumbnail setImageWithUrl: video.thumbnailUrl usingPlaceholder: @"Placeholder_"];
    [cell.videoTitle setText: video.videoTitle];
    [cell.videoDescription setText: video.videoDescription];
    cell.cellContainer.layer.cornerRadius = 20.0;
    
    [cell detectedIpadForVideoCell];
    
    if (isFavorite)
    {
        cell.cellContainer.layer.borderColor = UIColor.darkOrange.CGColor;
        cell.cellContainer.layer.borderWidth = 1.5;
    }
    
    return cell;
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
// MARK: Prepare for segue
//-------------------------------------------------------------------------//

- (void)prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender
{
    VideoPlayer *vc = (VideoPlayer *) [segue destinationViewController];
    vc.tappedVideo = tappedVideo;
}

//----------------------------------------------------------------------//
// MARK: Memory Warning
//----------------------------------------------------------------------//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
