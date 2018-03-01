//
// Created by m y on 2018/2/28.
// Copyright (c) 2018 m y. All rights reserved.
//

#import "G_JsonORM.h"
#import "G_Database.h"
#import <YYModel/YYModel.h>
#import <FMDB/FMDB.h>

@interface BaseJsonORM()<YYModel>
@end

@implementation BaseJsonORM

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"createTime", @"updateTime"];
}

+ (NSString *)tableName {
    return NSStringFromClass(self);
}

+ (NSString *)primaryKey {
    return nil;
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

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_count_sql = [NSString stringWithFormat:@"select count(*) as count from %@", self.tableName];

    __block long long _count = 0;
    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_count_sql];

        if ([set next]) {
            _count = [set longLongIntForColumn:@"count"];
        }
        [set close];
    }];

    return (NSInteger)_count;
}

+ (NSDictionary *)all {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_all_sql = [NSString stringWithFormat:@"select * from %@", self.tableName];

    NSMutableDictionary * _results = @{}.mutableCopy;
    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_all_sql];

        while ([set next]) {
            id json = [set objectForColumn:@"json"];
            id primaryValue = [set objectForColumn:@"primaryKey"];
            id object = [self yy_modelWithJSON:json];

            BaseJsonORM * ormObject = (BaseJsonORM *)object;
            [ormObject setCreateTime:[set doubleForColumn:@"createTime"]];
            [ormObject setUpdateTime:[set doubleForColumn:@"updateTime"]];

            [_results setObject:object forKey:primaryValue];
        }

        [set close];
    }];

    return _results.copy;
}

static NSString * select_primary_SQL = @"select * from %@ where primaryKey = ?";

+ (NSDictionary *)objectsWithPrimaryValues:(NSArray *)values {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_SQL = [NSString stringWithFormat:select_primary_SQL, self.tableName];

    NSMutableDictionary * _results = @{}.mutableCopy;
    [_database inDatabase:^(FMDatabase *db) {
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            FMResultSet * set = [db executeQuery:select_SQL, obj];
            if ([set next]) {
                id json = [set objectForColumn:@"json"];
                id primaryValue = [set objectForColumn:@"primaryKey"];
                id object = [self yy_modelWithJSON:json];

                BaseJsonORM * ormObject = (BaseJsonORM *)object;
                [ormObject setCreateTime:[set doubleForColumn:@"createTime"]];
                [ormObject setUpdateTime:[set doubleForColumn:@"updateTime"]];

                [_results setObject:object forKey:primaryValue];
            }

            [set close];
        }];
    }];
    
    return _results.copy;
}

+ (instancetype)objectWithPrimaryValue:(id)value {
    return [[self alloc] initWithPrimaryValue:value];
}

- (instancetype)initWithPrimaryValue:(id)value {

    BaseDatabase * _database = [BaseDatabase database];

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

        [set close];
    }];

    return _retValue;
}

+ (BOOL)destroy {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * drop_table_SQL = [NSString stringWithFormat:@"drop table %@", self.tableName];

    __block BOOL retValue = NO;

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        retValue = [db executeUpdate:drop_table_SQL];
    }];

    return retValue;
}

+ (BOOL)migrate {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * create_table_SQL = [NSString stringWithFormat:@"create table if not exists %@ \
                                          (primaryKey text, json text, updateTime double, createTime double)", self.tableName];

    __block BOOL retValue = NO;

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        retValue = [db executeUpdate:create_table_SQL];
    }];

    return retValue;
}

- (BOOL)delete {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    id value = [self valueForKey:[self class].primaryKey];
    NSAssert(value != nil , @"primaryKeyValue can not be nil");

    NSString * delete_table_SQL = [NSString stringWithFormat:@"delete from %@ where primaryKey = ?", [self class].tableName];

    __block BOOL retValue = NO;

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        retValue = [db executeUpdate:delete_table_SQL, value];
    }];

    return retValue;
}

- (BOOL)save {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    id value = [self valueForKey:[self class].primaryKey];
    NSAssert(value != nil , @"primaryKeyValue can not be nil");

    NSString * select_table_SQL = [NSString stringWithFormat:@"select count(*) as count from %@ where primaryKey = ?", [self class].tableName];

    NSString * update_table_SQL = [NSString stringWithFormat:@"update %@ set json = '%@', updateTime = %.3f where primaryKey = ?",
                                   [self class].tableName,
                                   [self yy_modelToJSONString],
                                   [NSDate date].timeIntervalSince1970];

    NSString * insert_table_SQL = [NSString stringWithFormat:@"insert into %@ \
                                   (primaryKey, json, updateTime, createTime) values('%@', '%@', %.3f, %.3f)",
                                   [self class].tableName,
                                   value,
                                   [self yy_modelToJSONString],
                                   [NSDate date].timeIntervalSince1970,
                                   [NSDate date].timeIntervalSince1970];

    __block BOOL retValue = NO;

    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {

        FMResultSet * set = [db executeQuery:select_table_SQL, value];

        if ([set next]) {

            NSInteger count = [set intForColumn:@"count"];

            if (count > 0) {

                retValue = [db executeUpdate:update_table_SQL, value];
            }
            else {

                retValue = [db executeUpdate:insert_table_SQL];
            }
        }
        else {

            retValue = [db executeUpdate:insert_table_SQL];
        }

        [set close];
    }];

    return retValue;
}

+ (instancetype)last {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_table_last_SQL = [NSString stringWithFormat:@"select * from %@ order by createTime desc limit 1", self.class.tableName];

    __block id retValue = nil;

    [_database inDatabase:^(FMDatabase *db) {

        FMResultSet * set = [db executeQuery:select_table_last_SQL];

        if ([set next]) {

            retValue = [[self alloc] init];
            [retValue yy_modelSetWithJSON:[set objectForColumn:@"json"]];
            [(BaseJsonORM *) retValue setUpdateTime:[set doubleForColumn:@"updateTime"]];
            [(BaseJsonORM *) retValue setCreateTime:[set doubleForColumn:@"createTime"]];
        }
        [set close];
    }];

    return retValue;
}

+ (instancetype)first {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_table_first_SQL = [NSString stringWithFormat:@"select * from %@ order by createTime limit 1", self.class.tableName];

    __block id retValue = nil;

    [_database inDatabase:^(FMDatabase *db) {

        FMResultSet * set = [db executeQuery:select_table_first_SQL];

        if ([set next]) {

            retValue = [[self alloc] init];
            [retValue yy_modelSetWithJSON:[set objectForColumn:@"json"]];
            [(BaseJsonORM *) retValue setUpdateTime:[set doubleForColumn:@"updateTime"]];
            [(BaseJsonORM *) retValue setCreateTime:[set doubleForColumn:@"createTime"]];
        }
        [set close];
    }];

    return retValue;
}
@end
