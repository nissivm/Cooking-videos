//
//  ChannelCell.m
//  Foodly
//
//  Created by ALTRAN on 18/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "ChannelCell.h"

@implementation ChannelCell

@synthesize container;
@synthesize thumbnail;
@synthesize channelTitle;
@synthesize favoriteButton;
@synthesize checkChannelButton;

@synthesize idxPath;
@synthesize delegate;

- (void)animateCell:(Boolean)flipped
{
    if (flipped)
    {
        [self unflipCellAndShow];
    }
    else
    {
        [self flipCellAndShow];
    }
}

- (void)flipCellAndShow
{
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews;
    
    [UIView transitionFromView: thumbnail
                        toView: container
                      duration: 0.5
                       options: options
                    completion: ^(BOOL finished) {}];
}

- (void)unflipCellAndShow
{
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews;
    
    [UIView transitionFromView: container
                        toView: thumbnail
                      duration: 0.5
                       options: options
                    completion: ^(BOOL finished) {}];
}

- (IBAction)favoriteButtonTapped:(UIButton *)sender
{
    if ([delegate respondsToSelector: @selector(tappedFavoriteButton:)])
    {
        [delegate tappedFavoriteButton: idxPath];
    }
}

- (IBAction)checkChannelButtonTapped:(UIButton *)sender
{
    if ([delegate respondsToSelector: @selector(tappedCheckNextChannel:)])
    {
        [delegate tappedCheckNextChannel: idxPath];
    }
}

- (void)detectedIpadForChannelCell
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIEdgeInsets imgIn = UIEdgeInsetsMake(20, 20, 20, 20);
        [self.favoriteButton setImageEdgeInsets: imgIn];
        [self.checkChannelButton setImageEdgeInsets: imgIn];
    }
}

@end
