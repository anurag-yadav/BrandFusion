//
//  ViewController.m
//  CamFusion
//
//  Created by Gaurav Garg on 6/21/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.

#import "BFMainTableViewController.h"
#import "VideoCustomCell.h"
#import "VideoPlayerViewController.h"
#import "UIImage+StackBlur.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Vzaar.h"
#import "NSDate+TimeAgo.h"

@interface BFMainTableViewController ()
{
    IBOutlet UITableView *videoListTable;
    IBOutlet UIView *view_Section1;
    IBOutlet UIView *view_Section2;
    
    NSArray *_videoList;
    
    UIImage *_screenShotImage;
    UIImageView *blurImageView;
    
    Vzaar *_vzaarApi;
    
    UIView *_versionView;
}
@end

@implementation BFMainTableViewController

static const NSInteger iPhone5ScreenHeight = 568;
static const NSInteger iPhone4ScreenHeight = 480;

// There are 2 sections in the table,
// 1st for the title image, the second for the list of videos.
static const NSInteger numberOfSectionsInTableView = 2;
static const NSInteger statusBarHeight = 20;
static const NSInteger tollBarHeight = 44;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _vzaarApi = [[Vzaar alloc] initWithURL:[NSURL URLWithString:kLiveAPIEndPoint]];
    [_vzaarApi setOAuthSecret:kVzaarPimoviSecret];
    [_vzaarApi setOAuthToken:kVzaarPimoviAuthToken];
    
    NSError *error = nil;
    NSDictionary *userDetailsDict = [_vzaarApi userDetailsForUsername:[_vzaarApi oAuthSecret]
                                                                  error:&error];
    
    _videoList  = [_vzaarApi videosForUser:@"pimovi" withTitleFilter:@"" page:1 ofPagesOfLength:100 reverseSortOrder:NO error:&error];
    NSLog(@"the user details %@ and %@ and video list  and %d",userDetailsDict,_videoList ,[_videoList count]);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //TODO: remove this for production
    [self showVersion];
}

#pragma mark - UITableView DataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return numberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return [_videoList count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        videoListTable.frame = CGRectMake(0, statusBarHeight,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height - statusBarHeight);
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (section == 0)
        return view_Section1;
    
    return view_Section2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return view_Section1.frame.size.height;
    }
    
    return view_Section2.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Mycell";
    VideoCustomCell *cell = (VideoCustomCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.userNameLabel.text = [[_videoList objectAtIndex:indexPath.row] objectForKey:@"author_name"];
    cell.numViewsLabel.text = [NSString stringWithFormat:@"%@ %@",[[_videoList objectAtIndex:indexPath.row]objectForKey:@"play_count"],NSLocalizedString(@"views", @"Number of views")];
    
#if USE_RANDOM_PREMUIM_LABELS==1
    
    if ([self isPremium:indexPath]) {
        cell.videoLabelImageView.image = [UIImage imageNamed:@"premium"];
        //cell.lockImageView.image = [UIImage imageNamed:@"lock"];
        [cell.lockImageView setContentMode:UIViewContentModeTopLeft];
    } else {
        cell.videoLabelImageView.image = nil;
        //cell.videoLabelImageView.image = [UIImage imageNamed:@"Free"];
        //cell.lockImageView.image = [UIImage imageNamed:@"unlock"];
    }
#endif
    
    cell.sharedTimeLabel.text = [self localisedForDateString:[[_videoList objectAtIndex:indexPath.row]objectForKey:@"created_at"]];
    cell.videoTitleLabel.text = [[_videoList objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    NSURL *url = (NSURL*)[[_videoList objectAtIndex:indexPath.row] objectForKey:@"thumbnail"];
    [cell.videoStillPlaceholderImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"vdo_preview.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.videoStillPlaceholderImageView.layer setBorderWidth:1];
    [cell.videoStillPlaceholderImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cell.videoStillPlaceholderImageView setContentMode:UIViewContentModeScaleAspectFill];
    [cell.videoStillPlaceholderImageView.layer setMasksToBounds:YES];
    [cell.placeholderButton addTarget:self action:@selector(videoCellButtonAction:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (BOOL) isPremium:(NSIndexPath*)indexPath
{
    return indexPath.row == 1||indexPath.row == 3 || indexPath.row == 6 || indexPath.row == 9 || indexPath.row == 11 || indexPath.row == 13 || indexPath.row == 15;
}

#pragma mark - Convert Create Date to localised string

- (NSString*)localisedForDateString:(NSDate*)date
{
    
    return [date timeAgo];
    
    //TODO: refactor this to a static class and write unit tests
    
//    NSDate * currentDate = [NSDate date];
//    NSCalendar *currCalendar = [NSCalendar currentCalendar];
//    unsigned int unitFlags = NSDayCalendarUnit|NSYearCalendarUnit;
//    NSDateComponents *conversionInfo = [currCalendar components:unitFlags fromDate:date  toDate:currentDate  options:0];
//    int year  = [conversionInfo year];
//    int days = [conversionInfo day];
//    
//    //TODO: this needs to be localised
//    if (days > 0) {
//        return [NSString stringWithFormat:@"%d days ago", days];
//    }
//    else return @"Today";
//    
//    if (year > 0) {
//        return [NSString stringWithFormat:@"%d years ago", year];
//    }
}

#pragma  mark - Touch Control

- (void)videoCellButtonAction:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:videoListTable];
    NSIndexPath *indexPath = [videoListTable indexPathForRowAtPoint: currentTouchPosition];
    VideoPlayerViewController *videoPlayerObj;
    
    NSDictionary *videoDetails = [_videoList objectAtIndex:indexPath.row];
    
    //TODO: Should use auto-layout instead of 2 different nib files.
    if ([[UIScreen mainScreen] bounds].size.height == iPhone5ScreenHeight)
    {
        videoPlayerObj  = [[VideoPlayerViewController alloc] initWithNibName:@"VideoPlayerViewController-iPhone5" bundle:nil];
    }
    else
        videoPlayerObj  = [[VideoPlayerViewController alloc] initWithNibName:@"VideoPlayerViewController" bundle:nil];
    
    videoPlayerObj.videoDetailsDict = videoDetails;
    videoPlayerObj.wholeDetailsOfVideo = _videoList;
    videoPlayerObj.currentVideoid = indexPath.row;
    
    #if USE_RANDOM_PREMUIM_LABELS==1
    
    if ([self isPremium:indexPath])
    {
        //TODO: this needs to be localised
        UIAlertView * alert_View = [[UIAlertView alloc]initWithTitle:@"Beta Version" message:@"We are currently in beta and you have reached a premium section. The premium content will eventually be available for subscription for $5/year. Stay tuned for an update to this app soon!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert_View  show];
    }
    else
    {
        [self.navigationController pushViewController:videoPlayerObj animated:YES];
    }
    
#endif
    
}

#pragma mark - Add Version on Screen

- (void) showVersion
{
    _versionView = [[UIView alloc] initWithFrame:(CGRect) {20,50,280,60}];
    _versionView.backgroundColor = [UIColor blackColor];
    _versionView.layer.cornerRadius = 6;
    _versionView.alpha = 0.65;
    
    UILabel *versionNumberLabel = [[UILabel alloc] initWithFrame:(CGRect){0,20,280,20}];
    
    versionNumberLabel.text = [NSString stringWithFormat:@"Version %@ (%@)",
                               [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
    
    versionNumberLabel.textColor = [UIColor whiteColor];
    [versionNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [_versionView addSubview:versionNumberLabel];
    [self.view addSubview:_versionView];
    
    [self performSelector:@selector(hideVersion) withObject:nil afterDelay:6];
    
}

- (void) hideVersion
{
    [_versionView removeFromSuperview];
    _versionView = nil;
}

#pragma mark - Button Action

- (IBAction)behindTheBrandButtonAction
{
    BehindBrandViewController *behindBrand_Obj = [[BehindBrandViewController alloc]initWithNibName:@"BehindBrandViewController" bundle:nil];
    [self.navigationController pushViewController:behindBrand_Obj animated:YES];
}

#pragma mark - Rotation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait);
}

#pragma mark - Blur Effect

- (void) captureBlur
{
    CGRect grabRect = CGRectMake(0,47,320,413);
    UIGraphicsBeginImageContext(grabRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -grabRect.origin.x, -grabRect.origin.y);
    [self.view.layer renderInContext:ctx];
    _screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)doBlurr
{
    blurImageView.image = [_screenShotImage stackBlur:10];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    //[self setBlurContainerView:nil];
    //[self setTransparentView:nil];
    [super viewDidUnload];
}
@end
