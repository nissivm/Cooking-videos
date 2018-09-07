//
//  AppDelegate.h
//  Foodly
//
//  Created by ALTRAN on 09/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_HEIGHT [UIScreen mainScreen].nativeBounds.size.height

@interface AppDelegate: UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)lockOrientation:(UIInterfaceOrientationMask)orientation;
- (void)rotateScreenTo:(UIInterfaceOrientation)desiredOrientation;
- (void)lockOrientation:(UIInterfaceOrientationMask)orientation andRotateTo:(UIInterfaceOrientation)desiredOrientation;

@end

