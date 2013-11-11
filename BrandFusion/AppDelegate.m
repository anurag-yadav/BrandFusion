//
//  AppDelegate.m
//  CamFusion
//
//  Created by Gaurav Garg on 6/21/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//
#import "AppDelegate.h"
#import "BFNavigationController.h"
#import "BFMainTableViewController.h"
#import "VideoPlayerViewController.h"

#import "RageIAPHelper.h"
#import <Parse/Parse.h>

@implementation AppDelegate
@synthesize allowRotation,buttontap;

NSString *const kGooglePlusClientID =
@"792045912939-39o2jcaohnc6kf92od28snvelemonm70.apps.googleusercontent.com";

NSString *const kParseAppId = @"1DV5HiUqVM9pfkfUKr1Jvw94V8fllT2EzJeCYZCe";
NSString *const kParseClientKey = @"q2E48BYQS0VGXkuHIHKIuQJ5wWlQQ5cLIIUoH3nE";

NSString *const kVzaarPimoviSecret = @"pimovi";
NSString *const kVzaarPimoviAuthToken = @"uq1cStHmgvXJXOWgEfAa48RfOkuvhCn1xvBJMdTA";

+ (AppDelegate *) sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return NO;
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication]setStatusBarStyle:SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? UIStatusBarStyleDefault:UIStatusBarStyleBlackOpaque];
    
    //    18af73622852449caab133825b12a97c
    [RageIAPHelper sharedInstance];
    [Parse setApplicationId:kParseAppId
                  clientKey:kParseClientKey];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BFMainTableViewController *viewController = [[BFMainTableViewController alloc] initWithNibName:@"BFMainTableViewController" bundle:nil];
    BFNavigationController *navController = [[BFNavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navController;
    navController.navigationBarHidden = YES;
    [self.window makeKeyAndVisible];
    self.allowRotation = NO;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillExitFullscreenNotification:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillEnterFullscreenNotification:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidEnterFullscreenNotification:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    }
    
    return YES;
}

#pragma mark - MoviePlayer Notifications

- (void) moviePlayerDidEnterFullscreenNotification:(NSNotification*)notification
{
    
}

- (void) moviePlayerWillEnterFullscreenNotification:(NSNotification*)notification {
    self.allowRotation = YES;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];
}

- (void) moviePlayerWillExitFullscreenNotification:(NSNotification*)notification {
    self.allowRotation = NO;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];
}

#pragma mark - Rotation support

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (buttontap == NO) {
        return nil;
    }
    if (self.allowRotation) {
        return  UIInterfaceOrientationMaskLandscapeLeft;
    }
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - UIApp lifecycle

- (void) applicationWillResignActive:(UIApplication *)application
{
    
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void) applicationWillTerminate:(UIApplication *)application
{

}

@end
