//
//  ChannelCell.h
//  Foodly
//
//  Created by ALTRAN on 18/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelCellDelegate.h"

@interface ChannelCell: UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *channelTitle;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *checkChannelButton;

@property (nonatomic, strong) NSIndexPath *idxPath;
@property (nonatomic, weak) id <ChannelCellDelegate> delegate;

- (void)animateCell:(Boolean)flipped;
- (void)detectedIpadForChannelCell;

@end
