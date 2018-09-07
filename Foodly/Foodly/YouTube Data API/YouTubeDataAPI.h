//
//  YouTubeDataAPI.h
//  Foodly
//
//  Created by ALTRAN on 10/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@protocol YouTubeDataAPIDelegate <NSObject>
@optional
- (void)getFirstChannelsBatch:(NSArray *)firstChannelsBatch;
- (void)getNextChannelsBatch:(NSArray *)nextChannelsBatch;
- (void)getChannelInfo:(Channel *)channel;
- (void)getFirstVideosBatch:(NSArray *)firstVideosBatch;
- (void)getNextVideosBatch:(NSArray *)nextVideosBatch;
@end

@interface YouTubeDataAPI: NSObject

// Obs.: Functions signatures and properties put here
//       make them public

@property (nonatomic, weak) id <YouTubeDataAPIDelegate> delegate;

+ (YouTubeDataAPI *)getInstance;
- (void)fetchFirstChannelsBatch:(RLMResults *)favChannels;
- (void)fetchNextChannelsBatch:(RLMResults *)favChannels;
- (void)fetchChannelsInfo:(Channel *)channel;
- (void)fetchFirstVideosBatch:(NSString *)channelId;
- (void)fetchNextVideosBatch:(NSString *)channelId;

@end
