//
//  G_BaseHud.h
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GeKit/GeKit.h>

@interface BaseHud : NSObject
/**
富文本的attribute
 */
@property(nonatomic, strong) NSDictionary<NSAttributedStringKey, id> * titleAttribute;

/**
 转子的颜色
 */
@property(nonatomic, strong) UIColor * indicatorColor;

/**
    中间view的背景颜色
 */
@property(nonatomic, strong) UIColor * backColor;

/**
 成功的图片
 */
@property(nonatomic, strong) UIImage * successImage;

/**
    失败的图片
 */
@property(nonatomic, strong) UIImage * failImage;

/**
 默认初始化

 @return BaseHud
 */
+ (instancetype)hud;

/**
 默认初始化

 @return BaseHud
 */
- (instancetype)init;

/**
 使用window初始化

 @param window window
 @return BaseHud
 */
- (instancetype)initWithWindow: (UIWindow *)window;

/**
 使用View初始化

 @param view view
 @return BaseHud
 */
- (instancetype)initWithView: (UIView *)view;
@end

@interface BaseHud (ShowHide)

/**
 显示等待

 @param title title
 */
- (BaseHud *) showWaitWithTitle: (NSString *)title;

/**
 显示成功

 @param title title
 */
- (BaseHud *) showSuccessWithTitle: (NSString *)title;

/**
 显示失败

 @param title title
 */
- (BaseHud *) showFailWithTitle: (NSString *)title;

/**
 显示纯文本

 @param title title
 */
- (BaseHud *) showToastWithTitle: (NSString *)title;

/**
 关闭hud

 @param delay 秒
 */
- (void) hideAfterDelay: (NSTimeInterval)delay;

/**
 关闭hud

 @param delay 秒
 @param action 执行回调
 */
- (void) hideAfterDelay: (NSTimeInterval)delay action: (G_EmptyAction)action;

/**
 显示成功，并在delay秒后关闭

 @param title title
 @param delay delay
 */
- (void) showSuccessWithTitle: (NSString *)title delay: (NSTimeInterval)delay;

/**
 显示失败，并在delay秒后关闭

 @param title title
 @param delay delay
 */
- (void) showFailWithTitle: (NSString *)title delay: (NSTimeInterval)delay;

/**
 显示纯文本，并在delay秒后关闭

 @param title title
 @param delay delay
 */
- (void) showToastWithTitle: (NSString *)title delay: (NSTimeInterval)delay;

/**
 显示成功，并在delay秒后关闭且执行action，

 @param title title
 @param delay delay
 @param action action
 */
- (void) showSuccessWithTitle:(NSString *)title delay:(NSTimeInterval)delay action: (G_EmptyAction)action;

/**
 显示失败，并在delay秒后关闭且执行action

 @param title title
 @param delay delay
 @param action action
 */
- (void) showFailWithTitle: (NSString *)title delay: (NSTimeInterval)delay action: (G_EmptyAction)action;

/**
 显示纯文本，并在delay秒后关闭且执行action

 @param title title
 @param delay delay
 @param action action
 */
- (void) showToastWithTitle: (NSString *)title delay: (NSTimeInterval)delay action: (G_EmptyAction)action;

@end
