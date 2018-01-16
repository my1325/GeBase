//
//  G_BaseViewController.m
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseViewController.h"

@interface G_BaseViewController ()

@end

@implementation G_BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:self.g_backImage style:UIBarButtonItemStylePlain target:self action:@selector(g_customBack:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)g_customBack:(UIBarButtonItem *)item {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
