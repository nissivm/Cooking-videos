//
//  Channel.h
//  Foodly
//
//  Created by ALTRAN on 10/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Channel: RLMObject

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelTitle;
@property (nonatomic, strong) NSString *thumbnailUrl;

@property (nonatomic, strong) NSString *subscribersCount;
@property (nonatomic, strong) NSString *videosCount;

@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL isNewFavorite;
@property (nonatomic, assign) BOOL isToDelete;

+ (Channel *)getInstance;

@end
