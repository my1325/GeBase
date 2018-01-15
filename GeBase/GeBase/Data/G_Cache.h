//
//  G_Cache.h
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject
/**
 用cache的目录初始化Cache, 默认的cacheFile名称

 @param folder 目录路径
 @return Cache
 */
- (instancetype)initWithCacheFolder: (NSString *)folder;

/**
 用cache的路径初始化Cache

 @param cachePath cache路径
 @return Cache
 */
- (instancetype)initWithCachePath: (NSString *)cachePath;

/**
 用cache的名称初始化cache, 默认的cacheFile的目录

 @param cacheName cache名称
 @return Cache
 */
- (instancetype)initWithCacheName: (NSString *)cacheName;

/**
 默认的cache

 @return Cache
 */
+ (instancetype)cache;
@end
