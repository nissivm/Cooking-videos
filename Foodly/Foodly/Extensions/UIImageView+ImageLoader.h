//
//  UIImageView+ImageLoader.h
//  Foodly
//
//  Created by ALTRAN on 12/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImageLoader)

- (void)setImageWithUrl:(NSString *)imageUrl usingPlaceholder:(NSString *)placeholder;

@end
