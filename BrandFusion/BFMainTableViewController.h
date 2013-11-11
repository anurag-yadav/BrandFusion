//
//  ViewController.h
//  CamFusion
//
//  Created by Gaurav Garg on 6/21/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "AccountsViewController.h"
#import "BehindBrandViewController.h"

@interface BFMainTableViewController : UIViewController

@property (weak, nonatomic)  UIView *transparentView;
@property (weak, nonatomic)  UIView *blurContainerView;

- (IBAction)behindTheBrandButtonAction;

@end