//
//  FoodlyNavController.m
//  Foodly
//
//  Created by ALTRAN on 24/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "FoodlyNavController.h"
#import "VideoPlayer.h"

@interface FoodlyNavController ()

@end

@implementation FoodlyNavController

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[self topViewController] isKindOfClass: [VideoPlayer class]])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[self topViewController] isKindOfClass: [VideoPlayer class]])
    {
        return true;
    }
    else
    {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

@end
