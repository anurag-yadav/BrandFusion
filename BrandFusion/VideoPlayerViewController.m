//
//  VideoPlayerViewController.m
//  CamfusionDemo
//
//  Created by Anurag Yadav on 6/12/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import "DejalActivityView.h"
#import <Twitter/Twitter.h>
#import "SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "ASIHTTPRequest.h"
#import <AudioToolbox/AudioToolbox.h>
#import <StoreKit/StoreKit.h>

#import "IAPHelper.h"
#import "RageIAPHelper.h"
#import <Parse/Parse.h>

@interface VideoPlayerViewController ()
{
    NSArray *_products;
    NSArray *_premiumVideoDetails;
    
    UISlider *_volumeSliderfull;
    UISlider *_volumeSlider;
    MPMoviePlayerViewController *_moviePlayerController;
}

@end

@implementation VideoPlayerViewController

static const NSInteger iPhone5ScreenHeight = 568;
static const NSInteger iPhone4ScreenHeight = 480;

@synthesize descripStr;
@synthesize playbackFinish,totalVideoTime,playPauseButton,fullScreenButton,currentTimeLabel,endTimeLable,customContorlView,playerSlider,soundSlider,customControlFullView,playPauseFullScreenButton,wholeDetailsOfVideo;
@synthesize myTimer = _myTimer,videoDetailsDict,queue,currentVideoid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        blockRotation = FALSE;
        wholeDetailsOfVideo = [[NSArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated;
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        PiLog(@" not finish");
        [self.moviePlayerController.moviePlayer stop];
        [self.moviePlayerController.moviePlayer.view removeFromSuperview];
        self.moviePlayerController = nil;
    }
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [_myTimer invalidate];
}

- (IBAction) onPlayerSliderChange: (UISlider*)sender
{
    if ([AppDelegate sharedDelegate].allowRotation == NO)
    {
        self.moviePlayerController.moviePlayer.currentPlaybackTime = self.totalVideoTime*self.playerSlider.value-1;
    }
    else
        self.moviePlayerController.moviePlayer.currentPlaybackTime = self.totalVideoTime*playerFullScreenSlider.value-1;
    
    [self updateTime];
}

- (void)handleDurationAvailableNotification
{
    mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    MPVolumeView *myVolumeView =
    [[MPVolumeView alloc] initWithFrame: mpVolumeViewParentView.bounds];
    [mpVolumeViewParentView addSubview: myVolumeView];
    for (UIView *view in [myVolumeView subviews]){
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
            _volumeSlider = (UISlider *) view;
        }
	}
    PiLog(@"the frame is %@",NSStringFromCGRect(_volumeSlider.frame));
    myVolumeView.transform=CGAffineTransformRotate(myVolumeView.transform,270.0/180*M_PI);
    mpVolumeParentFull.backgroundColor = [UIColor clearColor];
    MPVolumeView *myVolumeViewfull =
    [[MPVolumeView alloc] initWithFrame: mpVolumeParentFull.bounds];
    [mpVolumeParentFull addSubview: myVolumeViewfull];
    for (UIView *view in [myVolumeViewfull subviews]){
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
			_volumeSliderfull = (UISlider *) view;
		}
	}
    myVolumeViewfull.transform=CGAffineTransformRotate(myVolumeViewfull.transform,270.0/180*M_PI);
    self.totalVideoTime = self.moviePlayerController.moviePlayer.duration;
    self.playerSlider.backgroundColor = [UIColor clearColor];
    playerFullScreenSlider.backgroundColor = [UIColor clearColor];
    [self.playerSlider setThumbImage: [UIImage imageNamed:@"player_slider_thumb"] forState:UIControlStateNormal];
    [_volumeSlider sizeToFit];
    [_volumeSliderfull sizeToFit];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [_volumeSlider setThumbImage: [UIImage imageNamed:@"sound_slider3"] forState:UIControlStateNormal];
    }
    else
    {
        [_volumeSlider setThumbImage: [UIImage imageNamed:@"sound_slider1"] forState:UIControlStateNormal];
    }
    [_volumeSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_white_area"] forState:UIControlStateNormal];
    [_volumeSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_grey_area"] forState:UIControlStateNormal];
    [_volumeSliderfull setThumbImage: [UIImage imageNamed:@"sound_slider1"] forState:UIControlStateNormal];
    [_volumeSliderfull setMinimumTrackImage:[UIImage imageNamed:@"slider_white_area"] forState:UIControlStateNormal];
    [_volumeSliderfull setMaximumTrackImage:[UIImage imageNamed:@"slider_grey_area"] forState:UIControlStateNormal];
    [self.playerSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_white_area"] forState:UIControlStateNormal];
    [self.playerSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_grey_area"] forState:UIControlStateNormal];
    [playerFullScreenSlider setThumbImage: [UIImage imageNamed:@"player_slider_thumb"] forState:UIControlStateNormal];
    [playerFullScreenSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_white_area"] forState:UIControlStateNormal];
    [playerFullScreenSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_grey_area"] forState:UIControlStateNormal];
    [self.moviePlayerController.moviePlayer play];
    self.customContorlView.backgroundColor = [UIColor clearColor];
    [self.moviePlayerController.moviePlayer.view addSubview:self.customContorlView];
    
    //******** Get Device Voloume **********//
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    float deviceVoloumeLevel = musicPlayer.volume;
    [musicPlayer setVolume:deviceVoloumeLevel];
    PiLog(@"add %f",deviceVoloumeLevel);
    self.soundSlider.value = deviceVoloumeLevel ;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRollTap:)];
    singleFingerTap.delegate = self;
    singleFingerTap.numberOfTapsRequired = 1;
    [self.moviePlayerController.moviePlayer.view addGestureRecognizer:singleFingerTap];
    
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_myTimer forMode:NSDefaultRunLoopMode];
}

- (void) volumeChanged:(float*)notify
{
    //NSLog(@"volume changed");
    
    // NOTE:::  Do NOT use this call.  It is no longer necessary and Apple will reject
    //                your app if you use it!
    
}

- (void) handleRollTapforFullView:(UITapGestureRecognizer*)sender
{
    if ((customControlFullView.alpha > 0.0f) |(customControlFullView.alpha >1.0f))
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.90];
        customControlFullView.alpha = 0.0f;
        customControlFullView.alpha = 0.0f;
        [UIView commitAnimations];
    }
    else
        customControlFullView.alpha = 1.0f;
    customControlFullView.alpha = 1.0f;
    
    if (customControlFullView.hidden == NO) {
        customControlFullView.hidden = YES;
    }
    else
        customControlFullView.hidden = NO;
}

- (void)handleRollTap:(UITapGestureRecognizer*)sender
{
    if ((customContorlView.alpha > 0.0f) |(customControlFullView.alpha >1.0f)) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.90];
        customContorlView    .alpha = 0.0f;
        customControlFullView.alpha = 1.0f;
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.90];
        customContorlView    .alpha = 1.0f;
        customControlFullView.alpha = 0.0f;
        [UIView commitAnimations];
    }
}

- (void)controlsDisappear
{
    if ((customContorlView.alpha > 0.0f) |(customControlFullView.alpha >1.0f)) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.90];
        customContorlView    .alpha = 0.0f;
        customControlFullView.alpha = 1.0f;
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.90];
        customContorlView    .alpha = 1.0f;
        customControlFullView.alpha = 0.0f;
        [UIView commitAnimations];
    }
}

- (IBAction)fullScreenButtonAction:(id)sender
{
    
    
    BOOL chekFullScreen = self.moviePlayerController.moviePlayer.fullscreen;
    if (chekFullScreen == NO)
    {
        [self.moviePlayerController.moviePlayer setFullscreen:YES animated:YES];
        [AppDelegate sharedDelegate].buttontap = YES;
    }
    else
    {
        
        [self.moviePlayerController.moviePlayer setFullscreen:NO animated:YES];
        [AppDelegate sharedDelegate].buttontap = NO;
    }
}

//- (void)fullScreenButtonAction
//{
//    BOOL chekFullScreen = self.moviePlayerController.fullscreen;
//    if (chekFullScreen == NO)
//    {
//        [self.moviePlayerController setFullscreen:YES animated:YES];
//    }
//    else
//    {
//        [self.moviePlayerController setFullscreen:NO animated:YES];
//    }
//
//}

- (void)updateTime
{
    [animation_ImageView stopAnimating];
    blockRotation = TRUE;
    //  [moviePlayView removeFromSuperview];
    int timeleft = ((int)self.moviePlayerController.moviePlayer.duration - (int)self.moviePlayerController.moviePlayer.currentPlaybackTime);
    self.endTimeLable.text = [NSString stringWithFormat:@"-%d:%02d", timeleft / 60,timeleft % 60];
    endTimeFullLabel.text = [NSString stringWithFormat:@"-%d:%02d", timeleft / 60,timeleft % 60];
    
    self.playerSlider.value = self.moviePlayerController.moviePlayer.currentPlaybackTime / self.totalVideoTime;
    playerFullScreenSlider.value = self.moviePlayerController.moviePlayer.currentPlaybackTime / self.totalVideoTime;
    
    if (self.totalVideoTime != 0 && self.moviePlayerController.moviePlayer.currentPlaybackTime >= totalVideoTime - 0.1)
    {
        [_myTimer invalidate];
        [self.moviePlayerController.moviePlayer.view removeFromSuperview];
        
    }
    //    if (self.totalVideoTime == 0.01) {
    //        [self.moviePlayerController.moviePlayer.view removeFromSuperview];
    //        [self.view addSubview:moviePlayView];
    //    }
    
    //    BOOL controlsVisible = NO;
    //
    //    NSMutableArray *myarr = [[NSMutableArray alloc] init];
    //    [myarr addObject:[[[self.moviePlayerController view] subviews] objectAtIndex:0]];
    //
    //    for(id views in myarr){
    //        for(id subViews in [views subviews]){
    //            for (id controlView in [subViews subviews]){
    //                controlsVisible = ([controlView alpha] <= 0.0) ? (NO) : (YES);
    //                UIView *myView =  (UIView *) controlView;
    //            }
    //        }
    //    }
    
}

- (IBAction)playPauseButtonAction:(id)sender;
{
    if(self.moviePlayerController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self.moviePlayerController.moviePlayer pause];
        [self.playPauseButton setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
        [playPauseFullScreenButton setImage:[UIImage imageNamed:@"pause_btn.png"] forState:UIControlStateNormal];
        
    }
    else
    {
        [self.moviePlayerController.moviePlayer play];
        [self.playPauseButton setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
        [playPauseFullScreenButton setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
    }
}
- (void)finishedSharing:(BOOL)shared;
{
    NSLog(@"dsfd");
}

- (void)viewDidLoad
{
    
    // in app work
    
    [super viewDidLoad];
    
    _premiumVideoDetails = @[@1,@3,@6,@9,@11,@13,@15];
    
    label_Title.text = [videoDetailsDict objectForKey:@"title"];
    label_Name.text = [videoDetailsDict objectForKey:@"author_name"];
    if ([videoDetailsDict objectForKey:@"description"]) {
        textView_Description.text = [videoDetailsDict objectForKey:@"description"];
        PiLog(@"description , %@",[videoDetailsDict objectForKey:@"description"]);
    } else {
        PiLog(@"description , %@",[videoDetailsDict objectForKey:@"description"]);
        textView_Description.text = @"No Description Available";
        textView_Description.font = [UIFont fontWithName:@"System" size:26];
    }
    
    SKProduct * product = (SKProduct *) _products;
    lbl.text = product.localizedTitle;
    PiLog(@"my text,%@",lbl.text);
    
    
    CFURLRef myurl = (__bridge CFURLRef)([videoDetailsDict objectForKey:@"thumbnail"]);
    NSURL *thumbnailurl = (__bridge NSURL *)myurl;
    [thumbnailPreviewImage setImageWithURL:thumbnailurl placeholderImage:[UIImage imageNamed:@"vdo_preview.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addsubViewonFullScreen)
                                                 name:@"TestNotification"
                                               object:nil];
    [self addGestures];
}


#pragma mark - Swipe Methods

- (void)addGestures
{
    UISwipeGestureRecognizer * swipe_NextVideoToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNextVideoToLeftMethod)];
    swipe_NextVideoToLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [moviePlayView addGestureRecognizer:swipe_NextVideoToLeft];
    
    UISwipeGestureRecognizer *swipe_PreviousVideoToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePreviousVideoToRightMethod)];
    swipe_PreviousVideoToRight.direction = UISwipeGestureRecognizerDirectionRight;
    [moviePlayView addGestureRecognizer:swipe_PreviousVideoToRight];
}

- (void)swipeNextVideoToLeftMethod
{
    if (currentVideoid == [wholeDetailsOfVideo count] -1) {
        UIAlertView * alert  = [[UIAlertView alloc]initWithTitle:@"Video End" message:@"Please swipe right to the previous video in the list " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    }
    currentVideoid = currentVideoid +1;
    NSNumber *num = [NSNumber numberWithInt:currentVideoid];
    if ([_premiumVideoDetails containsObject:num]) {
        currentVideoid = currentVideoid +1;
    }
    CFURLRef myurl = (__bridge CFURLRef)([[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"thumbnail"]);
    NSURL *url = (__bridge NSURL *)myurl;
    videoDetailsDict = [wholeDetailsOfVideo objectAtIndex:currentVideoid ];
    PiLog(@"thumb ,%@",myurl);
    [thumbnailPreviewImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"vdo_preview"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    label_Title.text = [[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"title"];
    label_Name.text = [[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"author_name"];
}

- (void)swipePreviousVideoToRightMethod
{
    if (currentVideoid == 0)
    {
        UIAlertView * alert  = [[UIAlertView alloc]initWithTitle:@"Video End" message:@"Please swipe left to the next video in the list " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    currentVideoid = currentVideoid -1;
    NSNumber *num = [NSNumber numberWithInt:currentVideoid];
    if ([_premiumVideoDetails containsObject:num]) {
        currentVideoid = currentVideoid -1;
    }
    
    //CFURLRef myurl = (__bridge CFURLRef)([[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"thumbnail"]);
    //NSURL *url = (__bridge NSURL *)myurl;
    
    NSURL *url = (NSURL*)([[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"thumbnail"]);;
    
    videoDetailsDict = [wholeDetailsOfVideo objectAtIndex:currentVideoid];
    
    PiLog(@"thumb ,%@",[url absoluteString]);
    [thumbnailPreviewImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"vdo_preview"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    label_Title.text = [[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"title"];
    label_Name.text = [[wholeDetailsOfVideo objectAtIndex:currentVideoid] objectForKey:@"author_name"];
}

- (void)viewWillLayoutSubviews
{
    if ([UIScreen mainScreen].bounds.size.height == iPhone5ScreenHeight) {
        animation_ImageView.frame = CGRectMake(135, 90, 40, 40); // for iPhone 5
    } else {
        animation_ImageView.frame = CGRectMake(135, 60, 40, 40);
    }
}

- (IBAction)moviePlayButtonAction:(id)sender;
{
    moviePlayView.backgroundColor  = [UIColor blackColor];
    
    NSMutableArray *imagesFrames = nil;
    
    for (int i=0; i<20; i++) {
        [imagesFrames addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%d",i]]];
    }
    
    animation_ImageView = [[UIImageView alloc] init];
    animation_ImageView.animationImages = imagesFrames;
    animation_ImageView.animationDuration = 0.6;
    [moviePlayView addSubview:animation_ImageView];
    [animation_ImageView startAnimating];
    [self viewWillLayoutSubviews];
    
    [self startPlayBack];
}

- (void)exitFullscreen:(NSNotification*)notification
{
    [AppDelegate sharedDelegate].allowRotation = NO;
    self.customControlFullView.transform = CGAffineTransformIdentity;
    [self.customControlFullView removeFromSuperview];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    PiLog(@"the arr is %@",[[UIApplication sharedApplication].keyWindow subviews]);
    UIView *myView = [[[UIApplication sharedApplication].keyWindow subviews] objectAtIndex:0];
    
    [myView setFrame:CGRectMake(0, 0,320, [ [ UIScreen mainScreen ] bounds ].size.height )];
    myView.transform = CGAffineTransformIdentity;
    [myView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, [ [ UIScreen mainScreen ] bounds ].size.height)];
}

- (void) addsubViewonFullScreen
{
    UITapGestureRecognizer *Tap;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    if ([AppDelegate sharedDelegate].allowRotation == YES) {
        PiLog(@"app delegate notification i.e iOS6");
        self.customControlFullView.backgroundColor = [UIColor clearColor];
        if (window.gestureRecognizers == nil || [window.gestureRecognizers count] == 0) {
            Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRollTapforFullView:)];
            Tap.delegate = self;
            
            Tap.numberOfTapsRequired = 1;
            [window addGestureRecognizer:Tap];
        }
        
        CGRect rect =customControlFullView.frame;
        if ([[UIScreen mainScreen] bounds].size.height == iPhone5ScreenHeight) {
            Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRollTapforFullView:)];
            Tap.delegate = self;
            
            Tap.numberOfTapsRequired = 1;
            [window addGestureRecognizer:Tap];

            customControlFullView.frame = rect;
            customControlFullView.frame = CGRectMake(0, 0, iPhone5ScreenHeight, 320);
            CGAffineTransform landscapeTransform1;
            landscapeTransform1 = CGAffineTransformMakeRotation(M_PI+M_PI/2);
            landscapeTransform1 = CGAffineTransformTranslate(landscapeTransform1,-120, -130);
            [customControlFullView setTransform:landscapeTransform1];
            
        } else {
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRollTap:)];
            singleFingerTap.delegate = self;
            singleFingerTap.numberOfTapsRequired = 1;
            [window addGestureRecognizer:singleFingerTap];

            customControlFullView.frame = rect;
            customControlFullView.frame = CGRectMake(0, 0, iPhone4ScreenHeight, 320);
            CGAffineTransform landscapeTransform1;
            landscapeTransform1 = CGAffineTransformMakeRotation(M_PI+M_PI/2);
            landscapeTransform1 = CGAffineTransformTranslate(landscapeTransform1,-80, -80);
            [customControlFullView setTransform:landscapeTransform1];
        }
        
        
        PiLog(@"the frame is %@",NSStringFromCGRect(customControlFullView.frame));
        [window addSubview:customControlFullView];
        PiLog(@"the gesture regognizer of windows are as: %@",window.gestureRecognizers);
        
    } else {
        [self.customControlFullView removeFromSuperview];
        self.customControlFullView.transform = CGAffineTransformIdentity;
    }
}

- (void)enterFullscreen:(NSNotification*)notification
{
    [AppDelegate sharedDelegate].allowRotation = YES;
    customControlFullView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
    
    UIView *myView = [[[UIApplication sharedApplication].keyWindow subviews] objectAtIndex:0];
    [myView setFrame:CGRectMake(0, 0, [ [ UIScreen mainScreen ] bounds ].size.height, 320)];
    myView.transform = CGAffineTransformMakeRotation(M_PI+(M_PI/2));
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    if (window.gestureRecognizers == nil || [window.gestureRecognizers count] == 0) {
        UITapGestureRecognizer    *Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRollTapforFullView:)];
        Tap.delegate = self;
        
        Tap.numberOfTapsRequired = 1;
        [window addGestureRecognizer:Tap];
    }
    customControlFullView.frame = CGRectMake(0, 0, iPhone4ScreenHeight, 320);
    CGAffineTransform landscapeTransform1;
    landscapeTransform1 = CGAffineTransformMakeRotation(M_PI+M_PI/2);
    landscapeTransform1 = CGAffineTransformTranslate(landscapeTransform1,-80, -80);
    [customControlFullView setTransform:landscapeTransform1];
    [window addSubview:customControlFullView];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    blockRotation = FALSE;
    MPMoviePlayerViewController *player = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
}
- (void)playbackFinished:(NSNotification*)notification {
    
    NSNumber * reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackFinished. Reason: Playback Ended");
            break;
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"playbackFinished. Reason: Playback Error");
            break;
        case MPMovieFinishReasonUserExited:
            NSLog(@"playbackFinished. Reason: User Exited");
            break;
        default:
            break;
    }
    playbackFinish = YES;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        blockRotation = NO;
        [self performSelector:@selector(setFrameAfterVideoFinish) withObject:Nil afterDelay:0.0];
    } else {
        [self.view addSubview:moviePlayView];
    }
}

- (void)setFrameAfterVideoFinish
{
    [ AppDelegate sharedDelegate].allowRotation = NO;
    //     self.customControlFullView.transform = CGAffineTransformIdentity;
    [self.customControlFullView removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    // NSLog(@"the arr is %@",[[UIApplication sharedApplication].keyWindow subviews]);
    UIView *myView = [[[UIApplication sharedApplication].keyWindow subviews] objectAtIndex:0];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    [myView setFrame:CGRectMake(0, 0,screenSize.width,screenSize.height )];
    myView.transform = CGAffineTransformIdentity;
    [myView setFrame:CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height)];
    [self.moviePlayerController.moviePlayer.view removeFromSuperview];
    [self.view addSubview:moviePlayView];
  
}

//TODO: Refactor this method. There is a lot of duplication
// its is used for diffrent buttons and each button have tag. that's why duplication occur
- (IBAction) muteandUnmute:(id)sender
{
    UISlider *volumeSlider = nil;
    UISlider *volumeSlider1 = nil;
    UIView *myVolumeView = nil;
    UIView *myVolumeView1 = nil;
    
    if ([AppDelegate sharedDelegate].allowRotation == YES) {
        
        if (muteButtonFullscreen.tag == 0) {
            
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0];
            muteButtonFullscreen.tag = 1;
            muteButton.tag = 1;
            
            myVolumeView = [[mpVolumeParentFull subviews] objectAtIndex:0];
            
            for (UIView *view in [myVolumeView subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider = (UISlider *) view;
                }
            }
            voulumeValue = volumeSlider.value;
            [volumeSlider setValue:0 animated:YES];
            
            myVolumeView1 = [[mpVolumeViewParentView subviews] objectAtIndex:0];
            for (UIView *view in [myVolumeView1 subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider1 = (UISlider *) view;
                }
            }
            [volumeSlider1 setValue:0 animated:YES];
        } else if (muteButtonFullscreen.tag == 1) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:voulumeValue];
            muteButtonFullscreen.tag = 0;
            muteButton.tag = 0;
            myVolumeView = [[mpVolumeParentFull subviews] objectAtIndex:0];
            for (UIView *view in [myVolumeView subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider = (UISlider *) view;
                }
            }
            [volumeSlider setValue:voulumeValue animated:YES];

            myVolumeView1 = [[mpVolumeViewParentView subviews] objectAtIndex:0];
            
            for (UIView *view in [myVolumeView1 subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider1 = (UISlider *) view;
                }
            }
            [volumeSlider1 setValue:voulumeValue animated:YES];
        }
    } else {
        if (muteButton.tag == 0) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0];
            muteButtonFullscreen.tag = 1;
            muteButton.tag = 1;
            myVolumeView = [[mpVolumeParentFull subviews] objectAtIndex:0];
            
            for (UIView *view in [myVolumeView subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider = (UISlider *) view;
                }
            }
            voulumeValue = volumeSlider.value;
            
            [volumeSlider setValue:0 animated:YES];

            myVolumeView1 = [[mpVolumeViewParentView subviews] objectAtIndex:0];
            
            for (UIView *view in [myVolumeView1 subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider1 = (UISlider *) view;
                }
            }
            [volumeSlider1 setValue:0 animated:YES];
        } else if (muteButton.tag == 1) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:voulumeValue];
            muteButtonFullscreen.tag = 0;
            muteButton.tag = 0;
            
            myVolumeView = [[mpVolumeParentFull subviews] objectAtIndex:0];
            
            for (UIView *view in [myVolumeView subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider = (UISlider *) view;
                }
            }
            [volumeSlider setValue:voulumeValue animated:YES];
            
            myVolumeView1 = [[mpVolumeViewParentView subviews] objectAtIndex:0];
            
            for (UIView *view in [myVolumeView1 subviews]){
                if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
                    volumeSlider1 = (UISlider *) view;
                }
            }
            [volumeSlider1 setValue:voulumeValue animated:YES];
        }
    }
}

- (void)startPlayBack
{
    playbackFinish = NO;
    [moviePlayView removeFromSuperview];
    CFURLRef myurl = (__bridge CFURLRef)([videoDetailsDict objectForKey:@"url"]);
    NSURL *url = (__bridge NSURL *)myurl;
    
    self.moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.moviePlayerController.moviePlayer];
    [self.moviePlayerController.moviePlayer prepareToPlay];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if ([[UIScreen mainScreen] bounds].size.height == iPhone5ScreenHeight){
            self.moviePlayerController.moviePlayer.view.frame = CGRectMake(5.0f, 98.0f, 310.0f, 220.0f);
        } else
            self.moviePlayerController.moviePlayer.view.frame = CGRectMake(5.0f, 92.0f, 310.0f, 176.0f);
    } else {
        if ([[UIScreen mainScreen] bounds].size.height == iPhone5ScreenHeight) {
            self.moviePlayerController.moviePlayer.view.frame = CGRectMake(5.0f, 78.0f, 310.0f, 220.0f);
        }
        else
            self.moviePlayerController.moviePlayer.view.frame = CGRectMake(5.0f, 70.0f, 310.0f, 176.0f);
    }
    
    [self.view addSubview:self.moviePlayerController.moviePlayer.view];
    self.moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    //self.moviePlayerController.moviePlayer.
    float currentVersion = 6.0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < currentVersion) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleDurationAvailableNotification)
               name:MPMovieDurationAvailableNotification
             object:self.moviePlayerController.moviePlayer];
    [self performSelector:@selector(controlsDisappear) withObject:Nil afterDelay:4.0];
}

- (void)moviePlayerLoadStateChanged:(NSNotification *)notification
{
    PiLog(@"State changed to: %d\n", self.moviePlayerController.moviePlayer.loadState);
    if((self.moviePlayerController.moviePlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable)
    {
        //if load state is ready to play
        [self.moviePlayerController.moviePlayer play];//play the video
    }
}

#pragma mark - DownLoadVideo methods

- (IBAction)downloadVideosTest:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *videoTitle = [[videoDetailsDict objectForKey:@"title"] stringByDeletingPathExtension];
    NSString *videoTitleExt = [NSString stringWithFormat:@"%@.mp4",videoTitle];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:videoTitleExt];
    
    NSError *error = nil;
    NSURL *videoDownlaod = [NSURL URLWithString:[NSString stringWithFormat:@"http://view.vzaar.com/%@/download",[videoDetailsDict objectForKey:@"id"]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:videoDownlaod];
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@",dataPath]];
    PiLog(@"the path is %@",dataPath);
    [request setDelegate:self];
    [request setAllowResumeForFileDownloads:YES];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error %@",error);
    
}

#pragma mark - gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view ==playPauseFullScreenButton  || touch.view == fullScreenButton || touch.view ==playPauseButton ||touch.view == exitFullScreenButton || touch.view == muteButton || touch.view == muteButtonFullscreen || touch.view == shareButton || touch.view == backButton) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - Share

- (void)test
{
    NSLog(@"test");
    
    if(customContorlView)
        [customContorlView removeFromSuperview];
    
    [self.moviePlayerController.moviePlayer.view addSubview:customContorlView];
    
}

- (UIImage *)thumbnailImageAtCurrentTime
{
    UIImage *thumbnail = [self.moviePlayerController.moviePlayer thumbnailImageAtTime:self.moviePlayerController.moviePlayer.currentPlaybackTime
                                                                           timeOption:MPMovieTimeOptionExact];
    //NSLog(@"the current time is %f ",self.moviePlayerController.moviePlayer.currentPlaybackTime);
    videoThumbnailImageView.image = thumbnail;
    return thumbnail;
}

- (IBAction)shareButtonAction:(id)sender
{
    [self.moviePlayerController.moviePlayer pause];
    [self.playPauseButton setImage:[UIImage imageNamed:@"pause_btn"] forState:UIControlStateNormal];
    [playPauseFullScreenButton setImage:[UIImage imageNamed:@"pause_btn"] forState:UIControlStateNormal];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 190)];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = 5.f;
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 5.f;
    
    RNBlurModalView  *modal = [[RNBlurModalView alloc] initWithView:view andController:self];
    modal.delegate = self;
    [modal show:self];
}

#pragma mark - Share control Tap on View methods

- (void) controlSelectTableViewInViewAtIndex:(NSIndexPath *)selectIndex
{
    if (selectIndex.row == 0) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
            SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                    
                    [fbController dismissViewControllerAnimated:YES completion:nil];
                    
                    switch(result){
                        case SLComposeViewControllerResultCancelled:
                        default:
                        {
                            PiLog(@"Cancelled.....");
                            
                        }
                            break;
                        case SLComposeViewControllerResultDone:
                        {
                            PiLog(@"Posted....");
                        }
                            break;
                    }};
                
                [fbController setInitialText:@" Please checkout this app at"];
                CFURLRef video_URL = (__bridge CFURLRef)([videoDetailsDict objectForKey:@"url"]);
                NSURL *videoUrl = (__bridge NSURL *)video_URL;
                [fbController addURL:videoUrl];
                CFURLRef image_URL = (__bridge CFURLRef)([videoDetailsDict objectForKey:@"thumbnail"]);
                NSURL *thumbnailurl = (__bridge NSURL *)image_URL;
                [thumbnailPreviewImage setImageWithURL:thumbnailurl placeholderImage:[UIImage imageNamed:@"vdo_preview.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                NSData *   data = [[NSData alloc]initWithContentsOfURL:thumbnailurl ];
                [fbController addImage:[[UIImage alloc]initWithData:data ]];

                [fbController setCompletionHandler:completionHandler];
                [self presentViewController:fbController animated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                    message:@"You can't post on Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    if (selectIndex.row == 1) {
        SLComposeViewController *twitter_Controller=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                
                [twitter_Controller dismissViewControllerAnimated:YES completion:nil];
                
                switch(result){
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        PiLog(@"Cancelled.....");
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        PiLog(@"Posted....");
                    }
                        break;
                }};
            
            [twitter_Controller setInitialText:@" Please checkout this app at"];
            CFURLRef video_URL = (__bridge CFURLRef)([videoDetailsDict objectForKey:@"url"]);
            NSURL *videoUrl = (__bridge NSURL *)video_URL;
            [twitter_Controller addURL:videoUrl];
            CFURLRef image_URL = (__bridge CFURLRef)([videoDetailsDict objectForKey:@"thumbnail"]);
            NSURL *thumbnailurl = (__bridge NSURL *)image_URL;
            [thumbnailPreviewImage setImageWithURL:thumbnailurl placeholderImage:[UIImage imageNamed:@"vdo_preview.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            NSData *   data = [[NSData alloc]initWithContentsOfURL:thumbnailurl ];
            [twitter_Controller addImage:[[UIImage alloc]initWithData:data ]];
            [twitter_Controller setCompletionHandler:completionHandler];
            [self presentViewController:twitter_Controller animated:YES completion:nil];
            
            
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }
}

#pragma mark - Render Image

- (void)touchOnViewToHideit
{
    [self.moviePlayerController.moviePlayer play];
    [self.playPauseButton setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [playPauseFullScreenButton setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
}
#pragma mark - Auto-orientation

//-(BOOL)shouldAutorotate
//{
//    if ([AppDelegate sharedDelegate].buttontap == YES) {
//        return NO;
//    }
//    return UIInterfaceOrientationMaskPortrait;
//    
//    if (blockRotation) {
//        return YES;
//    }
//    else
//        return NO;
//}
- (NSUInteger)supportedInterfaceOrientations
{
    if ([AppDelegate sharedDelegate].buttontap == YES) {
        return nil;
    }
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice]orientation];
    NSLog(@"MY Present orientation  %d",interfaceOrientation);
    if (blockRotation) {
        if (interfaceOrientation == UIDeviceOrientationUnknown)
        {
            NSLog(@"MY Present UIDeviceOrientationUnknown");
        }
        
        if(interfaceOrientation== UIDeviceOrientationPortrait){
            [exitFullScreenButton setHidden:NO];
            
            [customControlFullView removeFromSuperview];
            
            if(customContorlView)
                [customContorlView removeFromSuperview];
            [self.moviePlayerController.moviePlayer.view setFrame:moviePlayView.frame];
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            [self.moviePlayerController.moviePlayer.view setTransform:CGAffineTransformMakeRotation(-(2*M_PI))];
            [self performSelector:@selector(test) withObject:nil afterDelay:0.0];
        }
        
        
        if(interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            [exitFullScreenButton setHidden:NO];
            [customControlFullView removeFromSuperview];
            
            if(customContorlView)
                [customContorlView removeFromSuperview];
            
            [self.moviePlayerController.moviePlayer.view setFrame:moviePlayView.frame];
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            [self.moviePlayerController.moviePlayer.view setTransform:CGAffineTransformMakeRotation(-(2*M_PI))];
            [self performSelector:@selector(test) withObject:nil afterDelay:0.0];
        }
        
        else if(interfaceOrientation ==UIDeviceOrientationLandscapeLeft)
        {
            [exitFullScreenButton setHidden:YES];
            
            [AppDelegate sharedDelegate].allowRotation = YES;
            [customContorlView removeFromSuperview];
            if(customControlFullView)
                [customControlFullView removeFromSuperview];
            
            customControlFullView.backgroundColor = [UIColor clearColor];
            [self.moviePlayerController.moviePlayer.view setFrame:self.view.bounds];
            [self.moviePlayerController.moviePlayer.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            [self.moviePlayerController.moviePlayer.view addSubview:customControlFullView];
        }
        else if(interfaceOrientation==UIDeviceOrientationLandscapeRight)
        {
            [exitFullScreenButton setHidden:YES];
            [AppDelegate sharedDelegate].allowRotation = YES;
            [customContorlView removeFromSuperview];
            if(customControlFullView)
                [customControlFullView removeFromSuperview];
            customControlFullView.backgroundColor = [UIColor clearColor];
            [self.moviePlayerController.moviePlayer.view setFrame:self.view.bounds];
            [self.moviePlayerController.moviePlayer.view setTransform:CGAffineTransformMakeRotation(M_PI+M_PI/2)];
            
            [self.moviePlayerController.moviePlayer.view addSubview:customControlFullView];
            
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
        }
        
        return 0;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
        
    }
}

#pragma mark - in-App Work

- (IBAction)restoreButton:(id)sender
{
    [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
    if ([PFUser currentUser].isAuthenticated) {
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
            NSDate * serverDate = [[object objectForKey:@"ExpirationDate"] lastObject];
            [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:@"ExpirationDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"Restore Complete!");
        }];
    }
}

- (IBAction)buyButtonTapped:(id)sender
{
    SKProduct *product = _products[0];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[RageIAPHelper sharedInstance] buyProduct:product];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            if ([product.productIdentifier hasSuffix:@"monthlyrageface"]) {
                [self reload];
            }
            *stop = YES;
        }
    }];
}

- (void)reload {
    _products = nil;
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    [self setPlayPauseButton:nil];
    [self setFullScreenButton:nil];
    [self setCurrentTimeLabel:nil];
    [self setEndTimeLable:nil];
    customContorlView = nil;
    [self setCustomContorlView:nil];
    playerSlider = nil;
    [self setPlayerSlider:nil];
    soundSlider = nil;
    [self setSoundSlider:nil];
    customControlFullView = nil;
    [self setCustomControlFullView:nil];
    [super viewDidUnload];
}
@end
