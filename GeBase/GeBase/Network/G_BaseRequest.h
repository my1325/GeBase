//
//  G_BaseRequest.h
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface BaseRequest : NSObject

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
