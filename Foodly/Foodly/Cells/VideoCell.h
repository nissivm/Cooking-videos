//
//  VideoCell.h
//  Foodly
//
//  Created by ALTRAN on 23/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCell: UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *cellContainer;
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet UILabel *videoDescription;

- (void)detectedIpadForVideoCell;

@end
