//
// Created by m y on 2018/2/28.
// Copyright (c) 2018 m y. All rights reserved.
//

#import "G_Database.h"
#import <FMDB/FMDB.h>
#import <GeKit/GeKit.h>

static NSString * checkDefaultDatabaseLibrary(){

    NSString * library = [NSString stringWithFormat:@"%@/dbs", NSString.g_libraryPath];

    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:library isDirectory:&isDir];

    if (!isExists || !isDir) {
       isExists = [[NSFileManager defaultManager] createDirectoryAtPath:library
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return isExists ? library : nil;
}

static BOOL checkFileAtPath(NSString * path) {

    BOOL isDir = YES;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    if (!isExists || isDir) {
        isExists = [[NSFileManager defaultManager] createFileAtPath:path
                                                           contents:nil
                                                         attributes:nil];
    }
    return isExists;
}

@implementation BaseDatabase {
    FMDatabaseQueue * _databaseQueue;
}

+ (BaseDatabase *)defaultDatabase {
    static BaseDatabase * _database;
    static dispatch_once_t token;
    dispatch_once(&token, ^{

        _database = [BaseDatabase databaseWithName:@"default.db"];
    });
    return _database;
}

+ (instancetype)databaseWithName:(NSString *)name {

    NSString * defaultPath = checkDefaultDatabaseLibrary();
    if (defaultPath.length > 0) {
        defaultPath = [NSString stringWithFormat:@"%@/name", defaultPath];
    }

    return [self databaseWithPath:defaultPath];
}

+ (instancetype)databaseWithPath:(NSString *)path {

    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithName:(NSString *)name {

    NSString * defaultPath = checkDefaultDatabaseLibrary();
    if (defaultPath.length > 0) {
        defaultPath = [NSString stringWithFormat:@"%@/name", defaultPath];
    }

    return [self initWithPath:defaultPath];
}

- (instancetype)initWithPath:(NSString *)path {

    if (!checkFileAtPath(path)) {
        return nil;
    }

    self = [super init];
    if (!self) return nil;

    _path = path.copy;
    _name = path.lastPathComponent.copy;
    _isOpened = NO;
    return self;
}

- (void)open {

    if (_isOpened) return;

    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_path];
    if (_databaseQueue) _isOpened = YES;
}

- (void)close {

    if (!_isOpened) return;

    [_databaseQueue close];
    _databaseQueue = nil;
    _isOpened = NO;
}

static BaseDatabase * _database;
+ (BaseDatabase *)database {
    return _database;
}

+ (void)useDatabase:(BaseDatabase *)database {
    _database = database;
}

- (void)dealloc {
    [self close];
}
@end

@implementation BaseDatabase (Execute)

- (void)inDatabase:(void (^)(FMDatabase *db))block {

    [self open];

    [_databaseQueue inDatabase:block];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollBack))block {

    [self open];

    [_databaseQueue inTransaction:block];
}

@end
