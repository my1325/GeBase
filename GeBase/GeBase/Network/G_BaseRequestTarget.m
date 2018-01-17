//
//  G_BaseRequestTarget.m
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseRequestTarget.h"

@implementation BaseRequestMethod

+ (BaseRequestMethod *)head {
    
    static BaseRequestMethod * _head = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _head = [[BaseRequestMethod alloc] initWithStringValue:@"HEAD"];
    });
    return _head;
}

+ (BaseRequestMethod *)get {
    
    static BaseRequestMethod * _get = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _get = [[BaseRequestMethod alloc] initWithStringValue:@"GET"];
    });
    
    return _get;
}

+ (BaseRequestMethod *)post {
    
    static BaseRequestMethod * _post = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _post = [[BaseRequestMethod alloc] initWithStringValue:@"POST"];
    });
    return _post;
}

+ (BaseRequestMethod *)put {
    
    static BaseRequestMethod * _put = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _put = [[BaseRequestMethod alloc] initWithStringValue:@"PUT"];
    });
    return _put;
}

+ (BaseRequestMethod *)delete {
    
    static BaseRequestMethod * _delete = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _delete = [[BaseRequestMethod alloc] initWithStringValue:@"DELETE"];
    });
    return _delete;
}

+ (BaseRequestMethod *)patch {
    
    static BaseRequestMethod * _patch = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _patch = [[BaseRequestMethod alloc] initWithStringValue:@"PATCH"];
    });
    return _patch;
}

- (instancetype)initWithStringValue: (NSString *)value {
    
    self = [super init];
    if (!self) return nil;
    
    _stringValue = [value copy];
    
    return self;
}
@end
