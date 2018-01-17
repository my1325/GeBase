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
G_ClassReadonlyProperty BaseRequestMethod * get;
/**
    POST
 */
G_ClassReadonlyProperty BaseRequestMethod * post;
/**
    PUT
 */
G_ClassReadonlyProperty BaseRequestMethod * put;
/**
    DELETE
 */
G_ClassReadonlyProperty BaseRequestMethod * delete;
/**
    HEAD
 */
G_ClassReadonlyProperty BaseRequestMethod * head;
/**
    PATCH
 */
G_ClassReadonlyProperty BaseRequestMethod * patch;

/**
 字符串形式
 */
G_ReadonlyProperty(strong) NSString * stringValue;
@end


/**
 请求对象
 */
@protocol BaseRequestTarget<NSObject>
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

