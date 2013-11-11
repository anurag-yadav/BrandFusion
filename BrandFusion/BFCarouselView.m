//
//  BFCarouselView.m
//  BrandFusion
//
//  Created by Ronan on 11/11/2013.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "BFCarouselView.h"
#import "SMPageControl.h"
#import "MSWeakTimer.h"

@interface BFCarouselView()
{
    UIScrollView *_scrollView;
    SMPageControl *_pageControl;
    MSWeakTimer *_animationTimer;
}

@end

@implementation BFCarouselView

static const float margin = 6.0;
static const float sideMargin = 6.0;
static const float pageControlDefaultHeight = 20.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        [_scrollView setPagingEnabled:YES];
        [self addSubview:_scrollView];
        
        _pageControl = [[SMPageControl alloc] init];
        // calculate frame to be bottm aligned
        _pageControl.frame = (CGRect) {margin,
            self.frame.size.height - pageControlDefaultHeight - margin,
            self.frame.size.width - 2 * sideMargin, pageControlDefaultHeight};
        
        [self addSubview:_pageControl];
        
    }
    return self;
}

- (void) setDataSource:(id<CarouselDataSource,UIScrollViewDelegate>)dataSource
{
    PiLog(@"");
    
    if ([dataSource conformsToProtocol:@protocol(CarouselDataSource)]) {
        
        NSInteger numberOfImages = [dataSource numberOfImages];
        
        if (numberOfImages > 1) {
            
        }
    }
}

#pragma mark - ScrollView Delegate


//TODO: when decelerating ends, start timer.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PiLog(@"");
}

//TODO: If image is dragged pause the timer
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    PiLog(@"");
}

//TODO: When a user stops dragging the image, wait for for animation to end
- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    PiLog(@"");
}

@end