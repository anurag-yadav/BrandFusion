//
//  Mycell.h
//  CamFusion
//
//  Created by Gaurav Garg on 6/14/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoLabelImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoStillPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numViewsLabel;
@property (weak, nonatomic) IBOutlet UIButton *placeholderButton;

- (IBAction)placeholderButtonAction:(id)sender;
- (IBAction)userButtonAction:(id)sender;

@end
