//
//  BFCarouselDataSource.m
//  BrandFusion
//
//  Created by Ronan on 11/11/2013.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "BFCarouselDataSource.h"

@implementation BFCarouselDataSource

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithData: (NSArray*) images;
{
    self = [super init];
    if (self) {
        self.images = [NSArray arrayWithArray:images];
    }
    return self;
}

- (UIImage*) imageAtIndex:(NSInteger)index
{
    return [self.images objectAtIndex:index];
}

- (NSInteger)numberOfImages
{
    return [self.images count];
}

@end