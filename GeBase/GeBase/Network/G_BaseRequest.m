//
//  G_BaseRequest.m
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "G_BaseCancelToken.h"
#import "G_BaseRequestTarget.h"
#import "G_BaseRequestParameter.h"

@implementation NSNumber (BaseRequest)

+ (NSInteger)baseRequestErrorTimeoutCode {
    
    static NSInteger _timeoutCode = 1000000;
    return _timeoutCode;
}

+ (NSInteger)baseRequestErrorCode {
    
    static NSInteger _errorCode = 1000001;
    return _errorCode;
}
@end

@implementation NSString (BaseRequest)

+ (NSErrorDomain)baseRequestErrorDomin {
    
    static NSErrorDomain _baseRequestErrorDomin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _baseRequestErrorDomin = @"com.GeBase.request.error.timeout";
    });
    
    return _baseRequestErrorDomin;
}
@end

@implementation NSError (BaseRequest)

+ (NSError *)timeout {

    return [NSError errorWithDomain: NSString.baseRequestErrorDomin code:NSNumber.baseRequestErrorTimeoutCode userInfo:@{NSLocalizedDescriptionKey: @"请求超时"}];
}
@end

@implementation BaseRequest {
    
    AFURLSessionManager * _manager;
    dispatch_queue_t _queue;
    dispatch_semaphore_t _lock;
}

+ (instancetype)request {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    return [self initWithManager: [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]];
}

- (instancetype)initWithManager:(AFURLSessionManager *)manager {
    
    self = [super init];
    if (!self) return nil;
    
    _reseponseEncoding = [AFJSONResponseSerializer serializer];
    _manager = manager;
    _manager.responseSerializer = _reseponseEncoding;
    _lock = dispatch_semaphore_create(1);
    _queue = dispatch_queue_create("com.GeBase.request.queue", DISPATCH_QUEUE_CONCURRENT);
    return self;
}

- (void)setReseponseEncoding:(BaseResponseEncoding *)reseponseEncoding {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _reseponseEncoding = reseponseEncoding;
    _manager.responseSerializer = reseponseEncoding;
    dispatch_semaphore_signal(_lock);
}
@end

@implementation BaseRequest (Request)

- (BaseCancelToken *)requestTarget:(id<BaseRequestTarget>)target {
    
    NSArray<id<BaseRequestParameter>> * parameters = target.parameters;
    
    NSMutableArray<BaseQueryParameter *> * queryParameters = @[].mutableCopy;
    NSMutableArray<BaseBodyParameter *> * bodyParameters = @[].mutableCopy;
    NSMutableArray<BasePathParameter *> * pathParameters = @[].mutableCopy;
    NSMutableArray<BaseMultipartParameter *> * multipartParameters = @[].mutableCopy;
    
    for (id parameter in parameters) {
        
        if ([parameter isKindOfClass:[BaseQueryParameter class]]) [queryParameters addObject:parameter];
        else if ([parameter isKindOfClass:[BaseBodyParameter class]]) [bodyParameters addObject:parameter];
        else if ([parameter isKindOfClass:[BasePathParameter class]]) [pathParameters addObject:parameter];
        else if ([parameter isKindOfClass:[BaseMultipartParameter class]]) [multipartParameters addObject:parameter];
    }
    
    // path类型的参数
    NSString * entirURL = target.URL.absoluteString;
    
    NSString * pathString = [self p_handlePathParameters:pathParameters];
    if (pathString.length > 0) entirURL = [NSString stringWithFormat:@"%@/%@", entirURL, pathString];
    
    // query类型的参数
    // 如果有文件类型的，则把body的参数放到query中
    if (multipartParameters.count > 0) {
        
        [queryParameters addObjectsFromArray:[bodyParameters g_map:^BaseQueryParameter *(BaseBodyParameter * param) {
            
            BaseQueryParameter * parameter = [[BaseQueryParameter alloc] init];
            parameter.label = [param.label copy];
            parameter.value = param.value;
            return parameter;
        }]];
        
        [bodyParameters removeAllObjects];
    }

    NSString * queryString = [self p_handleQueryParameters:queryParameters];
    if (queryString.length > 0) entirURL = [NSString stringWithFormat:@"%@?%@", entirURL, queryString];
    
    return [self p_handleEntirURL:entirURL bodyParameters:bodyParameters multipartParameters:multipartParameters fromTarget :target];
}

- (BaseCancelToken *) p_handleEntirURL: (NSString *)entirURL bodyParameters: (NSArray<BaseBodyParameter *> *)bodyParameters multipartParameters: (NSArray<BaseMultipartParameter *> *)mutilpartParameters fromTarget: (id<BaseRequestTarget>)target {
    
    NSURLRequest * request = nil;
    if (mutilpartParameters.count > 0) {
        
        request = [target.encoding multipartFormRequestWithMethod:target.method.stringValue URLString:entirURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            for (BaseMultipartParameter * parameter in mutilpartParameters)
                [formData appendPartWithFileData:parameter.value name: parameter.label fileName:parameter.fileName mimeType:parameter.type];
        } error:nil];
    }
    else {
        
        request = [target.encoding requestWithMethod:target.method.stringValue URLString:entirURL parameters:[self p_handleBodyParameters:bodyParameters] error:nil];
    }
    
    return [self p_handleRequest:request fromTarget:target];
}

- (BaseCancelToken *) p_handleRequest: (NSURLRequest *)request fromTarget: (id<BaseRequestTarget>) target {
    
    if (!request) return nil;
    
    BaseCancelToken * token = [[BaseCancelToken alloc] initWithSerializer:_responseSerizlizer];
    
    __weak typeof(token) wtoken = token;
    
    dispatch_block_t block = ^{
        
        dispatch_semaphore_t timeout = dispatch_semaphore_create(0);
        
        NSURLSessionTask * task = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
        {
            if (!wtoken || wtoken.isCanceled) return ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [wtoken receiveResponse:response fromRequest:request withResponseObject:responseObject error:error];
            });
            
            dispatch_semaphore_signal(timeout);
        }];
        
        [wtoken resumeTask:task];
        
        if (dispatch_semaphore_wait(timeout, dispatch_time(DISPATCH_TIME_NOW, (target.timeoutInterval) * NSEC_PER_SEC)) != 0) {
            
            [wtoken cancel];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [wtoken receiveResponse:nil fromRequest:request withResponseObject:nil error:NSError.timeout];
            });
        }
    };
    
    dispatch_async(_queue, block);
    
    return token;
}

- (NSString *)p_handlePathParameters: (NSArray<BasePathParameter *> *)parameters {
    
    return [[parameters g_map:^NSString *(BasePathParameter * param) {
        
        return param.value ? param.value : @"" ;
    }] componentsJoinedByString:@"-"];
}

- (NSString *)p_handleQueryParameters: (NSArray<BaseQueryParameter *> *)parameters {
    
    return [[[parameters g_filter:^BOOL(BaseQueryParameter * param) {
        
        return param.value;
    }] g_map:^NSString *(BaseQueryParameter * param) {
        
        return [NSString stringWithFormat:@"%@=%@", param.label, param.value];
    }] componentsJoinedByString:@"&"];
}

- (NSDictionary *)p_handleBodyParameters: (NSArray<BaseBodyParameter *> *)parameters {
    
    NSMutableDictionary * retValue = @{}.mutableCopy;
    
    for (BaseBodyParameter * parameter in parameters) {
        
        [retValue setValue:parameter.value forKey:parameter.label];
    }
    return retValue;
}
@end
