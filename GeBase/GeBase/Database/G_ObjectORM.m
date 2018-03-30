//
// Created by m y on 2018/3/1.
// Copyright (c) 2018 m y. All rights reserved.
//

#import "G_ObjectORM.h"
#import "G_Database.h"
#import <objc/message.h>
#import <FMDB/FMDB.h>
#import <YYModel/YYModel.h>
#import <GeKit/NSArray+Ge.h>

static void (*g_objc_void_msg_send)(id self, SEL _cmd, ...) = (void *)objc_msgSend;

@implementation NSObject (BaseObjectORM)

+ (BOOL)g_migrate {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    YYClassInfo * classInfo = [YYClassInfo classInfoWithClass:self.class];

    NSMutableArray * properties = @[].mutableCopy;
    for (YYClassPropertyInfo * propertyInfo in classInfo.propertyInfos.allValues) {

        NSString * databaseProperty = [NSString stringWithFormat:@"%@ text", propertyInfo.name];
        [properties addObject:databaseProperty];
    }

    NSString * migrate_table_sql = [NSString stringWithFormat:@"create table if not exists %@(%@)",
                    classInfo.name,
                    [properties componentsJoinedByString:@","]];

    __block BOOL retValue = NO;

    [_database inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:migrate_table_sql];
    }];

    return retValue;
}

+ (BOOL)g_destroy {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * drop_table_SQL = [NSString stringWithFormat:@"drop table %@", NSStringFromClass(self.class)];

    __block BOOL retValue = NO;

    [_database inDatabase:^(FMDatabase *db) {
        retValue = [db executeUpdate:drop_table_SQL];
    }];

    return retValue;
}

+ (instancetype)g_first {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_table_first_sql = [NSString stringWithFormat:@"select * from %@ limit 1", NSStringFromClass(self.class)];

    __block id retValue = nil;

    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_table_first_sql];

        if ([set next]) {

            retValue = [[self alloc] init];
            [retValue p_g_setWithResultSet:set];
        }

        [set close];
    }];

    return retValue;
}

+ (instancetype)g_last {

    BaseDatabase * _database = [BaseDatabase database];

    NSAssert(_database != nil, @"must set useDatabase");

    NSString * select_table_first_sql = [NSString stringWithFormat:@"select * from %@ desc limit 1", NSStringFromClass(self.class)];

    __block id retValue = nil;

    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_table_first_sql];

        if ([set next]) {

            retValue = [[self alloc] init];
            [retValue p_g_setWithResultSet:set];
        }

        [set close];
    }];

    return retValue;
}

+ (NSInteger)g_count {
    
    BaseDatabase * _database = [BaseDatabase database];
    
    NSAssert(_database != nil, @"must set useDatabase");
    
    NSString * select_table_count_sql = [NSString stringWithFormat:@"select count(*) as count from %@", NSStringFromClass(self.class)];
    
    __block NSInteger count = 0;
    
    [_database inDatabase:^(FMDatabase *db) {
        
        FMResultSet * set = [db executeQuery:select_table_count_sql];
        
        if ([set next]) {
            count = (NSInteger)[set longLongIntForColumn:@"count"];
        }
    }];
    
    return count;
}

+ (NSArray *)g_all {
    
    BaseDatabase * _database = [BaseDatabase database];
    
    NSAssert(_database != nil, @"must set useDatabase");
    
    NSString * select_table_all_sql = [NSString stringWithFormat:@"select * from %@", NSStringFromClass(self.class)];
    
    NSMutableArray * results = @[].mutableCopy;
    
    [_database inDatabase:^(FMDatabase *db) {
        
        FMResultSet * set = [db executeQuery:select_table_all_sql];
        while ([set next]) {
            
            id object = [[self alloc] init];
            [object p_g_setWithResultSet:set];
            [results addObject:object];
        }
        [set close];
    }];
    
    return results.copy;
}

+ (NSArray *)g_queryObjectsForKey:(NSString *)uniqueKey withKeyValue:(id)keyValue {
    
    BaseDatabase * _database = [BaseDatabase database];
    
    NSAssert(_database != nil, @"must set useDatabase");
    
    NSString * select_table_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", NSStringFromClass(self.class), uniqueKey];
    
    NSMutableArray * results = @[].mutableCopy;
    
    [_database inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery:select_table_sql, keyValue];
        while ([set next]) {
            
            id object = [[self alloc] init];
            [object p_g_setWithResultSet:set];
            [results addObject:object];
        }
        [set close];
    }];
    
    return results.copy;
}

- (BOOL)g_updateForUniqueKey:(NSString *)uniqueKey {
    
    BaseDatabase * _database = [BaseDatabase database];
    
    NSAssert(_database != nil, @"must set useDatabase");
    
    NSArray * conditionArray = [self p_g_combineCondition];
    
    NSString * selecte_table_sql = [NSString stringWithFormat:@"select count(*) as count from %@ where %@ = '%@'",
                                    NSStringFromClass(self.class),
                                    uniqueKey,
                                    [self valueForKey:uniqueKey]];

    NSString * update_table_sql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'",
                                   NSStringFromClass(self.class),
                                   [conditionArray componentsJoinedByString:@","],
                                   uniqueKey,
                                   [self valueForKey:uniqueKey]];
    
    NSArray * allKeys = [conditionArray g_map:^NSString *(NSString * string) {
        return [string componentsSeparatedByString:@"="].firstObject;
    }];
    
    NSArray * allValues = [conditionArray g_map:^NSString *(NSString * string) {
        return [string componentsSeparatedByString:@"="].lastObject;
    }];
    
    NSString * insert_table_sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)",
                                   NSStringFromClass(self.class),
                                   [allKeys componentsJoinedByString:@","],
                                   [allValues componentsJoinedByString:@","]];
    
    __block BOOL retValue = NO;
    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        
        FMResultSet * set = [db executeQuery:selecte_table_sql];
        
        if ([set next]) {
            long long count = [set longLongIntForColumn:@"count"];
            if (count > 0) {
                
                retValue = [db executeUpdate:update_table_sql];
            }
            else {
                
                retValue = [db executeUpdate:insert_table_sql];
            }
        }
        else {
            
            retValue = [db executeUpdate:insert_table_sql];
        }
        [set close];
    }];
    
    return retValue;
}

- (BOOL)g_save {
    
    BaseDatabase * _database = [BaseDatabase database];
    
    NSAssert(_database != nil, @"must set useDatabase");
    
    NSArray * conditionArray = [self p_g_combineCondition];
    
    NSArray * allKeys = [conditionArray g_map:^NSString *(NSString * string) {
        return [string componentsSeparatedByString:@"="].firstObject;
    }];
    
    NSArray * allValues = [conditionArray g_map:^NSString *(NSString * string) {
        return [string componentsSeparatedByString:@"="].lastObject;
    }];
    
    NSString * insert_table_sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)",
                                   NSStringFromClass(self.class),
                                   [allKeys componentsJoinedByString:@","],
                                   [allValues componentsJoinedByString:@","]];
    
    __block BOOL retValue = NO;
    
    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        
        retValue = [db executeUpdate:insert_table_sql];
    }];
    
    return retValue;
}

- (BOOL)g_delete {
    
    BaseDatabase * _database = [BaseDatabase database];
    
    NSAssert(_database != nil, @"must set useDatabase");
    
    NSArray * conditionArray = [self p_g_combineCondition];
    
    NSString * delete_table_sql = [NSString stringWithFormat:@"delete from %@ where %@",
                                   NSStringFromClass(self.class),
                                   [conditionArray componentsJoinedByString:@" and "]];
    
    __block BOOL retValue = NO;
    [_database inTransaction:^(FMDatabase *db, BOOL *rollBack) {
        
        retValue = [db executeUpdate:delete_table_sql];
    }];
    
    return retValue;
}


- (void)p_g_setWithResultSet: (FMResultSet *)set {

    NSArray * properties = [YYClassInfo classInfoWithClass:self.class].propertyInfos.allValues;

    for (YYClassPropertyInfo * propertyInfo in properties) {

        switch (propertyInfo.type & YYEncodingTypeMask) {
            case YYEncodingTypeBool: {
                BOOL value = [set boolForColumn:propertyInfo.name];
                g_objc_void_msg_send(self, propertyInfo.setter, value);
            }break;
            case YYEncodingTypeInt8:
            case YYEncodingTypeInt16:
            case YYEncodingTypeInt32:
            case YYEncodingTypeInt64: {
                long long value = [set longLongIntForColumn:propertyInfo.name];
                g_objc_void_msg_send(self, propertyInfo.setter, value);
            }break;
            case YYEncodingTypeUInt8:
            case YYEncodingTypeUInt16:
            case YYEncodingTypeUInt32:
            case YYEncodingTypeUInt64: {
                unsigned long long value = [set unsignedLongLongIntForColumn:propertyInfo.name];
                g_objc_void_msg_send(self, propertyInfo.setter, value);
            }break;
            case YYEncodingTypeFloat:
            case YYEncodingTypeDouble:
            case YYEncodingTypeLongDouble: {
                double value = [set doubleForColumn:propertyInfo.name];
                g_objc_void_msg_send(self, propertyInfo.setter, value);
            }break;
            case YYEncodingTypeObject: {
                [self p_g_setProperty:propertyInfo withObject:[set objectForColumn:propertyInfo.name]];
            }break;
            default:
                break;
        }
    }
}

- (void)p_g_setProperty: (YYClassPropertyInfo *)propertyInfo withObject:(id)value {

    if (propertyInfo.cls == nil) return;

    if ([value isKindOfClass:propertyInfo.cls]) {
        g_objc_void_msg_send(self, propertyInfo.setter, value);
    }
    else if ([propertyInfo.cls isSubclassOfClass:[NSString class]]) {

        NSString * retValue = nil;
        if ([value isKindOfClass:[NSNumber class]]) {
            retValue = [(NSNumber *)value stringValue];
        }
        g_objc_void_msg_send(self, propertyInfo.setter, retValue);
    }
    else if ([propertyInfo.cls isSubclassOfClass:[NSNumber class]]) {

        NSNumber * retValue = nil;
        if ([value isKindOfClass:[NSString class]]) {
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            retValue = [numberFormatter numberFromString:(NSString *)value];
        }
        g_objc_void_msg_send(self, propertyInfo.setter, retValue);
    }
    else if ([propertyInfo.cls isSubclassOfClass:[NSData class]]) {
        
        NSData * retValue = nil;
        if ([value isKindOfClass:[NSString class]]) {
            
            retValue = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            
            retValue = [[(NSNumber *)value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        }
        g_objc_void_msg_send(self, propertyInfo.setter, retValue);
    }
    else if ([propertyInfo.cls isSubclassOfClass:[NSDate class]]) {
        
        NSDate * date = nil;
        
        if ([value isKindOfClass:[NSString class]]) {

            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            date = [formatter dateFromString:(NSString *)value];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {

            date = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)value doubleValue]];
        }
        g_objc_void_msg_send(self, propertyInfo.setter, date);
    }
    else if ([propertyInfo.cls isSubclassOfClass:[NSURL class]]) {

        NSURL * url = nil;
        if ([value isKindOfClass:[NSString class]]) {

            url = [NSURL URLWithString:(NSString *)value];
        }
        g_objc_void_msg_send(self, propertyInfo.setter, url);
    }
}

- (NSArray<NSString *> *)p_g_combineCondition {
    
    NSArray * properties = [YYClassInfo classInfoWithClass:self.class].propertyInfos.allValues;
    
    NSMutableArray * propertyString = @[].mutableCopy;
    for (YYClassPropertyInfo * propertyInfo in properties) {
        switch (propertyInfo.type & YYEncodingTypeMask) {
            case YYEncodingTypeBool: {
                BOOL value = ((BOOL (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
                NSString * string = [NSString stringWithFormat:@"%@='%d'", propertyInfo.name, value];
                [propertyString addObject:string];
            }break;
            case YYEncodingTypeInt8:
            case YYEncodingTypeInt16:
            case YYEncodingTypeInt32:
            case YYEncodingTypeInt64: {
                NSInteger value = ((NSInteger (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
                NSString * string = [NSString stringWithFormat:@"%@='%ld'", propertyInfo.name, (long)value];
                [propertyString addObject:string];
            }break;
            case YYEncodingTypeUInt8:
            case YYEncodingTypeUInt16:
            case YYEncodingTypeUInt32:
            case YYEncodingTypeUInt64: {
                NSUInteger value = ((NSUInteger (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
                NSString * string = [NSString stringWithFormat:@"%@='%lu'", propertyInfo.name, (unsigned long)value];
                [propertyString addObject:string];
            }break;
            case YYEncodingTypeFloat:
            case YYEncodingTypeDouble:
            case YYEncodingTypeLongDouble: {
                double value = ((double (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
                NSString * string = [NSString stringWithFormat:@"%@='%lf'", propertyInfo.name, value];
                [propertyString addObject:string];
            }break;
            case YYEncodingTypeObject: {
                id value = [self p_g_getPropertyValue:propertyInfo];
                NSString * string = [NSString stringWithFormat:@"%@='%@'", propertyInfo.name, value];
                [propertyString addObject:string];
            }break;
            default:
                break;
        }
    }
    return propertyString.copy;
}

- (id)p_g_getPropertyValue: (YYClassPropertyInfo *)property {
    
    if ([property.cls isSubclassOfClass:[NSString class]]) return [((NSString * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter) copy];
    else if ([property.cls isSubclassOfClass:[NSNumber class]]) return [[((NSNumber * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter) stringValue] copy];
    else if ([property.cls isSubclassOfClass:[NSDate class]]) return @([((NSDate * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter) timeIntervalSince1970]);
    else if ([property.cls isSubclassOfClass:[NSURL class]]) return [((NSURL * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter) absoluteString];
    
    return nil;
}
@end
