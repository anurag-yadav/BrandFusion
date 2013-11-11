//
//  RNBlurView.m
//  CamFusion
//
//  Created by Gaurav Garg on 07/08/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "RNBlurView.h"
#import "UIImage+Blur.h"
#import <QuartzCore/QuartzCore.h>

@interface RNBlurView()
{
    UIView *_coverView;
    id <RenderDelegate> datasource;
}
@end

@implementation RNBlurView

- (id)initWithCoverView :(UIView *)view andDatasource: (id <RenderDelegate>)datasrc {
    if (self = [super initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)]) {
        NSLog(@"the %@",datasrc);
        datasource = datasrc;
        
        _coverView = view;
        UIImage *blur = [self renderView:_coverView];
        self.image = [blur boxblurImageWithBlur: 0.2f];
    }
    return self;
}

- (UIImage *) renderView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // TODO: this might be a problem for iPhone 5
    UIImageView *fullimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    fullimageView.image = image;
    [view addSubview:fullimageView];
    UIImage *thumbnail;
    
    if (datasource != nil) {
        thumbnail =  [datasource thumbnailImageAtCurrentTime];
    }
    
    UIImageView *thumbnailImageView  = [[UIImageView alloc] initWithFrame:CGRectMake(5,85, 310, 176)];
    thumbnailImageView.image = thumbnail;
    [view addSubview:thumbnailImageView];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *finalimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [thumbnailImageView removeFromSuperview];
    [fullimageView removeFromSuperview];
    NSData *imageData = UIImageJPEGRepresentation(finalimage, 1); // convert to jpeg
    image = [UIImage imageWithData:imageData];
    return image;
}

@end
