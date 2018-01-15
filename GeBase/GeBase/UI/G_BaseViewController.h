//
//  G_BaseViewController.h
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G_BaseViewController : UIViewController

@property (nonatomic, strong) UIImage * g_backImage;

- (void) g_customBack: (UIBarButtonItem *)item;
@end
