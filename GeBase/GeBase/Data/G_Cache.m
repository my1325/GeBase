//
//  G_Cache.m
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_Cache.h"
#import <GeKit/GeKit.h>

@implementation CacheKey {
    
    NSString * _key;
}

- (instancetype)initWithKeyName:(NSString *)keyName {
    
    if (keyName.length == 0) return nil;

    self = [super init];
    if (!self) return nil;
    
    _key = [keyName copy];
    
    return self;
}

- (instancetype)init { return nil; }

- (NSString *)stringValue { return _key; }
@end

static NSString * const kCacheFileName = @"G_Cache";
@implementation Cache  {
    
    NSCache * _cache;
    NSString * _filePath;
    NSInteger _cacheCount;
    NSMutableSet<CacheKey *> * _cacheKeys;
}

+ (instancetype)cache {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    NSString * fileDirectory = NSString.g_cachePath;
    NSString * path = [NSString stringWithFormat:@"%@/%@", fileDirectory, kCacheFileName];
    
    return [self initWithCachePath:path];
}

- (instancetype)initWithCacheName:(NSString *)cacheName {
    
    NSString * fileDirectory = NSString.g_cachePath;
    NSString * path = [NSString stringWithFormat:@"%@/%@", fileDirectory, cacheName];

    return [self initWithCachePath:path];
}

- (instancetype)initWithCacheFolder:(NSString *)folder {
    
    BOOL isFolder = NO;
    BOOL fileExists = [NSFileManager.defaultManager fileExistsAtPath:folder isDirectory:&isFolder];
    
    if (!fileExists || !isFolder) return nil;
    
    NSString * path = [NSString stringWithFormat:@"%@/%@", folder, kCacheFileName];
    
    return [self initWithCachePath:path];
}

- (instancetype)initWithCachePath:(NSString *)cachePath {
    
    BOOL isFolder = NO;
    BOOL fileExists = [NSFileManager.defaultManager fileExistsAtPath:cachePath isDirectory:&isFolder];
    
    if (isFolder) return nil;
    
    if (!fileExists) fileExists = [NSFileManager.defaultManager createFileAtPath:cachePath contents:nil attributes:nil];
    
    if (!fileExists) return nil;

    self = [super init];
    if (!self) return nil;
    
    _filePath = cachePath;
    _cache = [[NSCache alloc] init];
    _cacheKeys = [[NSMutableSet alloc] init];

    NSDictionary * caches = [NSDictionary dictionaryWithContentsOfFile:cachePath];
    
    for (NSString * key in caches.allKeys) {
     
        [_cacheKeys addObject: [[CacheKey alloc] initWithKeyName:key]];
        [_cache setObject:caches[key] forKey:key];
    }
    
    _cacheCount = _cacheKeys.count;
    
    return self;
}

- (void)setObject:(id)object forKeyedSubscript:(CacheKey *)aKey {
    
    if ([_cacheKeys containsObject:object] && !object) {
        
        _cacheCount -- ;
        [_cacheKeys removeObject:aKey];
        [_cache removeObjectForKey:[aKey stringValue]];
    }
    else if (![_cacheKeys containsObject:aKey]) {
        
        _cacheCount ++;
        [_cacheKeys addObject:aKey];
        [_cache setObject:object forKey:[aKey stringValue]];
    }
    else {
        
        [_cache setObject:object forKey:[aKey stringValue]];
    }
}

- (id)objectForKeyedSubscript:(CacheKey *)key {
    
    return [_cache objectForKey:[key stringValue]];
}

- (void)setValue:(id)value forKey:(CacheKey *)key {
    
    if ([_cacheKeys containsObject:key] && !value) {
        
        _cacheCount -- ;
        [_cacheKeys removeObject:key];
        [_cache removeObjectForKey:[key stringValue]];
    }
    else if (![_cacheKeys containsObject:key]) {
        
        _cacheCount ++;
        [_cacheKeys addObject:key];
        [_cache setObject:value forKey:[key stringValue]];
    }
    else {
        
        [_cache setObject:value forKey:[key stringValue]];
    }

    [[self dictionaryWithCache] writeToFile:_filePath atomically:YES];
}

- (id)valueForKey:(CacheKey *)key {
    
    return [_cache objectForKey:[key stringValue]];
}

- (void)synchronize {
    
    [[self dictionaryWithCache] writeToFile:_filePath atomically:YES];
}

- (NSDictionary *)dictionaryWithCache {
    
    NSMutableDictionary * dict = @{}.mutableCopy;
    
    for (CacheKey * cacheKey in _cacheKeys) {
        
        id value = [_cache objectForKey:[cacheKey stringValue]];
        [dict setValue:value forKey:[cacheKey stringValue]];
    }
    
    return [dict copy];
}
@end
