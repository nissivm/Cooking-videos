//
//  Channel.m
//  Foodly
//
//  Created by ALTRAN on 10/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "Channel.h"

@implementation Channel

@synthesize channelId;
@synthesize channelTitle;
@synthesize thumbnailUrl;

@synthesize subscribersCount;
@synthesize videosCount;

@synthesize isFavorite;
@synthesize isNewFavorite;
@synthesize isToDelete;

+ (Channel *)getInstance
{
    return [[Channel alloc] init];
}

@end
