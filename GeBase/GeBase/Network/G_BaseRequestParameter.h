//
//  G_BaseRequestParameter.h
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit.h>

@protocol BaseRequestParameter<NSObject>
/**
    label
 */
G_StrongProperty NSString * label;

/**
    value
 */
G_StrongProperty id value;
@end

@interface BaseQueryParameter : NSObject<BaseRequestParameter>
/**
 label
 */
G_StrongProperty NSString * label;

/**
 value
 */
G_StrongProperty id value;
@end

@interface BasePathParameter: NSObject<BaseRequestParameter>
/**
 label
 */
G_StrongProperty NSString * label;

/**
 value
 */
G_StrongProperty id value;
@end

@interface BaseBodyParameter: NSObject<BaseRequestParameter>
/**
 label
 */
G_StrongProperty NSString * label;

/**
 value
 */
G_StrongProperty id value;
@end

@interface BaseMultipartParameter: NSObject<BaseRequestParameter>
/**
 label
 */
G_StrongProperty NSString * label;

/**
 value
 */
G_StrongProperty id value;

/**
    fileName
 */
G_StrongProperty NSString * fileName;
/**
    IMAGE/JPG
 */
G_StrongProperty NSString * type;
@end
