//
//  VideoPlayerViewController.h
//  CamfusionDemo
//
//  Created by Gaurav Garg on 6/12/13.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RNBlurModalView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+Screenshot.h"
#import "RNBlurView.h"
#import "BFNavigationController.h"


@interface VideoPlayerViewController : UIViewController<UIGestureRecognizerDelegate,controltaponView,RenderDelegate,NSURLConnectionDelegate>

{
    IBOutlet UILabel * lbl;
    UINavigationController * navController;
    BOOL isPlayingVideo;
    
    NSArray * array_TitleName;

    BOOL test;

    BOOL playbackFinish;
    BOOL blockRotation;
    IBOutlet UIImageView          *     videoThumbnailImageView;

    float                               totalVideoTime;
    IBOutlet UISlider             *     soundSlider;
    IBOutlet UILabel              *     label_Title;
    IBOutlet UILabel              *     label_Name;;
    IBOutlet UISlider             *     playerSlider;
    IBOutlet UIView               *     customControlFullView;
    IBOutlet UIView               *     customContorlView;
    IBOutlet UIView               *     mpVolumeViewParentView;
    IBOutlet UIButton             *     playPauseFullScreenButton;
    IBOutlet UIButton             *     exitFullScreenButton;
    IBOutlet UILabel              *     endTimeFullLabel;
    IBOutlet UISlider             *     playerFullScreenSlider;
    IBOutlet UIView               *     mpVolumeParentFull;
    IBOutlet UIView               *     moviePlayView;
    IBOutlet UITextView           *     textView_Description;
    
    IBOutlet UIButton             *     muteButton;
    IBOutlet UIButton             *     muteButtonFullscreen;
    IBOutlet UIButton             *     backButton;
    IBOutlet UIButton             *     shareButton;
    IBOutlet UIImageView          *     thumbnailPreviewImage;
    float                               voulumeValue;
    UIImageView                   *     animation_ImageView;
    NSMutableData                 *     mutableData;
    int currentVideoid;
}

@property (assign, nonatomic) int currentVideoid;
@property (strong, nonatomic) IBOutlet UIView       *customControlFullView;
@property (strong, nonatomic) IBOutlet UISlider     *soundSlider;
@property (strong, nonatomic) IBOutlet UISlider     *playerSlider;
@property (strong, nonatomic) IBOutlet UIView       *customContorlView;
@property (strong, nonatomic) IBOutlet UILabel      *endTimeLable;
@property (strong, nonatomic) IBOutlet UIButton     *playPauseButton,*playPauseFullScreenButton;
@property (strong, nonatomic) IBOutlet UIButton     *fullScreenButton;

@property (strong, nonatomic) NSOperationQueue      *queue;
@property (strong, nonatomic) NSDictionary          *videoDetailsDict;
@property (strong, nonatomic) NSArray               *wholeDetailsOfVideo;
@property (strong, nonatomic) UILabel                   *currentTimeLabel;
@property (strong, nonatomic) NSTimer                   *myTimer;
@property (nonatomic, assign) float                      totalVideoTime;
@property (nonatomic, assign) BOOL                       playbackFinish;
@property (nonatomic, strong) MPMoviePlayerViewController   *moviePlayerController;
@property (nonatomic, strong) NSString                  *descripStr;

- (void) addsubViewonFullScreen;

- (IBAction) playPauseButtonAction:(id)sender;
- (IBAction) fullScreenButtonAction:(id)sender;
- (IBAction) onPlayerSliderChange: (UISlider*)sender;
- (IBAction) backButtonAction:(id)sender;
- (IBAction) moviePlayButtonAction:(id)sender;
- (IBAction) muteandUnmute:(id)sender;
- (IBAction) shareButtonAction:(id)sender;
- (IBAction) downloadVideosTest:(id)sender;


//- (IBAction)restoreButton:(id)sender;
//- (IBAction)buyButtonTapped:(id)sender;

@end
