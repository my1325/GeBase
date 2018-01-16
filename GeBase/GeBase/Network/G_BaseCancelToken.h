//
//  G_BaseCancelToken.h
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit.h>

typedef void(^BaseRequestCompletion)(NSURLRequest * request, NSURLResponse * response, NSError * error);
typedef void(^BaseRequestResponse)(id retObject);
typedef void(^BaseRequestError)(NSError * retError);

@class BaseCancelToken;

@protocol BaseResponseSerializer<NSObject>

@optional
/**
 序列化服务器返回数据接口

 @param object JSONObject
 @param token BaseCancelToken
 @param error 错误
 @return 自定义数据结构
 */
- (id) serializeResponseObject: (id)object fromCancelToken: (BaseCancelToken *)token error: (NSError **)error;
@end

@interface BaseCancelToken : NSObject

/**
    task
 */
G_ReadonlyProperty(strong) NSURLSessionTask * task;

/**
    完成回调
 */
G_ReadonlyProperty(strong) BaseRequestCompletion completion;

/**
    序列化正确回调
 */
G_ReadonlyProperty(strong) BaseRequestResponse responseCompletion;

/**
    错误回调
 */
G_ReadonlyProperty(strong) BaseRequestError errorCompletion;

/**
    关联对象
 */
G_ReadonlyProperty(weak) id bindTarget;

/**
    是否被取消
 */
G_ReadonlyProperty(assign) BOOL isCanceled;

/**
    自定义格式化数据
 */
G_ReadonlyProperty(strong) id<BaseResponseSerializer> responseSerializer;

/**
 初始化CancelToken

 @param target target
 @param completion 完成回调
 @return BaseCancelToken
 */
- (instancetype)initWithTarget: (id)target usingSerializer: (id<BaseResponseSerializer>)serializer completion: (BaseRequestCompletion)completion;

/**
 执行task

 @param task task
 */
- (void) resumeTask: (NSURLSessionTask *)task;

/**
 取消task
 */
- (void) cancel;
@end

@interface BaseCancelToken (Response)

/**
 序列化正确回调

 @param response 回调
 @return BaseCancelToken
 */
- (BaseCancelToken *) response: (BaseRequestResponse)response;

/**
 错误回调

 @param error error
 @return BaseCancelToken
 */
- (BaseCancelToken *) error: (BaseRequestError)error;
@end
