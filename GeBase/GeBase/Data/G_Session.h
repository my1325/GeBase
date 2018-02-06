//
//  G_Session.h
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit/GeKit.h>
#import "G_SessionObserver.h"

@class Cache;
@interface Session : NSObject
/**
 用户Id
 */
@property(nonatomic, strong, readonly) NSString * userId;

/**
登录token
 */
@property(nonatomic, strong, readonly) NSString * token;

/**
 用户信息
 */
@property(nonatomic, strong, readonly) id userInfo;

/**
 使用cache初始化

 @param cache Cache
 @return Session
 */
- (instancetype)initWithCache: (Cache *)cache;

/**
 默认初始化

 @return Session
 */
- (instancetype)init;

/**
 默认初始化

 @return Session
 */
+ (instancetype)session;
@end

@interface Session (Update)

/**
 登录

 @param userId userId
 @param token token
 */
- (void) signUpWithUserId: (NSString *)userId token: (NSString *)token;

/**
 登出
 */
- (void) signOut;

/**
 更新用户信息

 @param userInfo userInfo
 */
- (void) updateUserInfo: (id)userInfo;
@end

typedef NS_ENUM(NSInteger, SessionKeyPath) {
    
    SessionKeyPathUserId = 0,
    SessionKeyPathUserInfo = 1
};

@interface Session (Observer)

/**
 添加观察者

 @param observer 关联对象
 @param keyPath keyPath
 @param action 回调
 */
- (void) addObserver: (id)observer forKeyPath: (SessionKeyPath) keyPath usingAction: (SessionObserverAction)action;

/**
 移除观察者

 @param observer 关联对象
 @param keyPath keyPath
 */
- (void) removeObserver: (id)observer forKeyPath: (SessionKeyPath) keyPath;
@end
