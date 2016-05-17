//
//  AppDelegate.m
//  WoFun
//
//  Created by 林勇 on 16/3/12.
//  Copyright (c) 2016年 Leonly91. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TimeLineViewController.h"
#import "MessageViewController.h"
#import "ProfileViewController.h"
#import "AtMeViewController.h"
#import <UIKit/UIKit.h>
#import "ConfigFileUtil.h"
#import "NewTweetViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    TimeLineViewController *view1 = [[TimeLineViewController alloc] init];
    view1.tabBarItem.title = @"TimeLine";
    
    MessageViewController *view2 = [[MessageViewController alloc] init];
    view2.tabBarItem.title = @"Message";
    
    AtMeViewController *view3 = [[AtMeViewController alloc] init];
    view3.tabBarItem.title = @"@Me";
    
    ProfileViewController *view4 = [[ProfileViewController alloc] init];
    view4.tabBarItem.title = @"Profile";
    
    [tabBarController addChildViewController:view1];
    [tabBarController addChildViewController:view2];
    [tabBarController addChildViewController:view3];
    [tabBarController addChildViewController:view4];
    
    tabBarController.navigationItem.title = @"WoFun";
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    nvc.navigationBar.translucent = NO;
    //Add tool item to navigation
    
    
    self.window.rootViewController = nvc;
//    NewTweetViewController *newTweet = [[NewTweetViewController alloc] init];
//    self.window.rootViewController = newTweet;
    [self.window makeKeyAndVisible];
    
    [ConfigFileUtil readOAuthConfig];
    
//    self.window.backgroundColor = [UIColor whiteColor];
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
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [ConfigFileUtil readOAuthConfig];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [ConfigFileUtil writeOAuthConfig];
}

@end
