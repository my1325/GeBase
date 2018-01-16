//
//  G_SessionObserver.m
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_SessionObserver.h"


@implementation SessionObserver

+ (instancetype)observerWithTarget:(id)target action:(SessionObserverAction)action {
    
    return [[self alloc] initWithTarget:target action:action];
}

- (instancetype)initWithTarget: (id)target action: (SessionObserverAction)action {
    
    self = [super init];
    if (!self) return nil;
    
    _target = target;
    _action = action;
    _identifier = [NSString stringWithFormat:@"-initWithTarget: %@ action: %@", target, action];
    return self;
}

- (void)invokeActionWithData:(id)data {
    
    if (_action) _action(data);
}
@end
