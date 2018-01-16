//
//  G_BaseCancelToken.m
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseCancelToken.h"

@implementation BaseCancelToken

- (instancetype)init { return nil; }

- (instancetype)initWithTarget:(id)target usingSerializer:(id<BaseResponseSerializer>)serializer completion:(BaseRequestCompletion)completion {
    
    self = [super init];
    if (!self) return nil;
    
    _bindTarget = target;
    _completion = [completion copy];
    _responseSerializer = serializer;
    return self;
}

- (void)resumeTask:(NSURLSessionTask *)task {
    
    if (_task && !_isCanceled) [_task cancel];
    
    if (!_bindTarget) {
        
        _isCanceled = YES;
        _task = task;
        [_task cancel];
    }
    else {
    
        _isCanceled = NO;
        _task = task;
        [_task resume];
    }
}

- (void)cancel {
    
    if (_task && !_isCanceled) [_task cancel];
    
    _isCanceled = YES;
}
@end
