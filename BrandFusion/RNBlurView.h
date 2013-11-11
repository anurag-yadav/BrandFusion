//
//  RNBlurView.h
//  CamFusion
//
//  Created by Gaurav Garg on 07/08/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RenderDelegate <NSObject>

- (UIImage *)thumbnailImageAtCurrentTime;

@end

@interface RNBlurView : UIImageView

//@property (nonatomic,weak) id <RenderDelegate> datasource;

- (id)initWithCoverView :(UIView *)view andDatasource:(id <RenderDelegate>)datasource;
- (UIImage *)renderView:(UIView *)view;

@end
