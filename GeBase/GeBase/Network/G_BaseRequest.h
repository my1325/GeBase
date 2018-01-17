//
//  G_BaseRequest.h
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit/GeKit.h>

@protocol BaseRequestTarget, BaseResponseSerializer;
@class BaseCancelToken, AFURLSessionManager, AFHTTPResponseSerializer;

typedef AFHTTPResponseSerializer BaseResponseEncoding ;

@interface NSNumber (BaseRequest)
/**
    自定义请求错误码
 */
G_ClassReadonlyProperty NSInteger baseRequestErrorCode;

/**
    自定义请求超时错误码
 */
G_ClassReadonlyProperty NSInteger baseRequestErrorTimeoutCode;
@end

@interface NSString (BaseRequest)
/**
 自定义errroDomin
 */
G_ClassReadonlyProperty NSErrorDomain baseRequestErrorDomin;
@end

@interface NSError (BaseRequest)
/**
    请求超时错误
 */
G_ClassReadonlyProperty NSError * timeout;
@end

@interface BaseRequest : NSObject
/**
    处理服务器返回的数据
 */
G_StrongProperty BaseResponseEncoding * reseponseEncoding;

/**
    处理服务其返回的字段
 */
G_StrongProperty id<BaseResponseSerializer> responseSerizlizer;

/**
 默认初始化

 @return BaseRequest
 */
+ (instancetype)request;

/**
 默认初始化

 @return BaseRequest
 */
- (instancetype)init;

/**
 使用AFURLSessionManager初始化

 @param manager mangager
 @return BaseRequest
 */
- (instancetype)initWithManager: (AFURLSessionManager *)manager;
@end

@interface BaseRequest (Request)
/**
 发起请求

 @param target BaseRequestTarget
 @retrun BaseCancelToken
 */
- (BaseCancelToken *) requestTarget: (id<BaseRequestTarget>) target;
@end
