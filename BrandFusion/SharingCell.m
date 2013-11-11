//
//  SharingCell.m
//  AlertTableView
//
//  Created by  on 8/6/13.
//
//

#import "SharingCell.h"

@implementation SharingCell
@synthesize Label_forSocialSite;
@synthesize ImageView_ShowLogo;

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
