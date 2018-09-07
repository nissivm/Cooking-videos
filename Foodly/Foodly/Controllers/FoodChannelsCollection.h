//
//  FoodChannelsCollection.h
//  Foodly
//
//  Created by ALTRAN on 09/07/2018.
//  Copyright © 2018 Nissi Vieira Miranda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeDataAPI.h"
#import "ChannelCell.h"

@interface FoodChannelsCollection: UIViewController <YouTubeDataAPIDelegate, ChannelCellDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate>

@end
