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

- (instancetype)initWithSerializer:(id<BaseResponseSerializer>)serializer {
    
    self = [super init];
    if (!self) return nil;
    
    _responseSerializer = serializer;
    return self;
}

- (void)resumeTask:(NSURLSessionTask *)task {
    
    if (_task && !_isCanceled) [_task cancel];
    
    _isCanceled = NO;
    _task = task;
    [_task resume];
}

- (void)cancel {
    
    if (_task && !_isCanceled) [_task cancel];
    
    _isCanceled = YES;
}

- (BaseCancelToken *)receiveResponse:(NSURLResponse *)response fromRequest:(NSURLRequest *)request withResponseObject:(id)responseObject error:(NSError *)error {
        
    id retObject = responseObject;
    NSError * retError = error;
#if DEBUG
    NSLog(@"request = %@\nparameters = %@\nheader = %@\nretObject = %@\nretError = %@", request.URL, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], request.allHTTPHeaderFields, retObject, retError);
#endif
    if ([_responseSerializer respondsToSelector:@selector(serializeResponseObject:fromCancelToken:error:)] && !retError) {
        
        retObject = [_responseSerializer serializeResponseObject:responseObject fromCancelToken:self error:&retError];
    }
    
    if (!retError && _responseCompletion) _responseCompletion(retObject);
    else if (_errorCompletion) _errorCompletion(retError);
    
    return self;
}
@end

@implementation BaseCancelToken (Response)

- (BaseCancelToken *)response:(BaseRequestResponse)response {
    
    _responseCompletion = [response copy];
    return self;
}

- (BaseCancelToken *)error:(BaseRequestError)error {
    
    _errorCompletion = [error copy];
    return self;
}

- (BaseCancelToken *)updateSerializer:(id<BaseResponseSerializer>)serializer {
    
    _responseSerializer = serializer;
    return self;
}
@end
