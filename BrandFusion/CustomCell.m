//
//  CustomCell.m
//  CamFusion
//
//  Created by Anurag Yadav on 7/3/13.
//  Copyright (c) 2013 Gaurav Garg. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell
@synthesize channelNameLabel =_channelNameLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
