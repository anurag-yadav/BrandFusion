//
//  BehindBrandViewController.m
//  BrandFusion
//
//  Created by Anurag Yadav on 10/26/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "BehindBrandViewController.h"

@interface BehindBrandViewController ()
{
    UIImageView *_behindBrandImageView;
}
@end

@implementation BehindBrandViewController

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
    CGFloat screenWidth = self.view.frame.size.width;
    self.scrollView_BehindBrand.delegate = self;
    self.scrollView_BehindBrand.scrollEnabled = YES;
    self.scrollView_BehindBrand.contentSize = CGSizeMake(screenWidth,700);
    UIImage *image = [UIImage imageNamed:@"full_image_behind_brand"];
    _behindBrandImageView = [[UIImageView alloc] initWithImage:image];
    _behindBrandImageView.frame = CGRectMake(0,0, screenWidth, 686);
    [self.scrollView_BehindBrand addSubview:_behindBrandImageView];
}

- (IBAction)backToVideoListController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end