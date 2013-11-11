//
//  BFCarouselView.h
//  BrandFusion
//
//  Created by Ronan on 11/11/2013.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFCarouselDataSource.h"

@interface BFCarouselView : UIView <UIScrollViewDelegate>

/**
 *  The datasource
 */
@property (nonatomic,weak) id<CarouselDataSource> dataSource;

/**
 *  Page control image
 */
@property (nonatomic,strong) UIImage *pageControlImage;

/**
 *  The image for the select page
 */
@property (nonatomic,strong) UIImage *pageControlSelectedImage;

/**
 * The pause between animations
 */
@property (nonatomic, assign) NSInteger pauseTime;



@end