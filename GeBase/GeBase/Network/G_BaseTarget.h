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
@property(nonatomic, strong) NSURL * URL;
/**
 请求参数
 */
@property(nonatomic, strong) NSArray<id<BaseRequestParameter>> * parameters;
/**
 request封装方法
 */
@property(nonatomic, strong) BaseRequestEncoding * encoding;
/**
 request Header
 */
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> * headers;

/**
 请求超时时间
 */
@property(nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 请求方式
 */
@property(nonatomic, strong) BaseRequestMethod * method;
@end
