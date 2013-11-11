//
//  BFCarouselDataSource.h
//  BrandFusion
//
//  Created by Ronan on 11/11/2013.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CarouselDataSource

- (UIImage*)imageAtIndex:(NSInteger)index;
- (NSInteger)numberOfImages;

@end

@interface BFCarouselDataSource : NSObject <CarouselDataSource>

@property (nonatomic, strong) NSArray *images;

@end