//
//  AppDelegate.m
//  FishHook
//
//  Created by jufan wang on 2018/10/4.
//  Copyright © 2018年 jufan wang. All rights reserved.
//

#import "AppDelegate.h"

#import <objc/runtime.h>
#import <objc/NSObjCRuntime.h>
#import "YDCrashProtector.h"
//extern SEL SEL_release;

@interface AppDelegate ()
@property (nonatomic, weak) NSObject * outer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    crashProtectorHook();
//    SEL msel = SEL_release;
    
//    int i = 1+256;
//    char * p = &i;
//    NSLog(@"%d", *p);
//    NSLog(@"%d", *(p+1));
//    NSLog(@"%d", *(p+2));
//    NSLog(@"%d", *(p+3));

//    char * ch = malloc(4098);
//    memset(ch, 4, 5);
//
//    __weak typeof(self) wself = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @autoreleasepool {
//            NSObject * inner = [NSArray array];
//            wself.outer = inner;
//            NSLog(@"%@", inner);
//            NSLog(@"%@", wself.outer);
//            inner= nil;
//        }
//    });
//    self.outer = [NSObject new];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
