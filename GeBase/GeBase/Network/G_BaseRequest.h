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
@property(nonatomic, readonly, class) NSInteger baseRequestErrorCode;

/**
    自定义请求超时错误码
 */
@property(nonatomic, readonly, class) NSInteger baseRequestErrorTimeoutCode;
@end

@interface NSString (BaseRequest)
/**
 自定义errroDomin
 */
@property(nonatomic, strong, readonly, class) NSErrorDomain baseRequestErrorDomin;
@end

@interface NSError (BaseRequest)
/**
    请求超时错误
 */
@property(nonatomic, strong, readonly, class) NSError * timeout;
@end

@interface BaseRequest : NSObject
/**
    处理服务器返回的数据
 */
@property(nonatomic, strong) BaseResponseEncoding * reseponseEncoding;

/**
    处理服务其返回的字段
 */
@property(nonatomic, strong) id<BaseResponseSerializer> responseSerizlizer;

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
