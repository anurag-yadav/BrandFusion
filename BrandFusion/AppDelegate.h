//
//  AppDelegate.h
//  CamFusion
//
//  Created by Gaurav Garg on 6/21/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.



@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL shouldRotate;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL allowRotation;
@property (nonatomic,assign) BOOL buttontap;

+ (AppDelegate *) sharedDelegate;

@end