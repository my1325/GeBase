//
// Created by m y on 2018/2/28.
// Copyright (c) 2018 m y. All rights reserved.
//

#import "G_JsonORM.h"
#import "G_Database.h"
#import "NSObject+YYModel.h"
#import <FMDB.h>

static __weak BaseDatabase * _database;
@implementation BaseJsonORM {
    dispatch_queue_t _queue;
}

+ (NSString *)tableName {
    return NSStringFromClass(self);
}

+ (NSString *)primaryKey {
    return nil;
}

+ (BaseDatabase *)useDatabase {
    return _database;
}

+ (void)setUseDatabase:(BaseDatabase *)useDatabase {
    _database = useDatabase;
}

- (void)setCreateTime: (NSTimeInterval)crateTime {
    _crateTime = crateTime;
}

- (void)setUpdateTime: (NSTimeInterval)updateTime {
    _updateTime = updateTime;
}
@end

@implementation BaseJsonORM (DatabaseSync)

+ (NSInteger)count {

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_count_sql = [NSString stringWithFormat:@"select count(*) as count from %@", self.tableName];

    __block NSInteger _count = 0;
    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_count_sql];

        if ([set next]) {
            _count = [set longLongIntForColumn:@"count"];
        }
    }];

    return _count;
}

+ (NSDictionary *)all {

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_all_sql = [NSString stringWithFormat:@"select * from %@", self.tableName];

    NSMutableDictionary * _results = @{}.mutableCopy;
    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_all_sql];

        while ([set next]) {
            id json = [set objectForColumn:@"json"];
            id primaryValue = [set objectForColumn:@"primary"];
            id object = [self yy_modelWithJSON:json];

            BaseJsonORM * ormObject = (BaseJsonORM *)object;
            [ormObject setCreateTime:[set doubleForColumn:@"createTime"]];
            [ormObject setUpdateTime:[set doubleForColumn:@"updateTime"]];

            [_results setObject:object forKey:primaryValue];
        }
    }];

    return _results.copy;
}

static NSString * select_primary_SQL = @"select * from %@ where primary = ?";

+ (NSDictionary *)objectsWithPrimaryValues:(NSArray *)values {

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_SQL = [NSString stringWithFormat:select_primary_SQL, self.tableName];

    NSMutableDictionary * _results = @{}.mutableCopy;
    [_database inDatabase:^(FMDatabase *db) {
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            FMResultSet * set = [db executeQuery:select_SQL, obj];
            if ([set next]) {
                id json = [set objectForColumn:@"json"];
                id primaryValue = [set objectForColumn:@"primary"];
                id object = [self yy_modelWithJSON:json];

                BaseJsonORM * ormObject = (BaseJsonORM *)object;
                [ormObject setCreateTime:[set doubleForColumn:@"createTime"]];
                [ormObject setUpdateTime:[set doubleForColumn:@"updateTime"]];

                [_results setObject:object forKey:primaryValue];
            }
        }];
    }];
    
    return _results.copy;
}

+ (instancetype)objectWithPrimaryValue:(id)value {
    return [[self alloc] initWithPrimaryValue:value];
}

- (instancetype)initWithPrimaryValue:(id)value {

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_SQL = [NSString stringWithFormat:select_primary_SQL, [self class].tableName];

    __block id _retValue = nil;
    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_SQL, value];


        if ([set next]) {
            id json = [set objectForColumn:@"json"];

            id object = [self init];
            [object yy_modelSetWithJSON:json];

            BaseJsonORM * ormObject = (BaseJsonORM *)object;
            [ormObject setCreateTime:[set doubleForColumn:@"createTime"]];
            [ormObject setUpdateTime:[set doubleForColumn:@"updateTime"]];

            _retValue = object;
        }
    }];

    return _retValue;
}

+ (void)destroy {

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * drop_table_SQL = [NSString stringWithFormat:@"drop table %@", self.tableName];

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        [db executeUpdate:drop_table_SQL];
    }];
}

+ (void)migrate {

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * create_table_SQL = [NSString stringWithFormat:@"create table if not exists %@ \
                                          (primary text, json text, updateTime double, createTime double)", self.tableName];

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        [db executeUpdate:create_table_SQL];
    }];
}

- (void)delete {

    NSAssert(_database != nil, @"must set useDatabase");

    id value = [self valueForKey:[self class].primaryKey];
    NSAssert(value != nil , @"primaryKeyValue can not be nil");

    NSString * delete_table_SQL = [NSString stringWithFormat:@"delete from %@ where primary = ?", [self class].tableName];

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        [db executeUpdate:delete_table_SQL, value];
    }];
}

- (void)save {

    NSAssert(_database != nil, @"must set useDatabase");

    id value = [self valueForKey:[self class].primaryKey];
    NSAssert(value != nil , @"primaryKeyValue can not be nil");

    NSString * select_table_SQL = [NSString stringWithFormat:@"select count(*) as count from %@ where primary = ?", [self class].tableName];

    NSString * update_table_SQL = [NSString stringWithFormat:@"update table %@ set json = %@, updateTime = %.3f where primary = ?",
                                   [self class].tableName,
                                   [self yy_modelToJSONString],
                                   [NSDate date].timeIntervalSince1970];

    NSString * insert_table_SQL = [NSString stringWithFormat:@"insert into %@ \
                                   (primary, json, updateTime, createTime) (%@, %@, %.3f, %.3f)",
                                   [self class].tableName,
                                   value,
                                   [self yy_modelToJSONString],
                                   [NSDate date].timeIntervalSince1970,
                                   [NSDate date].timeIntervalSince1970];

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {

        FMResultSet * set = [db executeQuery:select_table_SQL, value];

        if ([set next]) {

            NSInteger count = [set intForColumn:@"count"];

            if (count > 0) {

                [db executeUpdate:update_table_SQL, value];
            }
            else {

                [db executeUpdate:insert_table_SQL];
            }
        }
        else {

            [db executeUpdate:insert_table_SQL];
        }
    }];
}

- (instancetype)last {
}

- (instancetype)first {
}
@end
