//
//  Mycell.m
//  CamFusion
//
//  Created by Gaurav Garg on 6/14/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "VideoCustomCell.h"

@implementation VideoCustomCell

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

- (IBAction)placeholderButtonAction:(id)sender {
}

- (IBAction)userButtonAction:(id)sender {
}
@end