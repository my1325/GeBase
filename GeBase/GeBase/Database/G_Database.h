//
// Created by m y on 2018/2/28.
// Copyright (c) 2018 m y. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FMDatabase;

@interface BaseDatabase : NSObject

/*单例（默认为library/dbs/default.db）*/
@property (nonatomic, readonly, class) BaseDatabase * defaultDatabase;

/*数据库路径*/
@property (nonatomic, readonly, strong) NSString * path;

/*数据库名称*/
@property (nonatomic, readonly, strong) NSString * name;

/*是否打开*/
@property (nonatomic, readonly, assign) BOOL isOpened;

@property (nonatomic, readonly, class) BaseDatabase * database;

/*初始化方法,文件不存在，目录存在*/
+ (instancetype) databaseWithPath: (NSString *)path;

/*默认目录下创建名称为name的数据库文件,该文件不存在*/
+ (instancetype) databaseWithName: (NSString *)name;

/*初始化方法, 文件不存在，目录存在*/
- (instancetype) initWithPath: (NSString *)path;

/*默认目录下创建名称为name的数据库文件,该文件不存在*/
- (instancetype) initWithName: (NSString *)name;

/*打开数据*/
- (void) open;

/*关闭数据库*/
- (void) close;

+ (void) useDatabase: (BaseDatabase *)database;
@end

@interface BaseDatabase (Execute)

/*执行SQL*/
- (void) inDatabase: (void(^)(FMDatabase * db))block;

/*在事务中执行SQL*/
- (void) inTransaction: (void(^)(FMDatabase * db, BOOL * rollBack))block;
@end

