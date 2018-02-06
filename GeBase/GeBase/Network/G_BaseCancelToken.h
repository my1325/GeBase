//
//  G_BaseCancelToken.h
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit/GeKit.h>

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
@property(nonatomic, strong, readonly) NSURLSessionTask * task;

/**
    序列化正确回调
 */
@property(nonatomic, strong, readonly) BaseRequestResponse responseCompletion;

/**
    错误回调
 */
@property(nonatomic, strong, readonly) BaseRequestError errorCompletion;

/**
    是否被取消
 */
@property(nonatomic, assign, readonly) BOOL isCanceled;

/**
    自定义格式化数据
 */
@property(nonatomic, strong, readonly) id<BaseResponseSerializer> responseSerializer;

/**
 初始化CancelToken

 @param serializer 自定义序列化对象
 @return BaseCancelToken
 */
- (instancetype)initWithSerializer: (id<BaseResponseSerializer>)serializer;

/**
 执行task

 @param task task
 */
- (void) resumeTask: (NSURLSessionTask *)task;

/**
 取消task
 */
- (void) cancel;

/**
 处理收到接口的返回信息

 @param response response
 @param request request
 @param responseObject responseObject
 @param error error
 @return BaseCancelToken
 */
- (BaseCancelToken *) receiveResponse: (NSURLResponse *)response fromRequest: (NSURLRequest *)request withResponseObject: (id)responseObject error: (NSError *)error;
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

/**
 自定义序列化对象

 @param serializer serializer
 @return BaseCancelToken
 */
- (BaseCancelToken *) updateSerializer: (id<BaseResponseSerializer>)serializer;
@end
