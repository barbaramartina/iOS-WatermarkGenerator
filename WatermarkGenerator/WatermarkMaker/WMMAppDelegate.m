//
//  WMMAppDelegate.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 2/6/14.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

#import "WMMAppDelegate.h"

#import <TestFlightSDK/TestFlight.h>

#import "WMMSideMenuViewController.h"
#import "CLSideMenuViewController.h"
#import "WMMMenuManager.h"
#import "WMMNavigationController.h"
#import <PixateFreestyle/PixateFreestyle.h>


/**********************************************************************/


#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


/**********************************************************************/

@implementation WMMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:TESTFLIGHT_KEY];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self loadInitialViewController];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    

    return YES;
}

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

#pragma mark Private

- (void)loadInitialViewController
{
    UIStoryboard *sb = nil;
    if (IS_IPAD) {
        sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_IPAD bundle:nil];
    } else {
        sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_IPHONE bundle:nil];
    }

    WMMNavigationController *navCon = [sb instantiateViewControllerWithIdentifier:VIEW_CONTROLLER_ID_NAVIGATION];
    
    [[WMMMenuManager sharedInstance] setDelegate:navCon];
    
    WMMSideMenuViewController *menuViewController = [sb instantiateViewControllerWithIdentifier:VIEW_CONTROLLER_ID_SIDEMENU];
    [menuViewController setMainViewController:navCon];
    
    CLSideMenuViewController *sideMenuViewController = [[CLSideMenuViewController alloc] initWithMenuViewController:menuViewController mainViewController:navCon];
    
    self.window.rootViewController = sideMenuViewController;
}

@end
