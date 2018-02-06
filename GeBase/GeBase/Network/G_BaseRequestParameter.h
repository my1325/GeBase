//
//  G_BaseRequestParameter.h
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit/GeKit.h>

@protocol BaseRequestParameter<NSObject>
/**
    label
 */
@property(nonatomic, strong) NSString * label;

/**
    value
 */
@property(nonatomic, strong) id value;
@end

@interface BaseQueryParameter : NSObject<BaseRequestParameter>
/**
 label
 */
@property(nonatomic, strong) NSString * label;

/**
 value
 */
@property(nonatomic, strong) id value;
@end

@interface BasePathParameter: NSObject<BaseRequestParameter>
/**
 label
 */
@property(nonatomic, strong) NSString * label;

/**
 value
 */
@property(nonatomic, strong) id value;
@end

@interface BaseBodyParameter: NSObject<BaseRequestParameter>
/**
 label
 */
@property(nonatomic, strong) NSString * label;

/**
 value
 */
@property(nonatomic, strong) id value;
@end

@interface BaseMultipartParameter: NSObject<BaseRequestParameter>
/**
 label
 */
@property(nonatomic, strong) NSString * label;

/**
 value
 */
@property(nonatomic, strong) id value;

/**
    fileName
 */
@property(nonatomic, strong) NSString * fileName;
/**
    IMAGE/JPG
 */
@property(nonatomic, strong) NSString * type;
@end
