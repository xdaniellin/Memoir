/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>
#import "VideoPlaybackEAGLView.h"
#import "SampleApplicationSession.h"
#import "SampleAppMenuViewController.h"
#import <Vuforia/DataSet.h>

@interface VideoPlaybackViewController : UIViewController <SampleApplicationControl, SampleAppMenuDelegate> {
    Vuforia::DataSet*  dataSet;
    BOOL fullScreenPlayerPlaying;
    
    // menu options
    BOOL extendedTrackingEnabled;
    BOOL continuousAutofocusEnabled;
    BOOL flashEnabled;
    BOOL playFullscreenEnabled;
    BOOL frontCameraEnabled;
}

- (void)rootViewControllerPresentViewController:(UIViewController*)viewController inContext:(BOOL)currentContext;
- (void)rootViewControllerDismissPresentedViewController;

@property (nonatomic, strong) VideoPlaybackEAGLView* eaglView;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) SampleApplicationSession * vapp;

@property (nonatomic, readwrite) BOOL showingMenu;

@end
