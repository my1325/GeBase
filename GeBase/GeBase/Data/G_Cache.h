//
//  G_Cache.h
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheKey: NSObject

- (instancetype) initWithKeyName: (NSString *)keyName;

@end 

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

/**
 下标方法

 @param object object
 @param aKey aKey
 */
- (void)setObject:(id)object forKeyedSubscript:(CacheKey *)aKey;
- (id)objectForKeyedSubscript:(CacheKey *)key;
//- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;
//- (id)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 重写KVC，调用此方法会写入文件，使用下标则不会

 @param value value
 @param key key
 */
- (void)setValue:(id)value forKey:(CacheKey *)key;
- (id)valueForKey:(CacheKey *)key;

/**
 同步方法会写入文件
 */
- (void)synchronize;
@end
