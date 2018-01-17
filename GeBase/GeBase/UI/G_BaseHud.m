//
//  G_BaseHud.m
//  GeBase
//
//  Created by m y on 2018/1/16.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseHud.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation BaseHud {
    
    MBProgressHUD * _progressHud;
}

+ (instancetype)hud {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    return [self initWithView:[[UIApplication sharedApplication].delegate window]];
}

- (instancetype)initWithWindow:(UIWindow *)window {
    
    return [self initWithView:window];
}

- (instancetype)initWithView:(UIView *)view {
    
    self = [super init];
    if (!self || !view) return nil;
    
    _backColor = [UIColor colorWithWhite:0.8f alpha:0.6f];
    
    UIColor * fontColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    _titleAttribute = @{NSForegroundColorAttributeName: fontColor, NSFontAttributeName: [UIFont systemFontOfSize:14]};

    _indicatorColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    
    [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]].color = _indicatorColor;
    
    _progressHud = [[MBProgressHUD alloc] initWithView: view];
    _progressHud.animationType = MBProgressHUDAnimationFade;
    _progressHud.bezelView.color = _backColor;
    _progressHud.label.font = _titleAttribute[NSFontAttributeName];
    _progressHud.contentColor = _titleAttribute[NSForegroundColorAttributeName];
    _progressHud.label.numberOfLines = 0;
    
    [view addSubview:_progressHud];
    return self;
}
@end

@implementation BaseHud (ShowHide)

- (BaseHud *)showWaitWithTitle:(NSString *)title {
    
    _progressHud.mode = MBProgressHUDModeIndeterminate;
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    
    return self;
}

- (BaseHud *)showSuccessWithTitle:(NSString *)title {
    
    _progressHud.mode = MBProgressHUDModeCustomView;
    _progressHud.customView = [[UIImageView alloc] initWithImage: _successImage];
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    
    return self;
}

- (BaseHud *)showFailWithTitle:(NSString *)title {
    
    _progressHud.mode = MBProgressHUDModeCustomView;
    _progressHud.customView = [[UIImageView alloc] initWithImage: _failImage];
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    
    return self;
}

- (BaseHud *)showToastWithTitle:(NSString *)title {
    
    _progressHud.mode = MBProgressHUDModeText;
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    
    return self;
}

- (void)hideAfterDelay:(NSTimeInterval)delay {
    
    [_progressHud hideAnimated:YES afterDelay:delay];
}

- (void)hideAfterDelay:(NSTimeInterval)delay action:(G_EmptyAction)action {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_progressHud hideAnimated:YES];
        if (action) action();
    });
}

- (void)showSuccessWithTitle:(NSString *)title delay:(NSTimeInterval)delay {
    
    _progressHud.mode = MBProgressHUDModeCustomView;
    _progressHud.customView = [[UIImageView alloc] initWithImage: _successImage];
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    [_progressHud hideAnimated:YES afterDelay:delay];
}

- (void)showFailWithTitle:(NSString *)title delay:(NSTimeInterval)delay {
    
    _progressHud.mode = MBProgressHUDModeCustomView;
    _progressHud.customView = [[UIImageView alloc] initWithImage: _failImage];
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    [_progressHud hideAnimated:YES afterDelay:delay];
}

- (void)showToastWithTitle:(NSString *)title delay:(NSTimeInterval)delay {
    
    _progressHud.mode = MBProgressHUDModeText;
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    [_progressHud hideAnimated:YES afterDelay:delay];
}

- (void)showSuccessWithTitle:(NSString *)title delay:(NSTimeInterval)delay action:(G_EmptyAction)action {
    
    _progressHud.mode = MBProgressHUDModeCustomView;
    _progressHud.customView = [[UIImageView alloc] initWithImage: _successImage];
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_progressHud hideAnimated:YES];
        if (action) action();
    });
}

- (void)showFailWithTitle:(NSString *)title delay:(NSTimeInterval)delay action:(G_EmptyAction)action {
    
    _progressHud.mode = MBProgressHUDModeCustomView;
    _progressHud.customView = [[UIImageView alloc] initWithImage: _failImage];
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_progressHud hideAnimated:YES];
        if (action) action();
    });
}

- (void)showToastWithTitle:(NSString *)title delay:(NSTimeInterval)delay action:(G_EmptyAction)action {
    
    _progressHud.mode = MBProgressHUDModeText;
    _progressHud.detailsLabel.text = title;
    [_progressHud showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_progressHud hideAnimated:YES];
        if (action) action();
    });
}
@end
