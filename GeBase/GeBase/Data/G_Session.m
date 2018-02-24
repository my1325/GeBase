//
//  G_Session.m
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_Session.h"
#import "G_Cache.h"
#import "G_SessionObserver.h"
#import <YYModel/YYModel.h>

@interface CacheKey (Session)

@property (nonatomic, readonly, class) CacheKey * UserID;

@property (nonatomic, readonly, class) CacheKey * UserInfo;

@property (nonatomic, readonly, class) CacheKey * Token;
@end

@implementation CacheKey (Session)

+ (CacheKey *)UserID {
    
    static CacheKey * UserIDKey = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UserIDKey = [[CacheKey alloc] initWithKeyName:@"com.GeBase.CacheKey.UserId"];
    });
    
    return UserIDKey;
}

+ (CacheKey *)UserInfo {
    
    static CacheKey * UserInfoKey = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UserInfoKey = [[CacheKey alloc] initWithKeyName:@"com.GeBase.CacheKey.UserInfo"];
    });
    
    return UserInfoKey;
}

+ (CacheKey *)Token {
    
    static CacheKey * TokenKey = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        TokenKey = [[CacheKey alloc] initWithKeyName:@"com.GeBase.CacheKey.Token"];
    });
    
    return TokenKey;
}
@end

@interface Session()

@property (nonatomic, strong, readwrite) NSString * userId;

@property (nonatomic, strong, readwrite) NSString * token;

@property (nonatomic, strong, readwrite) id userInfo;

@property (nonatomic, strong, readwrite) NSMutableArray<SessionObserver *> * userIdObserver;

@property (nonatomic, strong, readwrite) NSMutableArray<SessionObserver *> * userInfoObserver;

@end

@implementation Session {
    
    Cache * _cache;
    
    dispatch_semaphore_t _lock;
}

+ (instancetype)session {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    return [self initWithCache:[Cache cache]];
}

- (instancetype)initWithCache:(Cache *)cache {
    
    self = [super init];
    if (!self)  return nil;
    
    _lock = dispatch_semaphore_create(1);
    
    _userIdObserver = @[].mutableCopy;
    _userInfoObserver = @[].mutableCopy;
    _cache = cache;
    
    _userId = _cache[CacheKey.UserID];
    _userInfo = _cache[CacheKey.UserInfo];
    _token = _cache[CacheKey.Token];
    return self;
}
@end

@implementation Session (Update)

- (void)signUpWithUserId:(NSString *)userId token:(NSString *)token {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    _cache[CacheKey.UserID] = userId;
    _cache[CacheKey.Token] = token;
    
    [_cache synchronize];
    
    self.userId = userId;
    self.token = token;
    
    for (SessionObserver * observer in _userIdObserver) {
        
        if (!observer.target) {
            
            [_userIdObserver removeObject:observer];
            continue;
        }
        
        [observer invokeActionWithData:userId];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)signOut {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        
    _cache[CacheKey.UserID] = nil;
    _cache[CacheKey.Token] = nil;
    
    [_cache synchronize];
    
    self.userId = nil;
    self.token = nil;
    
    for (SessionObserver * observer in _userIdObserver) {
        
        if (!observer.target) {
            
            [_userIdObserver removeObject:observer];
            continue;
        }
        
        [observer invokeActionWithData:nil];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)updateUserInfo:(id)userInfo {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    _cache[CacheKey.UserInfo] = [userInfo yy_modelToJSONObject];
    
    [_cache synchronize];
    
    for (SessionObserver * observer in _userInfoObserver) {
        
        if (!observer.target) {
            
            [_userInfoObserver removeObject:observer];
            continue;
        }
        
        [observer invokeActionWithData:userInfo];
    }
    dispatch_semaphore_signal(_lock);
}
@end

@implementation Session (Observer)

- (void)addObserver:(id)target forKeyPath:(SessionKeyPath)keyPath usingAction:(SessionObserverAction)action {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if (keyPath == SessionKeyPathUserId) {
        
        SessionObserver * observer = [SessionObserver observerWithTarget:target action:action];
    
        [_userIdObserver addObject:observer];
    }
    else if (keyPath == SessionKeyPathUserInfo) {
        
        SessionObserver * observer = [SessionObserver observerWithTarget:target action:action];
        
        [_userInfoObserver addObject:observer];
    }
    
    dispatch_semaphore_signal(_lock);
}

- (void)removeObserver:(id)target forKeyPath:(SessionKeyPath)keyPath {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);

    if (keyPath == SessionKeyPathUserId) {
        
        for (SessionObserver * observer in _userIdObserver) {
            
            if ([observer.target isEqual:target]) {
                
                [_userIdObserver removeObject:target];
                continue;
            }
            
            if (!observer.target) {
                
                [_userInfoObserver removeObject:observer];
            }
        }
    }
    else if (keyPath == SessionKeyPathUserInfo) {
        
        for (SessionObserver * observer in _userInfoObserver) {
            
            if ([observer.target isEqual:target]) {
                
                [_userInfoObserver removeObject:target];
                continue;
            }
            
            if (!observer.target) {
                
                [_userInfoObserver removeObject:observer];
            }
        }
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}
@end
