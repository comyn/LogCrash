//
//  ViewController.m
//  LogCrash
//
//  Created by comyn on 2018/4/4.
//  Copyright © 2018年 comyn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"123");
    DDLogError(@"[Error]:%@", @"输出错误信息");//输出错误信息
    DDLogWarn(@"[Warn]:%@", @"输出警告信息");//输出警告信息
    DDLogInfo(@"[Info]:%@", @"输出描述信息");//输出描述信息
    DDLogDebug(@"[Debug]:%@", @"输出调试信息");//输出调试信息
    DDLogVerbose(@"[Verbose]:%@", @"输出详细信息");//输出详细信息
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //常见异常1---不存在方法引用
    
    [self performSelector:@selector(thisMthodDoesNotExist) withObject:nil];
    
    //常见异常2---键值对引用nil
    
    //    [[NSMutableDictionary dictionary] setObject:nil forKey:@"nil"];
    
    //常见异常3---数组越界
    
    [[NSArray array] objectAtIndex:1];
    
    //常见异常4---memory warning 级别3以上
    
    //    [self performSelector:@selector(killMemory) withObject:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
