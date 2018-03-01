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
#import "G_JsonORM.h"
#import "G_Database.h"
#import "G_ObjectORM.h"


@interface TestJsonORM: BaseJsonORM
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSDate * userBirthday;
@property (nonatomic, assign) int userAge;
@end

@implementation TestJsonORM

+ (NSString *)primaryKey {
    return @"userId";
}
@end

@interface TestObjectORM: NSObject
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSDate * userBirthday;
@property (nonatomic, assign) int userAge;
@end

@implementation TestObjectORM
@end

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
    
//    BasePathParameter * parameter = [[BasePathParameter alloc] init];
//    parameter.label = @"";
//    parameter.value = @"13730639424";
//
//    BaseQueryParameter * parameter1 = [[BaseQueryParameter alloc] init];
//    parameter1.label = @"userId";
//    parameter1.value = @"13730639424";
//
//    BaseBodyParameter * parameter2 = [[BaseBodyParameter alloc] init];
//    parameter2.label = @"userId";
//    parameter2.value = @"13730639424";
//
//    BaseTarget * target = [[BaseTarget alloc] init];
//    target.URL = [NSURL URLWithString:@"http://39.108.171.244:8080/shet_mall/api/gethomedata"];
//    target.parameters = @[parameter, parameter1, parameter1, parameter2];
//    target.method = BaseRequestMethod.post;
//
//    _token = [[[_request requestTarget:target] response:^(id retObject) {
//
//        NSLog(@"responseretObject");
//    }] error:^(NSError *retError) {
//
//        NSLog(@"'errorertError");
//    }];
    
    [BaseDatabase useDatabase:BaseDatabase.defaultDatabase];
    
    TestJsonORM * jsonORM = [[TestJsonORM alloc] init];
    jsonORM.userId = 123232;
    jsonORM.userName = @"sfadsfa";
    jsonORM.userBirthday = [NSDate date];
    jsonORM.userAge = 12;
    
    if ([TestJsonORM migrate]) {
        if ([jsonORM save]) {
            
            TestJsonORM * orm = [TestJsonORM first];
            
            orm.userAge = 14;
            
            if ([orm save]) {
                
                [orm delete];
            }
        }
    }
    
    NSArray * objectORMs = [TestObjectORM g_all];
    
    for (TestObjectORM * objectOrm in objectORMs) {
        NSLog(@"userId = %ld, userName = %@", (long)objectOrm.userId, objectOrm.userName);
        objectOrm.userName = [NSString stringWithFormat:@"name-%ld", (unsigned long)[objectORMs indexOfObject:objectOrm]];
        [objectOrm g_updateForUniqueKey:@"userId"];
    }
    
    NSArray * objectORMs1 = [TestObjectORM g_all];
    for (TestObjectORM * objectOrm in objectORMs1) {
        NSLog(@"userId = %ld, userName = %@", (long)objectOrm.userId, objectOrm.userName);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
