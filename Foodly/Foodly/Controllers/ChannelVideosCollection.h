//
//  ChannelVideosCollection.h
//  Foodly
//
//  Created by ALTRAN on 20/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "YouTubeDataAPI.h"

@interface ChannelVideosCollection: UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, YouTubeDataAPIDelegate>

@property (strong, nonatomic) Channel *channel;
@property (assign, nonatomic) BOOL isFavorite;

@end
