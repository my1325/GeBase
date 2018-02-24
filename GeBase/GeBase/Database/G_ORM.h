//
// Created by m y on 2018/2/24.
// Copyright (c) 2018 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@protocol BaseConstraint<NSObject>
@end

@interface BasePrimaryKeyConstraint: NSObject <BaseConstraint>
/*主键名称*/
@property (nonatomic, strong, readonly) NSString * key;
/*是否自增*/
@property (nonatomic, assign, readonly) BOOL isAutoIncrement;
/*初始化方法*/
+ (instancetype) primaryKeyWithKey: (NSString *)keyName
                     autoIncrement: (BOOL)autoIncrement;
@end

@interface BaseUniqueConstraint: NSObject <BaseConstraint>
/*唯一键名称*/
@property (nonatomic, strong, readonly) NSString * key;
/*初始化方法*/
+ (instancetype) uniqueKeyWithKey: (NSString *)keyName;
@end

typedef NS_ENUM(NSInteger, BaseForeignKeyAttribute) {

    BaseForeignKeyAttributeIgnore,
    BaseForeignKeyAttributeDelete
};

@interface BaseForeignKeyConstraint: NSObject <BaseConstraint>
/*外键名称*/
@property (nonatomic, strong, readonly) NSString * key;
/*关联的外键对应的键*/
@property (nonatomic, strong, readonly) NSString * relatedForeignKey;
/*关联的外键对应的表名*/
@property (nonatomic, strong, readonly) NSString * relatedForeignTable;
/*外键属性*/
@property (nonatomic, assign, readonly) BaseForeignKeyAttribute attribute;
/*初始化方法*/
+ (instancetype) foreignKeyWithKey: (NSString *)keyName
                 relatedForeignKey: (NSString *)relatedForeignKey
               relatedForeignTable: (NSString *)relatedForeignTable
                         attribute: (BaseForeignKeyAttribute)attribute;
@end

@protocol BaseORMTable;

@protocol BaseDatabaseTrigger <NSObject>
@optional

- (BOOL) ormTableShouldInsertRecord: (id<BaseORMTable>)record;

- (void) ormTableWillInsertRecord: (id<BaseORMTable>)record;

- (void) ormTableDidInsertRecord: (id<BaseORMTable>)record;


- (BOOL) ormTable: (id<BaseORMTable>)oldRecord shouldUpdateToRecord: (id<BaseORMTable>)newRecord;

- (void) ormTable: (id<BaseORMTable>)oldRecord willUpdateToRecord: (id<BaseORMTable>)newRecord;

- (void) ormTable: (id<BaseORMTable>)oldRecord didUpdateToRecord: (id<BaseORMTable>)newRecord;


- (BOOL) ormTableShouldDeleteRecord: (id<BaseORMTable>)record;

- (void) ormTableWillDeleteRecord: (id<BaseORMTable>)record;

- (void) ormTableDidDeleteRecord: (id<BaseORMTable>)record;
@end

@protocol BaseORMTable<NSObject, NSCopying>
@optional
/*表名*/
@property (nonatomic, readonly, class) NSString * tableName;
/*主键*/
@property (nonatomic, readonly, class) BasePrimaryKeyConstraint * primaryKey;
/*唯一约束*/
@property (nonatomic, readonly, class) NSSet<BaseUniqueConstraint *> * uniqueKeys;
/*外键*/
@property (nonatomic, readonly, class) NSSet<BaseForeignKeyConstraint *> * foreignKeys;
/*忽略的键*/
@property (nonatomic, readonly, class) NSSet<NSString *> * ignoreKeys;
/*groupBy的key*/
@property (nonatomic, class) NSString * groupKey;
/*orderBy的key*/
@property (nonatomic, class) NSString * orderKey;
/*查询限制，0为不加限制*/
@property (nonatomic, class) NSInteger limit;
/*查询排列方式：desc-YES, esc-NO*/
@property (nonatomic, class) BOOL desc;
/*触发器*/
@property (nonatomic, strong) id<BaseDatabaseTrigger> trigger;
@end




@interface BaseDatabase: NSObject
/*默认路径创建db*/
@property (nonatomic, readonly, class) BaseDatabase * defaultDatabase;
/*数据库路径*/
@property (nonatomic, strong, readonly) NSString * databasePath;
/*是否已经打开*/
@property (nonatomic, assign, readonly) BOOL isOpened;

/*初始化方法*/
+ (instancetype) databaseWithPath: (NSString *)path;
/*初始化方法*/
- (instancetype) initWithPath: (NSString *)path;

/*打开数据库*/
- (void) open;
/*关闭数据库*/
- (void) close;

/*操作数据库*/
- (void) inDatabase: (void(^)(FMDatabase * db))database;
/*事务操作*/
- (void) inTransaction: (void(^)(FMDatabase * db, BOOL * rollback))transaction;
@end

@interface BaseDatabase (BaseORMTable)

/*数据库迁移*/
- (BOOL) migrateTable: (id<BaseORMTable>)table;

/*删除表*/
- (BOOL) destroyTable: (id<BaseORMTable>)table;

/*插入或者更新满足条件的第一条记录*/
- (BOOL) insertTableOrUpdate: (id<BaseORMTable>)record;
/*批量更新满足条件的第一条记录*/
- (BOOL) updateTables: (id<BaseORMTable>)records;
/*更新满足条件的所有记录*/
- (BOOL) updateTable: (id<BaseORMTable>)record;

/*批量插入*/
- (BOOL) insertTables: (NSArray<id<BaseORMTable>> *)records;

/*删除满足该条件的第一条记录*/
- (BOOL) deleteTable: (id<BaseORMTable>)record;
/*批量删除, 满足该条件的第一条记录*/
- (BOOL) deleteTables: (NSArray<id<BaseORMTable>> *)records;
/*删除满足该条件的所有记录*/
- (BOOL) deleteAllInTable: (id<BaseORMTable>)record;

/*查询所有记录数量*/
- (NSInteger) countTable: (id<BaseORMTable>)table;
/*查询所有记录*/
- (NSArray<id<BaseORMTable>> *) allInTable: (id<BaseORMTable>)table;
/*筛选条件*/
- (NSArray<id<BaseORMTable>> *) filtersInTable: (id<BaseORMTable>)table;
/*第一条记录*/
- (id<BaseORMTable>) firstInTable: (id<BaseORMTable>) table;
/*最后一条记录*/
- (id<BaseORMTable>) lastInTable: (id<BaseORMTable>) table;
@end
