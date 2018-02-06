//
//  G_BaseRequestTarget.h
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit/GeKit.h>

@class AFHTTPRequestSerializer;
@protocol BaseRequestParameter;

typedef AFHTTPRequestSerializer BaseRequestEncoding;

/**
 HTTP Method
 */
@interface BaseRequestMethod: NSObject
/**
    GET
 */
@property(nonatomic, strong, readonly, class) BaseRequestMethod * get;
/**
    POST
 */
@property(nonatomic, strong, readonly, class) BaseRequestMethod * post;
/**
    PUT
 */
@property(nonatomic, strong, readonly, class) BaseRequestMethod * put;
/**
    DELETE
 */
@property(nonatomic, strong, readonly, class) BaseRequestMethod * delete;
/**
    HEAD
 */
@property(nonatomic, strong, readonly, class) BaseRequestMethod * head;
/**
    PATCH
 */
@property(nonatomic, strong, readonly, class) BaseRequestMethod * patch;

/**
 字符串形式
 */
@property(nonatomic, strong, readonly) NSString * stringValue;
@end


/**
 请求对象
 */
@protocol BaseRequestTarget<NSObject>
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

