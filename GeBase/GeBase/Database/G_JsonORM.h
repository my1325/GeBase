//
// Created by m y on 2018/2/28.
// Copyright (c) 2018 m y. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseDatabase;

@interface BaseJsonORM : NSObject

@property (nonatomic, class) BaseDatabase * useDatabase;

/*表名*/
@property (nonatomic, readonly, class) NSString * tableName;

/*主键名称*/
@property (nonatomic, readonly, class) NSString * primaryKey;

/*创建时间*/
@property (nonatomic, readonly, assign) NSTimeInterval crateTime;

/*最新一次修改时间*/
@property (nonatomic, readonly, assign) NSTimeInterval updateTime;
@end

@interface BaseJsonORM (DatabaseSync)

/*数量*/
@property (nonatomic, readonly, class) NSInteger count;

/*查询所有*/
@property (nonatomic, readonly, class) NSDictionary * all;

/*删除表*/
+ (void)destroy;

/*查询满足主键条件的所有object*/
+ (NSDictionary *) objectsWithPrimaryValues: (NSArray *)values;

/*初始化查询*/
+ (instancetype) objectWithPrimaryValue: (id)value;

/*初始化查询*/
- (instancetype) initWithPrimaryValue: (id)value;

/*最后一个*/
+ (instancetype) last;

/*第一个*/
+ (instancetype) first;

/*数据库迁移*/
+ (void) migrate;

/*保存到数据库*/
- (void) save;

/*从数据库删除*/
- (void) delete;
@end