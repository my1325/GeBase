//
//  G_BaseApp.h
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit/GeKit.h>
#import "G_BaseRequest.h"
#import "G_BaseTarget.h"
#import "G_BaseRequestParameter.h"
#import "G_BaseCancelToken.h"
#import "G_Session.h"
#import "G_Cache.h"
#import "G_BaseHud.h"
#import "G_SessionObserver.h"

@interface BaseApp : NSObject

@property (nonatomic, readonly, class) BaseApp * sharedApp;

@property (nonatomic, readonly, strong) BaseRequest * request;

@property (nonatomic, readonly, strong) Session * session;

@property (nonatomic, readonly, strong) BaseHud * hud;

@property (nonatomic, readonly, strong) UIViewController * currentViewController;

@end
