//
//  SharingCell.h
//  AlertTableView
//
//  Created by  on 8/6/13.
//
//

#import <UIKit/UIKit.h>

@interface SharingCell : UITableViewCell
{

    IBOutlet UILabel       * Label_forSocialSite;
    IBOutlet UIImageView   * ImageView_ShowLogo;



}
@property(nonatomic
          ,strong)    IBOutlet UILabel       * Label_forSocialSite;
@property(nonatomic
          ,strong)    IBOutlet UIImageView   * ImageView_ShowLogo;

@end
