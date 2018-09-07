//
//  Video.m
//  Foodly
//
//  Created by ALTRAN on 23/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "Video.h"

@implementation Video

@synthesize videoId;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize thumbnailUrl;

+ (Video *)getInstance
{
    return [[Video alloc] init];
}

@end
