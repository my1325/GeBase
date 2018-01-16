//
//  G_SessionObserver.h
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit.h>

typedef void(^SessionObserverAction)(id);

@interface SessionObserver : NSObject

/**
 唯一标示
 */
G_ReadonlyProperty(strong) NSString * identifier;

/**
 回调
 */
G_StrongProperty SessionObserverAction action;

/**
 关联对象
 */
G_WeakProperty id target;

/**
 初始化

 @param action 回调
 @param target 关联对象
 @return SessionObserver
 */
+ (instancetype)observerWithTarget: (id)target action: (SessionObserverAction)action;

/**
 调用回调

 @param data 数据
 */
- (void)invokeActionWithData: (id)data;
@end 

