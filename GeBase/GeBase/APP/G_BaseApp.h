//
//  G_BaseApp.h
//  GeBase
//
//  Created by m y on 2018/1/17.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GeKit.h>
#import "G_BaseRequest.h"
#import "G_BaseTarget.h"
#import "G_BaseRequestParameter.h"
#import "G_BaseCancelToken.h"
#import "G_Session.h"
#import "G_Cache.h"
#import "G_BaseHud.h"
#import "G_SessionObserver.h"

@interface BaseApp : NSObject

G_ClassReadonlyProperty BaseApp * sharedApp;

G_ReadonlyProperty(strong) BaseRequest * request;

G_ReadonlyProperty(strong) Session * session;

G_ReadonlyProperty(strong) BaseHud * hud;

G_ReadonlyProperty(strong) UIViewController * currentViewController;

@end
