//
//  UIImageView+ImageLoader.m
//  Foodly
//
//  Created by ALTRAN on 12/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "UIImageView+ImageLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (ImageLoader)

- (void)setImageWithUrl:(NSString *)imageUrl usingPlaceholder:(NSString *)placeholder
{
    NSURL *url = [NSURL URLWithString: imageUrl];
    UIImage *plHolder = [UIImage imageNamed: placeholder];
    [self sd_setImageWithURL: url placeholderImage: plHolder];
}

@end
