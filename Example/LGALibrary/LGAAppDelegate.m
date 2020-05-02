//
//  LGAAppDelegate.m
//  LGALibrary
//
//  Created by CocoaPods on 08/05/2014.
//  Copyright (c) 2014 Loic Gardiol. All rights reserved.
//

#import "LGAAppDelegate.h"

#import "NSNotificationCenter+LGAAdditions.h"

//static NSString* kNotif1Name = @"test1";
//static NSString* kNotif2Name = @"test2";

@implementation LGAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /*[[NSNotificationCenter defaultCenter] lga_addObserver:self name:kNotif1Name object:nil block:^(NSNotification *notif) {
        NSLog(@"notif test new 1");
    }];
    [[NSNotificationCenter defaultCenter] lga_addObserver:self name:kNotif2Name object:nil block:^(NSNotification *notif) {
        NSLog(@"notif test new 2");
    }];
    [[NSNotificationCenter defaultCenter] lga_addObserver:self name:kNotif1Name object:nil block:^(NSNotification *notif) {
        NSLog(@"notif test new 1 2");
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(print) name:kNotif1Name object:nil];
    id opaqueObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotif2Name object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"notif 2 bloxk");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif2Name object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:opaqueObserver];
    });
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(test) userInfo:nil repeats:YES];*/
    
    
    
    return YES;
}

/*- (void)print {
    NSLog(@"notif 1 selector");
}

- (void)test {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif1Name object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif2Name object:nil];
}*/
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
