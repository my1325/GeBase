//
//  G_BaseApp.m
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseApp.h"

@implementation BaseApp

+ (BaseApp *)sharedApp {
    
    static BaseApp * _app = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _app = [[BaseApp alloc] init];
    });
    return _app;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) return nil;
    
    _request = [BaseRequest request];
    _hud = [BaseHud hud];
    _session = [Session session];
    return self;
}

- (UIViewController *)currentViewController {
    
    return [self p_currentViewController];
}

- (UIViewController*)p_topMostWindowController
{
    UIViewController *topController = [[[UIApplication sharedApplication].delegate window] rootViewController];
    
    //  Getting topMost ViewController
    while ([topController presentedViewController]) topController = [topController presentedViewController];
    
    //  Returning topMost ViewController
    return topController;
}

- (UIViewController*)p_currentViewController;
{
    UIViewController *currentViewController = [self p_topMostWindowController];
    
    while ([currentViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)currentViewController topViewController])
        currentViewController = [(UINavigationController*)currentViewController topViewController];
    
    return currentViewController;
}

@end
