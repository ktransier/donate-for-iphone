//
//  AppDelegate.m
//  Together
//
//  Created by Kenneth Transier on 11/9/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "AppDelegate.h"
#import "Stripe.h"
#import <Parse/Parse.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
        [Parse setApplicationId:@"DKvsMri4bujpNN8P3HTTH2gpsBTWZi8lGDBYydLz"
                      clientKey:@"u2pT69wFBSixoIjdPpS8EIxdnvnk0MT84f8kvPUE"];
        
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
        NSString * const StripePublishableKey = @"pk_test_e8fFkfDSGhVPrWFrrl8HMrHX";
        
        [Stripe setDefaultPublishableKey:StripePublishableKey];
        return YES;

    }

    - (void)applicationWillResignActive:(UIApplication *)application {
    }

    - (void)applicationDidEnterBackground:(UIApplication *)application {
    }

    - (void)applicationWillEnterForeground:(UIApplication *)application {
    }

    - (void)applicationDidBecomeActive:(UIApplication *)application {
    }

    - (void)applicationWillTerminate:(UIApplication *)application {
    }

@end
