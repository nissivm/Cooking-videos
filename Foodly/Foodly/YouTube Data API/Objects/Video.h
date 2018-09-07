//
//  Video.h
//  Foodly
//
//  Created by ALTRAN on 23/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video: NSObject

@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *videoDescription;
@property (nonatomic, strong) NSString *thumbnailUrl;

+ (Video *)getInstance;

@end
