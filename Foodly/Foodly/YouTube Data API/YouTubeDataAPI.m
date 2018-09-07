//
//  YouTubeDataAPI.m
//  Foodly
//
//  Created by ALTRAN on 10/07/2018.
//  Copyright © 2018 App Magic. All rights reserved.
//

#import "YouTubeDataAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "Channel.h"
#import "Video.h"

@interface YouTubeDataAPI()

@end

@implementation YouTubeDataAPI

@synthesize delegate;

// Obs.: Properties put here make them private

static YouTubeDataAPI *dataApi;
static NSString *nextPageToken;
static NSString *nextVideosPageToken;

//-------------------------------------------------------------------------//
// MARK: Get instance
//-------------------------------------------------------------------------//

+ (YouTubeDataAPI *)getInstance
{
    if (dataApi == nil)
    {
        dataApi = [[YouTubeDataAPI alloc] init];
    }
    
    return dataApi;
}

//-------------------------------------------------------------------------//
// MARK: Fetch first channels batch
//-------------------------------------------------------------------------//

- (void)fetchFirstChannelsBatch:(RLMResults *)favChannels
{
    AFURLSessionManager *manager = [self getManager];
    NSString *regionCode = [self getRegionCode];
    NSString *apiKey = [self getApiKey];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&type=channel&q=culinary&regionCode=%@&key=%@", regionCode, apiKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest: request uploadProgress: ^(NSProgress *uploadProgress){} downloadProgress: ^(NSProgress *downloadProgress) {} completionHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error)
        {
            if ([delegate respondsToSelector: @selector(getFirstChannelsBatch:)])
            {
                [delegate getFirstChannelsBatch: nil];
            }
            
            NSLog(@"\n (fetchFirstChannelsBatch) Error: %@ \n", error);
            return;
        }
        
        //NSLog(@"\n response -> %@ \n", response);
        //NSLog(@"\n responseObject -> %@ \n", responseObject);
        
        if ([delegate respondsToSelector: @selector(getFirstChannelsBatch:)])
        {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            NSArray *items = responseDic[@"items"];
            
            if ([items count] == 0)
            {
                NSLog(@"\n (fetchFirstChannelsBatch) items count == 0 \n");
                
                [delegate getFirstChannelsBatch: items];
                return;
            }
            
            if (responseDic[@"nextPageToken"] != nil)
            {
                nextPageToken = responseDic[@"nextPageToken"];
            }
            else
            {
                NSLog(@"\n (fetchFirstChannelsBatch) nextPageToken is nil \n");
            }
            
            NSMutableArray *firstChannelsBatch = [NSMutableArray new];
            
            for (NSDictionary *item in items)
            {
                NSDictionary *snippet = item[@"snippet"];
                
                if (snippet[@"thumbnails"] != nil)
                {
                    NSString *channelId = (NSString *)snippet[@"channelId"];
                    NSString *channelTitle = snippet[@"channelTitle"];
                    
                    NSDictionary *thumbnails = snippet[@"thumbnails"];
                    NSString *url;
                    
                    if (thumbnails[@"high"] != nil)
                    {
                        NSDictionary *high = thumbnails[@"high"];
                        url = high[@"url"];
                    }
                    else
                    {
                        NSDictionary *def = thumbnails[@"default"];
                        url = def[@"url"];
                    }
                    
                    Channel *channel = Channel.getInstance;
                    channel.channelId = channelId;
                    channel.channelTitle = channelTitle;
                    channel.thumbnailUrl = url;
                    channel.isFavorite = false;
                    channel.isNewFavorite = false;
                    channel.isToDelete = false;
                    
                    if ([favChannels count] > 0)
                    {
                        for (Channel *favCh in favChannels)
                        {
                            if ([favCh.channelId isEqualToString: channelId])
                            {
                                channel.isFavorite = true;
                                break;
                            }
                        }
                    }
                    
                    [firstChannelsBatch addObject: channel];
                }
            }
            
            [delegate getFirstChannelsBatch: firstChannelsBatch];
        }
    }];
    
    [dataTask resume];
}

//-------------------------------------------------------------------------//
// MARK: Fetch next channels batch
//-------------------------------------------------------------------------//

- (void)fetchNextChannelsBatch:(RLMResults *)favChannels
{
    if (nextPageToken == nil)
    {
        if ([delegate respondsToSelector: @selector(getNextChannelsBatch:)])
        {
            [delegate getNextChannelsBatch: nil];
        }
        
        return;
    }
    
    AFURLSessionManager *manager = [self getManager];
    NSString *regionCode = [self getRegionCode];
    NSString *apiKey = [self getApiKey];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&type=channel&q=culinary&regionCode=%@&pageToken=%@&key=%@", regionCode, nextPageToken, apiKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest: request uploadProgress: ^(NSProgress *uploadProgress){} downloadProgress: ^(NSProgress *downloadProgress) {} completionHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error)
        {
            if ([delegate respondsToSelector: @selector(getNextChannelsBatch:)])
            {
                [delegate getNextChannelsBatch: nil];
            }
            
            NSLog(@"\n (fetchNextChannelsBatch) Error: %@ \n", error);
            return;
        }
        
        //NSLog(@"\n response -> %@ \n", response);
        //NSLog(@"\n responseObject -> %@ \n", responseObject);
        
        if ([delegate respondsToSelector: @selector(getNextChannelsBatch:)])
        {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            NSArray *items = responseDic[@"items"];
            
            if ([items count] == 0)
            {
                NSLog(@"\n (fetchNextChannelsBatch) items count == 0 \n");
                
                nextPageToken = nil;
                [delegate getNextChannelsBatch: items];
                return;
            }
            
            if (responseDic[@"nextPageToken"] != nil)
            {
                nextPageToken = responseDic[@"nextPageToken"];
            }
            else
            {
                nextPageToken = nil;
                NSLog(@"\n (fetchNextChannelsBatch) nextPageToken is nil \n");
            }
            
            NSMutableArray *nextChannelsBatch = [NSMutableArray new];
            
            for (NSDictionary *item in items)
            {
                NSDictionary *snippet = item[@"snippet"];
                
                if (snippet[@"thumbnails"] != nil)
                {
                    NSString *channelId = (NSString *)snippet[@"channelId"];
                    NSString *channelTitle = snippet[@"channelTitle"];
                    
                    NSDictionary *thumbnails = snippet[@"thumbnails"];
                    NSString *url;
                    
                    if (thumbnails[@"high"] != nil)
                    {
                        NSDictionary *high = thumbnails[@"high"];
                        url = high[@"url"];
                    }
                    else
                    {
                        NSDictionary *def = thumbnails[@"default"];
                        url = def[@"url"];
                    }
                    
                    Channel *channel = Channel.getInstance;
                    channel.channelId = channelId;
                    channel.channelTitle = channelTitle;
                    channel.thumbnailUrl = url;
                    channel.isFavorite = false;
                    channel.isNewFavorite = false;
                    channel.isToDelete = false;
                    
                    if ([favChannels count] > 0)
                    {
                        for (Channel *favCh in favChannels)
                        {
                            if ([favCh.channelId isEqualToString: channelId])
                            {
                                channel.isFavorite = true;
                                break;
                            }
                        }
                    }
                    
                    [nextChannelsBatch addObject: channel];
                }
            }
            
            [delegate getNextChannelsBatch: nextChannelsBatch];
        }
    }];
    
    [dataTask resume];
}

//-------------------------------------------------------------------------//
// MARK: Fetch channel info
//-------------------------------------------------------------------------//

- (void)fetchChannelsInfo:(Channel *)channel
{
    AFURLSessionManager *manager = [self getManager];
    NSString *apiKey = [self getApiKey];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics,contentDetails&id=%@&key=%@", channel.channelId, apiKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest: request uploadProgress: ^(NSProgress *uploadProgress){} downloadProgress: ^(NSProgress *downloadProgress) {} completionHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error)
        {
            if ([delegate respondsToSelector: @selector(getChannelInfo:)])
            {
                [delegate getChannelInfo: nil];
            }
            
            NSLog(@"\n (fetchChannelsInfo) Error: %@ \n", error);
            return;
        }
        
        //NSLog(@"\n response -> %@ \n", response);
        //NSLog(@"\n responseObject -> %@ \n", responseObject);
        
        if ([delegate respondsToSelector: @selector(getChannelInfo:)])
        {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            NSArray *items = responseDic[@"items"];
            
            if ([items count] == 0)
            {
                NSLog(@"\n (fetchChannelsInfo) items count == 0 \n");
                
                [delegate getChannelInfo: nil];
                return;
            }
            
            NSDictionary *item = items[0];
            NSDictionary *statistics = item[@"statistics"];
            channel.subscribersCount = statistics[@"subscriberCount"];
            channel.videosCount = statistics[@"videoCount"];
            
            [delegate getChannelInfo: channel];
        }
    }];
    
    [dataTask resume];
}

//-------------------------------------------------------------------------//
// MARK: Fetch first videos batch
//-------------------------------------------------------------------------//

- (void)fetchFirstVideosBatch:(NSString *)channelId
{
    nextVideosPageToken = nil;
    
    AFURLSessionManager *manager = [self getManager];
    NSString *apiKey = [self getApiKey];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.googleapis.com/youtube/v3/search?channelId=%@&part=id,snippet&order=date&maxResults=50&key=%@", channelId, apiKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest: request uploadProgress: ^(NSProgress *uploadProgress){} downloadProgress: ^(NSProgress *downloadProgress) {} completionHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error)
        {
            if ([delegate respondsToSelector: @selector(getFirstVideosBatch:)])
            {
                [delegate getFirstVideosBatch: nil];
            }
            
            NSLog(@"\n (fetchFirstVideosBatch) Error: %@ \n", error);
            return;
        }
        
        //NSLog(@"\n response -> %@ \n", response);
        //NSLog(@"\n responseObject -> %@ \n", responseObject);
        
        if ([delegate respondsToSelector: @selector(getFirstVideosBatch:)])
        {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            NSArray *items = responseDic[@"items"];
            
            if ([items count] == 0)
            {
                NSLog(@"\n (fetchFirstVideosBatch) items count == 0 \n");
                
                [delegate getFirstVideosBatch: items];
                return;
            }
            
            if (responseDic[@"nextPageToken"] != nil)
            {
                nextVideosPageToken = responseDic[@"nextPageToken"];
            }
            else
            {
                NSLog(@"\n (fetchFirstVideosBatch) nextVideosPageToken is nil \n");
            }
            
            NSMutableArray *firstVideosBatch = [NSMutableArray new];
            
            for (NSDictionary *item in items)
            {
                NSDictionary *snippet = item[@"snippet"];
                NSDictionary *item_id = item[@"id"];
                NSString *videoId = item_id[@"videoId"];
                
                if (videoId == nil) { continue; }
                
                NSString *videoTitle = snippet[@"title"];
                NSString *videoDescription = (NSString *)snippet[@"description"];
                
                if ((videoDescription == nil) || [videoDescription isEqualToString: @""])
                {
                    videoDescription = @"No description available";
                }
                
                NSDictionary *thumbnails = snippet[@"thumbnails"];
                NSString *url;
                
                if (snippet[@"thumbnails"] != nil)
                {
                    if (thumbnails[@"high"] != nil)
                    {
                        NSDictionary *high = thumbnails[@"high"];
                        url = high[@"url"];
                    }
                    else
                    {
                        NSDictionary *def = thumbnails[@"default"];
                        url = def[@"url"];
                    }
                }
                
                Video *video = Video.getInstance;
                video.videoId = videoId;
                video.videoTitle = videoTitle;
                video.videoDescription = videoDescription;
                video.thumbnailUrl = url;
                
                [firstVideosBatch addObject: video];
            }
            
            [delegate getFirstVideosBatch: firstVideosBatch];
        }
    }];
    
    [dataTask resume];
}

//-------------------------------------------------------------------------//
// MARK: Fetch next videos batch
//-------------------------------------------------------------------------//

- (void)fetchNextVideosBatch:(NSString *)channelId
{
    if (nextVideosPageToken == nil)
    {
        if ([delegate respondsToSelector: @selector(getNextVideosBatch:)])
        {
            [delegate getNextVideosBatch: nil];
        }
        
        return;
    }
    
    AFURLSessionManager *manager = [self getManager];
    NSString *apiKey = [self getApiKey];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.googleapis.com/youtube/v3/search?channelId=%@&part=id,snippet&order=date&maxResults=50&pageToken=%@&key=%@", channelId, nextVideosPageToken, apiKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest: request uploadProgress: ^(NSProgress *uploadProgress){} downloadProgress: ^(NSProgress *downloadProgress) {} completionHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error)
        {
            if ([delegate respondsToSelector: @selector(getNextVideosBatch:)])
            {
                [delegate getNextVideosBatch: nil];
            }
            
            NSLog(@"\n (fetchNextVideosBatch) Error: %@ \n", error);
            return;
        }
        
        //NSLog(@"\n response -> %@ \n", response);
        //NSLog(@"\n responseObject -> %@ \n", responseObject);
        
        if ([delegate respondsToSelector: @selector(getNextVideosBatch:)])
        {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            NSArray *items = responseDic[@"items"];
            
            if ([items count] == 0)
            {
                NSLog(@"\n (fetchNextVideosBatch) items count == 0 \n");
                
                [delegate getNextVideosBatch: items];
                return;
            }
            
            if (responseDic[@"nextPageToken"] != nil)
            {
                nextVideosPageToken = responseDic[@"nextPageToken"];
            }
            else
            {
                nextVideosPageToken = nil;
                NSLog(@"\n (fetchFirstVideosBatch) nextVideosPageToken is nil \n");
            }
            
            NSMutableArray *nextVideosBatch = [NSMutableArray new];
            
            for (NSDictionary *item in items)
            {
                NSDictionary *snippet = item[@"snippet"];
                NSDictionary *item_id = item[@"id"];
                NSString *videoId = item_id[@"videoId"];
                
                if (videoId == nil) { continue; }
                
                NSString *videoTitle = snippet[@"title"];
                NSString *videoDescription = (NSString *)snippet[@"description"];
                
                if ((videoDescription == nil) || [videoDescription isEqualToString: @""])
                {
                    videoDescription = @"No description available";
                }
                
                NSDictionary *thumbnails = snippet[@"thumbnails"];
                NSString *url;
                
                if (snippet[@"thumbnails"] != nil)
                {
                    if (thumbnails[@"high"] != nil)
                    {
                        NSDictionary *high = thumbnails[@"high"];
                        url = high[@"url"];
                    }
                    else
                    {
                        NSDictionary *def = thumbnails[@"default"];
                        url = def[@"url"];
                    }
                }
                
                Video *video = Video.getInstance;
                video.videoId = videoId;
                video.videoTitle = videoTitle;
                video.videoDescription = videoDescription;
                video.thumbnailUrl = url;
                
                [nextVideosBatch addObject: video];
            }
            
            [delegate getNextVideosBatch: nextVideosBatch];
        }
    }];
    
    [dataTask resume];
}

//-------------------------------------------------------------------------//
// MARK: Get Manager
//-------------------------------------------------------------------------//

- (AFURLSessionManager *)getManager
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [[AFURLSessionManager alloc] initWithSessionConfiguration: configuration];
}

//-------------------------------------------------------------------------//
// MARK: Get Region Code
//-------------------------------------------------------------------------//

- (NSString *)getRegionCode
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleCountryCode];
}

//-------------------------------------------------------------------------//
// MARK: Get API Key
//-------------------------------------------------------------------------//

- (NSString *)getApiKey
{
    return @"AIzaSyBYotLt5WyG3yWqFgphKmJl2qunO-T7TiY";
}

@end
