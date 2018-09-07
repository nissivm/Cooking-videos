//
//  AppDelegate.m
//  Foodly
//
//  Created by ALTRAN on 09/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoPlayer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    UIInterfaceOrientationMask orientationLock;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    orientationLock = UIInterfaceOrientationMaskPortrait;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return orientationLock;
}

- (void)lockOrientation:(UIInterfaceOrientationMask)orientation
{
    orientationLock = orientation;
}

- (void)rotateScreenTo:(UIInterfaceOrientation)desiredOrientation
{
    NSNumber *value = [NSNumber numberWithInt: desiredOrientation];
    [[UIDevice currentDevice] setValue: value forKey: @"orientation"];
}

- (void)lockOrientation:(UIInterfaceOrientationMask)orientation andRotateTo:(UIInterfaceOrientation)desiredOrientation
{
    [self lockOrientation: orientation];
    NSNumber *value = [NSNumber numberWithInt: desiredOrientation];
    [[UIDevice currentDevice] setValue: value forKey: @"orientation"];
}

@end
