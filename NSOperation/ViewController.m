//
//  ViewController.m
//  NSOperation
//
//  Created by zzy on 2023/8/5.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self NSOperationTest];
//    [self noInvisibleQueue];
//    [self testBlockOperation];
//    [self asyncCurrentOperation];
//        [self testPriority];
//    [self testCommunication];
//    [self testControlCurrentCount];
    [self testDependency];
    
}

//处理事务，基本使用
- (void)NSOperationTest {
    NSInvocation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:@"arno"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];
}
- (void)handleInvocation:(id)operation {
    NSLog(@"%@ - -----%@", operation,[NSThread currentThread]);
}
//直接处理事务，不添加隐性队列
- (void)noInvisibleQueue {
    NSInvocationOperation * op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:@"arno"];
    
    [op start];
}

- (void)testBlockOperation {
    // 初始化添加事务
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务1————%@",[NSThread currentThread]);
    }];
    // 添加事务
    [bo addExecutionBlock:^{
        NSLog(@"任务2————%@",[NSThread currentThread]);
    }];
    // 回调监听
    bo.completionBlock = ^{
        NSLog(@"完成了!!!");
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:bo];
    NSLog(@"事务添加进了NSOperationQueue");
}
- (void)asyncCurrentOperation {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (int i = 0; i < 5; i++) {
        [queue addOperationWithBlock:^{
            NSLog(@"%@----%d", [NSThread currentThread], i);
        }];
    }
}
//设置优先级
- (void)testPriority {
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            sleep(1);
            NSLog(@"第一个操作 %d --- %@", i, [NSThread currentThread]);
        }
    }];
    // 设置最高优先级
    bo1.qualityOfService = NSQualityOfServiceUserInteractive;
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"第二个操作 %d --- %@", i, [NSThread currentThread]);
        }
    }];
    // 设置最低优先级
    bo2.qualityOfService = NSQualityOfServiceBackground;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:bo1];
    [queue addOperation:bo2];
}
- (void)testCommunication {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"Felix";
    [queue addOperationWithBlock:^{
        NSLog(@"请求网络%@--%@", [NSOperationQueue currentQueue], [NSThread currentThread]);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"刷新UI%@--%@", [NSOperationQueue currentQueue], [NSThread currentThread]);
        }];
    }];
}
- (void)testControlCurrentCount{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"Felix";
    queue.maxConcurrentOperationCount = 2;
    
    for (int i = 0; i < 5; i++) {
        [queue addOperationWithBlock:^{ // 一个任务
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%d-%@",i,[NSThread currentThread]);
        }];
    }
}

- (void)testDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"请求token");
    }];
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"拿着token,请求数据1");
    }];
    
    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"拿着数据1,请求数据2");
    }];
    
    [bo2 addDependency:bo1];
    [bo1 addDependency:bo2];
   
    
    [queue addOperations:@[bo1,bo2,bo3] waitUntilFinished:YES];
    
    NSLog(@"执行完");
}


@end
