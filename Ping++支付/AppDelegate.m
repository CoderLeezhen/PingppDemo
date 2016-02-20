//
//  AppDelegate.m
//  Ping++支付
//
//  Created by lizhen on 16/1/29.
//  Copyright © 2016年 lizhen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <Pingpp.h>
#define kUrl            @"http://218.244.151.190/demo/charge" // 你的服务端创建并返回 charge 的 URL 地址，此地址仅供测试用。
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc]init];
    _nav = [[UINavigationController alloc]initWithRootViewController:vc];
    _window.rootViewController = _nav;
    //打开调试模式
    [Pingpp setDebugMode:YES];
    return YES;
}
#warning 渠道为微信、支付宝且安装了支付宝钱包时实现方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    [Pingpp handleOpenURL:[NSURL URLWithString:kUrl] withCompletion:^(NSString *result, PingppError *error) {
        if ([result isEqualToString:@"success"]) {
            //...
        }else{
            NSLog(@"PingppError: code=%lu msg=%@", error.code, [error getMsg]);
        }
    }];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
