//
//  testnavcontrViewController.m
//  MapSimpleHarversine
//
//  Created by TonyM on 21.04.2013.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "BFNavigationController.h"
#import "VideoPlayerViewController.h"


@interface BFNavigationController ()

@end

@implementation BFNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    //Return Top view orientation
    PiLog(@"supportedInterfaceOrientations = %d ", [self.topViewController supportedInterfaceOrientations]);

    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // You do not need this method if you are not supporting earlier iOS Versions
    
    return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
@end
