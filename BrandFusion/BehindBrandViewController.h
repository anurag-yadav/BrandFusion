//
//  BehindBrandViewController.h
//  BrandFusion
//
//  Created by Anurag Yadav on 10/26/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BehindBrandViewController : UIViewController <UIScrollViewDelegate,UIScrollViewAccessibilityDelegate>

@property (nonatomic,retain)  IBOutlet  UIScrollView   *scrollView_BehindBrand;
//@property (assign) CGPoint rememberContentOffset;

-(IBAction)backToVideoListController;

@end