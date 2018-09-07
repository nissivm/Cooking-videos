//
//  ChannelCellDelegate.h
//  Foodly
//
//  Created by ALTRAN on 18/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChannelCellDelegate <NSObject>
@optional
- (void)tappedFavoriteButton:(NSIndexPath *)indexPath;
- (void)tappedCheckNextChannel:(NSIndexPath *)indexPath;
@end
