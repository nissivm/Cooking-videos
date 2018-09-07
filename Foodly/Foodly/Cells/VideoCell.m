//
//  VideoCell.m
//  Foodly
//
//  Created by ALTRAN on 23/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "VideoCell.h"
#import "AppDelegate.h"

@implementation VideoCell

@synthesize cellContainer;
@synthesize videoThumbnail;
@synthesize videoTitle;
@synthesize videoDescription;

- (void)detectedIpadForVideoCell
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (SCREEN_HEIGHT == 2732) // iPad Pro 12.9"
        {
            [videoTitle setFont: [UIFont fontWithName: @"Thonburi-Bold" size: 26]];
            [videoDescription setFont: [UIFont fontWithName: @"Thonburi" size: 23]];
        }
    }
}

@end
