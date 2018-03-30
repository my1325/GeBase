//
// Created by m y on 2018/3/1.
// Copyright (c) 2018 m y. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseDatabase;

/*支持的类型：
 * BOOL，int, double, NSString, NSNumber, NSDate, NSURL
 * 简单操作
*/
@interface NSObject (BaseObjectORM)

/*第一条数据*/
+ (instancetype) g_first;

/*最后一条数据*/
+ (instancetype) g_last;

/*记录总数*/
+ (NSInteger) g_count;

/*查询所有*/
+ (NSArray *) g_all;

/**
 以某个字段为表示查询数据库

 @param uniqueKey 字段名
 @return NSArray
 */
+ (NSArray *) g_queryObjectsForKey: (NSString *)uniqueKey withKeyValue: (id)keyValue;

/*表迁移*/
+ (BOOL) g_migrate;

/*删除表*/
+ (BOOL) g_destroy;

/*insert*/
- (BOOL) g_save;

/*删除记录*/
- (BOOL) g_delete;

/**
 以uniqueKey 为唯一值，更新记录
 */
- (BOOL) g_updateForUniqueKey: (NSString *)uniqueKey;
@end
