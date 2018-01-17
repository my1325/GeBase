//
//  ViewController.m
//  GeBase
//
//  Created by m y on 2018/1/15.
//  Copyright © 2018年 m y. All rights reserved.
//

#import "ViewController.h"
#import "G_BaseRequest.h"
#import "G_BaseTarget.h"
#import "G_BaseCancelToken.h"
#import "G_BaseRequestParameter.h"

@interface ViewController ()
@property (nonatomic, strong) BaseRequest * request;
@property (nonatomic, strong) BaseCancelToken * token;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _request = [BaseRequest request];
//    http://39.108.171.244:8080/shet_mall/api/gethomedata
    
    BasePathParameter * parameter = [[BasePathParameter alloc] init];
    parameter.label = @"";
    parameter.value = @"13730639424";
    
    BaseQueryParameter * parameter1 = [[BaseQueryParameter alloc] init];
    parameter1.label = @"userId";
    parameter1.value = @"13730639424";
    
    BaseBodyParameter * parameter2 = [[BaseBodyParameter alloc] init];
    parameter2.label = @"userId";
    parameter2.value = @"13730639424";
    
    BaseTarget * target = [[BaseTarget alloc] init];
    target.URL = [NSURL URLWithString:@"http://39.108.171.244:8080/shet_mall/api/gethomedata"];
    target.parameters = @[parameter, parameter1, parameter1, parameter2];
    target.method = BaseRequestMethod.post;
    
    _token = [[[_request requestTarget:target] response:^(id retObject) {
        
        NSLog(@"responseretObject");
    }] error:^(NSError *retError) {
        
        NSLog(@"'errorertError");
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
