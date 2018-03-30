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
    
    NSMutableDictionary * _cache;
    NSString * _filePath;
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
    
    _cache = [NSDictionary dictionaryWithContentsOfFile:cachePath].mutableCopy;
    
    if (!_cache) {
        _cache = @{}.mutableCopy;
    }
    return self;
}

- (void)setObject:(id)object forKeyedSubscript:(CacheKey *)aKey {
    
    [_cache setValue:object forKey:[aKey stringValue]];
}

- (id)objectForKeyedSubscript:(CacheKey *)key {
    
    return [_cache valueForKey:[key stringValue]];
}

- (void)setValue:(id)value forKey:(CacheKey *)key {

    [_cache setValue:value forKey:[key stringValue]];
    [_cache writeToFile:_filePath atomically:YES];
}

- (id)valueForKey:(CacheKey *)key {
    
    return [_cache valueForKey:[key stringValue]];
}

- (void)synchronize {
    
    [_cache writeToFile:_filePath atomically:YES];
}

@end
