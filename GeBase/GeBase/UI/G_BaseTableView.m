//
//  G_BaseTableView.m
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "G_BaseTableView.h"
#import <MJRefresh/MJRefresh.h>

@implementation G_BaseTableView

- (void)g_beginRefresh {
    
    if (self.mj_header.isRefreshing) {
        
        [self.mj_header endRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.mj_header beginRefreshing];
        });
    }
    else {
        
        [self.mj_header beginRefreshing];
    }
}
@end
