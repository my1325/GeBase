//
//  G_BaseTarget.m
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseTarget.h"
#import "G_BaseRequest.h"
#import <AFNetworking.h>

@implementation BaseTarget

- (instancetype)init {
    
    self = [super init];
    if (!self) return nil;
    
    self.method = BaseRequestMethod.get;
    self.encoding = [AFHTTPRequestSerializer serializer];
    self.timeoutInterval = 10;
    return self;
}

@end
