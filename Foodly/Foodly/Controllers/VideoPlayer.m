//
//  VideoPlayer.m
//  Foodly
//
//  Created by ALTRAN on 24/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "VideoPlayer.h"
#import "YTPlayerView.h"
#import "AppDelegate.h"
#import "UIColor+FoodlyColors.h"
#import "UIImageView+ImageLoader.h"

@interface VideoPlayer()

@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnail;
@property (weak, nonatomic) IBOutlet UIView *playButtonView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UIStackView *videoInfo;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet UILabel *videoDescription;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation VideoPlayer

@synthesize tappedVideo;

//----------------------------------------------------------------------//
// MARK: Initialization / Deinitialization
//----------------------------------------------------------------------//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playButtonView.layer.cornerRadius = 5.0;
    self.backButton.layer.cornerRadius = 10.0;
    self.backButton.backgroundColor = UIColor.darkOrange;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate lockOrientation: UIInterfaceOrientationMaskAllButUpsideDown];
    
    self.videoInfo.layer.cornerRadius = 20.0;
    [self.videoThumbnail setImageWithUrl: tappedVideo.thumbnailUrl usingPlaceholder: @"Placeholder_"];
    [self.videoTitle setText: tappedVideo.videoTitle];
    [self.videoDescription setText: tappedVideo.videoDescription];
}

//----------------------------------------------------------------------//
// MARK: IBActions
//----------------------------------------------------------------------//

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated: true];
}

- (IBAction)playButtonTapped:(UIButton *)sender
{
    [self.videoThumbnail setHidden: true];
    [self.playButtonView setHidden: true];
    [self.visualEffectView setHidden: true];
    [self.videoInfo setHidden: true];
    
    [self.playerView loadWithVideoId: tappedVideo.videoId];
}

//----------------------------------------------------------------------//
// MARK: Memory Warning
//----------------------------------------------------------------------//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
