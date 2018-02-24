//
// Created by m y on 2018/2/24.
// Copyright (c) 2018 m y. All rights reserved.
//

#import "G_ORM.h"
#import <GeKit.h>
#import <YYModel.h>

@implementation BasePrimaryKeyConstraint

+ (instancetype)primaryKeyWithKey:(NSString *)keyName autoIncrement:(BOOL)autoIncrement {

    return [[self alloc] initWithPrimaryKey:keyName autoIncrement:autoIncrement];
}

- (instancetype)initWithPrimaryKey: (NSString *)keyName autoIncrement: (BOOL)autoIncrement {
    self = [super init];
    if (!self) return nil;

    _isAutoIncrement = autoIncrement;
    _key = keyName.copy;
    return self;
}
@end

@implementation BaseForeignKeyConstraint

+ (instancetype)foreignKeyWithKey:(NSString *)keyName
                relatedForeignKey:(NSString *)relatedForeignKey
              relatedForeignTable:(NSString *)relatedForeignTable
                        attribute:(BaseForeignKeyAttribute)attribute {

    return [[self alloc] initWithKey:keyName
                   relatedForeignKey:relatedForeignKey
                 relatedForeignTable:relatedForeignTable
                           attribute:attribute];
}

- (instancetype)initWithKey: (NSString *)keyName
          relatedForeignKey: (NSString *)relatedForeignKey
        relatedForeignTable: (NSString *)relatedForeignTable
                  attribute: (BaseForeignKeyAttribute)attribute {
    self = [super init];
    if (!self) return nil;

    _key = keyName.copy;
    _relatedForeignKey = relatedForeignKey.copy;
    _relatedForeignTable = relatedForeignTable.copy;
    return self;
}

@end

@implementation BaseUniqueConstraint

+ (instancetype)uniqueKeyWithKey:(NSString *)keyName {

    return [[self alloc] initWithKey:keyName];
}

- (instancetype)initWithKey: (NSString *)keyName {
    self = [super init];
    _key = keyName.copy;
    return self;
}
@end


static BOOL fileCreateIfNotExitWithPath(NSString * path) {

    NSString * dbDirectory = [path stringByDeletingLastPathComponent];

    BOOL isDirectory = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:dbDirectory isDirectory:&isDirectory];

    if (!isFileExists || !isDirectory)
        return NO;//如果目录为空则返回空对象

    isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];

    if (!isFileExists || isDirectory) {

        isFileExists = [[NSFileManager defaultManager] createFileAtPath:path
                                                               contents:nil
                                                             attributes:nil];
    }

    if (!isFileExists)
        return NO;///如果文件不存在或者创建失败，返回空对象

    return YES;
}

@interface BaseDatabase()

@property (nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) FMDatabaseQueue * databaseQueue;
@end

@implementation BaseDatabase

+ (BaseDatabase *)defaultDatabase {

    static BaseDatabase * _defaultDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * defaultDBPath = [NSString stringWithFormat:@"%@/BaseDatabase", NSString.g_libraryPath];

        BOOL isDirectory = NO;
        BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:defaultDBPath isDirectory:&isDirectory];

        if (!isFileExists || !isDirectory) {
            /// 没有则创建路径
            [[NSFileManager defaultManager] createDirectoryAtPath:defaultDBPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
//        default.db
        defaultDBPath = [defaultDBPath stringByAppendingPathComponent:@"default.db"];
        _defaultDatabase = [BaseDatabase databaseWithPath:defaultDBPath];
    });

    return _defaultDatabase;
}

+ (instancetype)databaseWithPath:(NSString *)path {

    if (!fileCreateIfNotExitWithPath(path))
        return nil;

    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {

    if (!fileCreateIfNotExitWithPath(path))
        return nil;

    self = [super init];
    if (!self) return nil;

    _databasePath = path.copy;
    _lock = dispatch_semaphore_create(1);
    _isOpened = NO;
    return self;
}

- (void)open {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_isOpened)
        return;
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
    if (_databaseQueue)
        _isOpened = YES;
    dispatch_semaphore_signal(_lock);
}

- (void)close {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (!_isOpened)
        return ;
    [_databaseQueue close];
    _databaseQueue = nil;
    _isOpened = NO;
    dispatch_semaphore_signal(_lock);
}

- (void)inDatabase:(void (^)(FMDatabase *db))database {

    if (!_isOpened) {
        [self open];
    }

    if (_isOpened) {
        [_databaseQueue inDatabase:database];
    }
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))transaction {

    if (!_isOpened) {
        [self open];
    }

    if (_isOpened) {
        [_databaseQueue inTransaction:transaction];
    }
}

@end

@interface BaseSystemIndexTable: NSObject<BaseORMTable>
/**
 表名
 */
@property (nonatomic, strong) NSString * tableName;
/**
 记录数
 */
@property (nonatomic, assign) NSInteger count;
/**
 创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;
/**
 最新操作时间
 */
@property (nonatomic, assign) NSTimeInterval updateTime;
/**
 第一条数据的记录主键值
 */
@property (nonatomic, strong) id firstRecordKey;
/**
 最好一条记录的主键值
 */
@property (nonatomic, strong) id lastRecordKey;
@end

@implementation BaseSystemIndexTable

+ (NSString *)tableName {
    return @"BS_IndexTable";
}

+ (BasePrimaryKeyConstraint *)primaryKey {
    static BasePrimaryKeyConstraint * _primaryKey = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _primaryKey = [BasePrimaryKeyConstraint primaryKeyWithKey:@"tableName" autoIncrement:NO];
    });
    return _primaryKey;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    
    id json = [self yy_modelToJSONObject];
    return [[self class] yy_modelWithJSON:json];
}
@end

@interface BaseORMTableInfo: NSObject

@property (nonatomic, copy) NSString * tableName;

@property (nonatomic, strong) BasePrimaryKeyConstraint * primaryKey;

@property (nonatomic, strong) NSSet<BaseForeignKeyConstraint *> * foreignKeys;

@property (nonatomic, strong) NSSet<BaseUniqueConstraint *> * uniqueKeys;

@property (nonatomic, strong) NSSet<NSString *> * ignoreKeys;
@end

@implementation BaseORMTableInfo
@end

static NSString * transformClassInfoToTableSQL(id<BaseORMTable> table) {

    NSString * tableName = [[table class] tableName];
    
    static CFMutableDictionaryRef tableInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tableInfo = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    
    YYClassInfo * classInfo = [YYClassInfo classInfoWithClass:table.class];

    if (tableName.length == 0) {
        tableName = classInfo.name.copy;
    }
    
    BaseORMTableInfo * info = CFDictionaryGetValue(tableInfo, (__bridge const void *)(tableName));
    
    if (!info) {
        info = [[BaseORMTableInfo alloc] init];
        info.tableName = tableName;
        info.primaryKey = [[table class] primaryKey];
        info.foreignKeys = [[table class] foreignKeys];
        info.ignoreKeys = [[table class] ignoreKeys];
        info.uniqueKeys = [[table class] uniqueKeys];
        
        CFDictionarySetValue(tableInfo, (__bridge const void *)(tableName), (__bridge const void *)(info));
    }
    
    NSMutableString * transformSQL = [NSMutableString stringWithFormat:@"create table if not exists %@ (", info.tableName];
    NSSet * uniqueKeys = [NSSet setWithArray:[info.uniqueKeys.allObjects g_map:^id(BaseUniqueConstraint * uniqueKey) {
        return uniqueKey.key;
    }]];
    
    NSMutableArray * values = [NSMutableArray array];
    
    for (YYClassPropertyInfo * propertyInfo in classInfo.propertyInfos) {
        
        if ([info.ignoreKeys containsObject:propertyInfo.name] ||
            [info.primaryKey.key isEqualToString:propertyInfo.name] ||
            [uniqueKeys containsObject:propertyInfo.name])
            continue;
        
        NSString * type = @"TEXT";
    }
    
    return @"";
}

@implementation BaseDatabase (BaseORMTable)

- (BOOL)migrateTable:(id <BaseORMTable>)table {


}
@end
