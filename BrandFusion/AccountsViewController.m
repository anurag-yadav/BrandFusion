//
//  AccountsViewController.m
//  DemoDownSlider
//
//  Created by Anurag Yadav on 6/22/13.
//  Copyright (c) 2013 Anurag Yadav. All rights reserved.
//

#import "AccountsViewController.h"
//scb
@interface AccountsViewController ()

@end

@implementation AccountsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//     ******  My BackUp

//-(void)removeControlsOfCustomControlFullView
//{
//    [mpVolumeParentFull removeFromSuperview];
//    [playerFullScreenSlider removeFromSuperview];
//    [playPauseFullScreenButton removeFromSuperview];
//    [muteButtonFullscreen removeFromSuperview];
//    
//    
//    
//}
//-(void)removeControlsOfCustomControlView
//{
//    [mpVolumeViewParentView removeFromSuperview];
//    [playerSlider removeFromSuperview];
//    [playPauseButton removeFromSuperview];
//    [muteButton removeFromSuperview];
//



//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    
//    if (blockRotation) {
//        if (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation ==UIInterfaceOrientationPortraitUpsideDown) {
//            if(customControlFullView)
//            {
//                [self removeControlsOfCustomControlFullView];
//                [customControlFullView removeFromSuperview];
//            }
//            [[UIApplication sharedApplication]setStatusBarHidden:NO];
//            
//            
//            [self.moviePlayerController.moviePlayer.view setFrame:moviePlayView.frame];
//            
//            
//            [self.customContorlView addSubview:playerSlider];
//            [self.customContorlView addSubview:mpVolumeViewParentView];
//            
//            [self.moviePlayerController.moviePlayer.view addSubview:customContorlView];
//            
//            
//            //            [self.moviePlayerController.moviePlayer.view setTransform:CGAffineTransformMakeRotation(-(2*M_PI))];
//            [self performSelector:@selector(test) withObject:nil afterDelay:1];
//            //            [mpVolumeParentFull setFrame:CGRectMake(336, 144, 135, 134)];
//            
//        }
//        else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//        {
//            if (customContorlView)
//            {
//                [self removeControlsOfCustomControlView];
//                [customContorlView removeFromSuperview];
//            }
//            [[UIApplication sharedApplication]setStatusBarHidden:YES];
//            
//            
//            customControlFullView.backgroundColor = [UIColor clearColor];
//            
//            [self.moviePlayerController.moviePlayer.view setFrame:self.view.bounds];
//            //            [self.moviePlayerController.moviePlayer.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
//            
//            [self.customControlFullView addSubview:playerFullScreenSlider];
//            [self.customControlFullView addSubview:mpVolumeParentFull];
//            
//            [self.moviePlayerController.moviePlayer.view addSubview:customControlFullView];
//        }
//        
//        return TRUE;
//        
//    }
//    else
//    {
//        return (interfaceOrientation == UIInterfaceOrientationPortrait);
//    }
//}


@end
