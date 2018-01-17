//
//  G_BaseTarget.h
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G_BaseRequestTarget.h"

@class BaseCancelToken;
@interface BaseTarget : NSObject<BaseRequestTarget>
/**
 URL
 */
G_StrongProperty NSURL * URL;
/**
 请求参数
 */
G_StrongProperty NSArray<id<BaseRequestParameter>> * parameters;
/**
 request封装方法
 */
G_StrongProperty BaseRequestEncoding * encoding;
/**
 request Header
 */
G_StrongProperty NSDictionary<NSString *, NSString *> * headers;

/**
 请求超时时间
 */
G_AssignProperty NSTimeInterval timeoutInterval;

/**
 请求方式
 */
G_StrongProperty BaseRequestMethod * method;
@end
