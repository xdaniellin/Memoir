/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/ImageTarget.h>


#import "VideoPlaybackEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "Teapot.h"
#import "SampleMath.h"
#import "Quad.h"

//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
    // --- Data private to this unit ---
    
    // Texture filenames (an Object3D object is created for each texture)
    const char* textureFilenames[kNumAugmentationTextures] = {
        "icon_play.png",
        "icon_loading.png",
        "icon_error.png",
        "VuforiaSizzleReel_1.png",
        "VuforiaSizzleReel_2.png"
    };
    
    enum tagObjectIndex {
        OBJECT_PLAY_ICON,
        OBJECT_BUSY_ICON,
        OBJECT_ERROR_ICON,
        OBJECT_KEYFRAME_1,
        OBJECT_KEYFRAME_2,
    };
    
    const NSTimeInterval TRACKING_LOST_TIMEOUT = 2.0f;
    
    // Playback icon scale factors
    const float SCALE_ICON = 2.0f;
    
    // Video quad texture coordinates
    const GLfloat videoQuadTextureCoords[] = {
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
    };
    
    struct tagVideoData {
        // Needed to calculate whether a screen tap is inside the target
        Vuforia::Matrix44F modelViewMatrix;
        
        // Trackable dimensions
        Vuforia::Vec2F targetPositiveDimensions;
        
        // Currently active flag
        BOOL isActive;
    } videoData[kNumVideoTargets];
    
    //DL: Shouldn't this be declared AFTER playerIndex?..?
    int touchedTarget = 0;
    
    //DL: Custom global vars
    int list_version1[4] = { 5, 6, 7, 8 }; // codepath
    int list_version2[5] = { 1, 0, 2, 1, 0 }; // kingsley
    int list_version3[1] = { 1 }; // fan
    int current_index = 0;
    int arrayLength = 0;
    int current_listOfVideos [] = {};
    bool changedJustNow = true;
    int playerIndex = 0;
    
    float progress = 0.0;
    float seconds_played = 0.0;
    Float64 total_seconds = 0.0;
    
    //DL: Delegate Stuff; these should be publicly accessible
    // bool scanSuccessful
    // int numberOfVideos = list_version
}

//int playerIndex = 1;

@interface VideoPlaybackEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end


@implementation VideoPlaybackEAGLView

@synthesize vapp;

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame rootViewController:(VideoPlaybackViewController *) rootViewController appSession:(SampleApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        
        videoPlaybackViewController = rootViewController;
        
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        }
        
        // Load the augmentation textures
        for (int i = 0; i < kNumAugmentationTextures; ++i) {
            augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
        }
        
        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        sampleAppRenderer = [[SampleAppRenderer alloc] initWithSampleAppRendererControl:self deviceMode:Vuforia::Device::MODE_AR stereo:false nearPlane:5 farPlane:5000.0];
        
        // Generate the OpenGL ES texture and upload the texture data for use
        // when rendering the augmentation
        for (int i = 0; i < kNumAugmentationTextures; ++i) {
            GLuint textureID;
            glGenTextures(1, &textureID);
            [augmentationTexture[i] setTextureID:textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture[i] pngData]);
            
            // Set appropriate texture parameters (for NPOT textures)
            if (OBJECT_KEYFRAME_1 <= i) {
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            }
        }
        
        [sampleAppRenderer initRendering];
        [self initShaders];
    }
    
    return self;
}

- (void) willPlayVideoFullScreen:(BOOL) fullScreen {
    playVideoFullScreen = fullScreen;
}

- (void) prepare {
    // For each target, create a VideoPlayerHelper object and zero the
    // target dimensions
    // For each target, create a VideoPlayerHelper object and zero the
    // target dimensions
    for (int i = 0; i < kNumVideoTargets; ++i) {
        printf("Int number: %u\n", i);
        videoPlayerHelper[i] = [[VideoPlayerHelper alloc] initWithRootViewController:videoPlaybackViewController];
        videoData[i].targetPositiveDimensions.data[0] = 0.0f;
        videoData[i].targetPositiveDimensions.data[1] = 0.0f;
    }
    
    // Start video playback from the current position (the beginning) on the
    // first run of the app
    for (int i = 0; i < kNumVideoTargets; ++i) {
        videoPlaybackTime[i] = VIDEO_PLAYBACK_CURRENT_POSITION;
    }
    
    // For each video-augmented target
    for (int i = 0; i < kNumVideoTargets; ++i) {
        // Load a local file for playback and resume playback if video was
        // playing when the app went into the background
        VideoPlayerHelper* player = [self getVideoPlayerHelper:i];
        NSString* filename;
        printf("Int number: %u\n", i);
        switch (i) {
            case 0:
                //filename = @"codepath_dog.mp4";
                filename = @"14_dl_portland.mp4";//@"codepath_dog.mp4";//@"14_dl_portland.mp4";
                break;
            case 1:
                filename = @"18_dl_fan.mp4";
                break;
            case 2:
                filename = @"codepath_dog.mp4";
                break;
            case 3:
                filename = @"codepath_drunk.mp4"; //DL: need to convert to .mp4 ... maybe play with tap controls! UI? inter-clip "white blips"
                break;
            case 4:
                filename = @"codepath_study.mp4";
                break;
            case 5:
                filename = @"xcode_charlie_1.mp4";
                break;
            case 6:
                filename = @"xcode_combined1.mp4";
                break;
            case 7:
                filename = @"xcode_charlie_2.mp4";
                break;
            case 8:
                filename = @"xcode_combined2.mp4";
                break;
            default:
                filename = @"18_dl_fan.mp4";
                break;
        }
        
        if (NO == [player load:filename playImmediately:NO fromPosition:videoPlaybackTime[i]]) {
            NSLog(@"Failed to load media");
        }
    }
    
    
}

- (void) dismiss {
    for (int i = 0; i < kNumVideoTargets; ++i) {
        [videoPlayerHelper[i] unload];
        videoPlayerHelper[i] = nil;
    }
}

- (void)dealloc
{
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    for (int i = 0; i < kNumAugmentationTextures; ++i) {
        augmentationTexture[i] = nil;
    }
    
    for (int i = 0; i < kNumVideoTargets; ++i) {
        videoPlayerHelper[i] = nil;
    }
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}

//------------------------------------------------------------------------------
#pragma mark - User interaction

- (bool) handleTouchPoint:(CGPoint) point {
    // DL: Touch Event
    // DL: I dont think we need this (especially if we're autoplaying), but this controls UI interaction when user taps on screen
    
    // Store the current touch location
    touchLocation_X = point.x;
    touchLocation_Y = point.y;
    //printf("%f", touchLocation_X);

    

    
    
    // Determine which target was touched (if no target was touch, touchedTarget
    // will be -1)
    touchedTarget = [self tapInsideTargetWithID];
    
    // Ignore touches when videoPlayerHelper is playing in fullscreen mode
    if (-1 != touchedTarget && PLAYING_FULLSCREEN != [videoPlayerHelper[touchedTarget] getStatus]) {
        // Get the state of the video player for the target the user touched
        MEDIA_STATE mediaState = [videoPlayerHelper[touchedTarget] getStatus];
        
        
        // DL: TURNING OFF ABILITY to pause video -- conflicts too much with navigation
        // If any on-texture video is playing, pause it
//        for (int i = 0; i < kNumVideoTargets; ++i) {
//            if (PLAYING == [videoPlayerHelper[i] getStatus]) {
//                [videoPlayerHelper[i] pause];
//            }
//        }
    
#ifdef EXAMPLE_CODE_REMOTE_FILE
        // With remote files, single tap starts playback using the native player
        if (ERROR != mediaState && NOT_READY != mediaState) {
            // Play the video
            NSLog(@"Playing video with native player");
            [videoPlayerHelper[touchedTarget] play:YES fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
#else
        // For the target the user touched
        if (ERROR != mediaState && NOT_READY != mediaState && PLAYING != mediaState) {
            // Play the video
            NSLog(@"Playing video with on-texture player");
            [videoPlayerHelper[touchedTarget] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
#endif
        return true;
    } else {
        
        //DL: Tap behavior when tapping outside of the trigger
        float max_X = 375.0;
        float dividerRatio = 0.5; // split the screen in half, or 0.5
        float divider_X = max_X * dividerRatio;
        if(touchLocation_X > divider_X){
            printf("TAPPED RIGHT \n");
            playerIndex = list_version1[current_index];
            // Restart current video
            [videoPlayerHelper[playerIndex] seekTo:(0.01)];
            [videoPlayerHelper[playerIndex] pause];
            
            // Move to next video
            changedJustNow = true;
            current_index++;
            playerIndex = list_version1[current_index];
            [videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
            
            // DL: INSERT DELEGATE HERE "skipToNextVideo(newIndex)"
            // DL: TEST NSNOTIFICATIONCENTER!!! (Post)
            NSDictionary *dict =  [NSDictionary dictionaryWithObject:@0.8 forKey:@"progress"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tapRight"
                                                                object:nil
                                                              userInfo:dict];
        }
        else{
            printf("TAPPED LEFT \n");
            // Restart current video
            if(current_index > 0){
                playerIndex = list_version1[current_index];
                // Restart current video
                [videoPlayerHelper[playerIndex] seekTo:(0.01)];
                [videoPlayerHelper[playerIndex] pause];
                
                // Move to previous video
                changedJustNow = true;
                current_index--;
                playerIndex = list_version1[current_index];
                [videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                
            }
            else{
                [videoPlayerHelper[current_index] seekTo:(0.01)];
            }
            
            // DL: INSERT DELEGATE HERE "skipToPrevVideo(newIndex)"
            NSDictionary *dict =  [NSDictionary dictionaryWithObject:@1.0 forKey:@"progress"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tapLeft"
                                                                object:nil
                                                              userInfo:dict];
            
            
        }
        
        return false;
    }
}
- (void) preparePlayers {
    [self prepare];
}


- (void) dismissPlayers {
    [self dismiss];
}



// Determine whether a screen tap is inside the target
- (int)tapInsideTargetWithID
{
    Vuforia::Vec3F intersection, lineStart, lineEnd;
    Vuforia::Matrix44F inverseProjMatrix = SampleMath::Matrix44FInverse(tapProjectionMatrix);
    CGRect rect = [self bounds];
    int touchInTarget = -1;
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // The target returns as pose the centre of the trackable.  Thus its
    // dimensions go from -width / 2 to width / 2 and from -height / 2 to
    // height / 2.  The following if statement simply checks that the tap is
    // within this range
    for (int i = 0; i < kNumVideoTargets; ++i) {
        SampleMath::projectScreenPointToPlane(inverseProjMatrix, videoData[i].modelViewMatrix, rect.size.width, rect.size.height,
                                              Vuforia::Vec2F(touchLocation_X, touchLocation_Y), Vuforia::Vec3F(0, 0, 0), Vuforia::Vec3F(0, 0, 1), intersection, lineStart, lineEnd);
        
        if ((intersection.data[0] >= -videoData[i].targetPositiveDimensions.data[0]) && (intersection.data[0] <= videoData[i].targetPositiveDimensions.data[0]) &&
            (intersection.data[1] >= -videoData[i].targetPositiveDimensions.data[1]) && (intersection.data[1] <= videoData[i].targetPositiveDimensions.data[1])) {
            // The tap is only valid if it is inside an active target
            if (YES == videoData[i].isActive) {
                touchInTarget = i;
                break;
            }
        }
    }
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    return touchInTarget;
}

// Get a pointer to a VideoPlayerHelper object held by this EAGLView
- (VideoPlayerHelper*)getVideoPlayerHelper:(int)index
{
    return videoPlayerHelper[index];
}


- (void) updateRenderingPrimitives
{
    [sampleAppRenderer updateRenderingPrimitives];
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
    if (! vapp.cameraIsStarted) {
        return;
    }
    
    [sampleAppRenderer renderFrameVuforia];
}


- (void)renderFrameWithState:(const Vuforia::State &)state projectMatrix:(Vuforia::Matrix44F &)projectionMatrix
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    // Render the video background
    [sampleAppRenderer renderVideoBackground];
    
    glEnable(GL_DEPTH_TEST);
    
    // We must detect if background reflection is active and adjust the culling
    // direction.  If the reflection is active, this means the pose matrix has
    // been reflected as well, therefore standard counter clockwise face culling
    // will result in "inside out" models
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // Get the active trackables
    int numActiveTrackables = state.getNumTrackableResults();
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // Assume all targets are inactive (used when determining tap locations)
    for (int i = 0; i < kNumVideoTargets; ++i) {
        videoData[i].isActive = NO;
    }
    
    tapProjectionMatrix = projectionMatrix;
    
    // Did we find any trackables this frame?
    for (int i = 0; i < numActiveTrackables; ++i) {
        // Get the trackable
        const Vuforia::TrackableResult* trackableResult = state.getTrackableResult(i);
        const Vuforia::ImageTarget& imageTarget = (const Vuforia::ImageTarget&) trackableResult->getTrackable();
        
        // VideoPlayerHelper to use for current target
        
        // DL: This is index used for choosing which video to play!!! 0 or 1, currently
        // - getId() works (1,2,...) but getName() is weird and just returns random numbers
        // - ok this is working now: appropriately plays correct video based on image ID
        // - next step: identify the right "end video moment", currently REACHED_END keeps firing
        //      - Fixed: "REACHED_END" state actually ires the first time the videoplayer is loaded, so i made a global var bool that checks to see when this is the case (to prevent it from increasing it the index without playing the video)
        // TO DO:
        //      - Remove: (1) white flash, (2) icon button
        //      - Aspect Ratio (Aspect Fill? The dog is long)
        //      - Custom view controller container
        //      - UI Controls? Tap to advance to next button
        int playerIndex = 0;    // stone
        
        if(imageTarget.getId() == 1) {
            // DL: INSERT DELEGATE HERE scanned(TRUE)
            // DL: TEST NSNOTIFICATIONCENTER!!! (Post)
            arrayLength = sizeof(list_version1)/sizeof(list_version1[0]);

            NSDictionary *dict = [NSDictionary dictionaryWithObject:@(arrayLength) forKey:@"numberOfVideos"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scanOn"
                                                                object:nil
                                                              userInfo:dict];
            
            printf("PORTLAND DETECTED!!! \n");
            
            if(current_index >= arrayLength){
                current_index = 0;
            }
            //printf("Why is this crashing? current_index: %u\n", current_index);
            playerIndex = list_version1[current_index];
        } // portland

        if(imageTarget.getId() == 3) {
            printf("FAN DETECTED!!! \n");
            arrayLength = sizeof(list_version3)/sizeof(list_version3[0]);
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@(arrayLength) forKey:@"numberOfVideos"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scanOn"
                                                                object:nil
                                                              userInfo:dict];
            
            printf("PORTLAND DETECTED!!! \n");
            
            if(current_index >= arrayLength){
                current_index = 0;
            }
            //printf("Why is this crashing? current_index: %u\n", current_index);
            playerIndex = list_version3[current_index];
        } // fan
        
        
        //int current_videoIndex = current_listOfVideos[current_index];
        //printf("current index: %u\n", current_index);
        
        
        //for (int i = 0; i < 5; i++)
            //printf("index: %u\n", current_listOfVideos[i]);
        //printf("current video index: %u\n", current_videoIndex);
        //playerIndex = current_videoIndex;    // stone
        
        
        
        
        // DL: Calculating progress, seconds passed, etc
        //printf("Why is this crashing? playerIndex: %u\n", playerIndex);
        seconds_played = [videoPlayerHelper[playerIndex] getCurrentPosition];
        total_seconds = [videoPlayerHelper[playerIndex] getLength];
        if ((seconds_played/total_seconds) != progress){
            progress = seconds_played / total_seconds;
            // DL: INSERT DELEGATE HERE updateProgressBar(currentIndex, progress)
            // DL: TEST NSNOTIFICATIONCENTER !!! (post: progressUpdate)
            //NSDictionary *dict =  [NSDictionary dictionaryWithObject:@(progress) forKey:@"progress"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @(progress), @"progress", @(current_index), @"current_index", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"progressUpdate"
                                                                object:nil
                                                              userInfo:dict];

            
        }
        
        
        //printf("seconds played: %lf\n", seconds_played);
        //printf("total seconds: %lf\n", total_seconds);
        //printf("total progress: %lf %%\n", progress);
        
        // DL: PROGRESS RATIO messing with video control, testing skipping / seekTo
        if(progress > 0.5){
            //printf("MORE THAN HALF WAY! \n");
            //[videoPlayerHelper[i] seekTo:(total_seconds - 0.01)];
            //[videoPlayerHelper[i] seekTo:(0)];
        }
        
        

        
        // Mark this video (target) as active
        videoData[playerIndex].isActive = YES;
        
        // Get the target size (used to determine if taps are within the target)
        if (0.0f == videoData[playerIndex].targetPositiveDimensions.data[0] ||
            0.0f == videoData[playerIndex].targetPositiveDimensions.data[1]) {
            const Vuforia::ImageTarget& imageTarget = (const Vuforia::ImageTarget&) trackableResult->getTrackable();
            
            Vuforia::Vec3F size = imageTarget.getSize();
            videoData[playerIndex].targetPositiveDimensions.data[0] = size.data[0];
            videoData[playerIndex].targetPositiveDimensions.data[1] = size.data[1];
            
            // The pose delivers the centre of the target, thus the dimensions
            // go from -width / 2 to width / 2, and -height / 2 to height / 2
            videoData[playerIndex].targetPositiveDimensions.data[0] /= 2.0f;
            videoData[playerIndex].targetPositiveDimensions.data[1] /= 2.0f;
        }
        
        // Get the current trackable pose
        const Vuforia::Matrix34F& trackablePose = trackableResult->getPose();
        
        // This matrix is used to calculate the location of the screen tap
        videoData[playerIndex].modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
        
        float aspectRatio;
        const GLvoid* texCoords;
        GLuint frameTextureID = 0;
        BOOL displayVideoFrame = YES;
        
        // Retain value between calls
        static GLuint videoTextureID[kNumVideoTargets] = {0};
        
        MEDIA_STATE currentStatus = [videoPlayerHelper[playerIndex] getStatus];
        
        // NSLog(@"MEDIA_STATE for %d is %d", playerIndex, currentStatus);
        
        // --- INFORMATION ---
        // One could trigger automatic playback of a video at this point.  This
        // could be achieved by calling the play method of the VideoPlayerHelper
        // object if currentStatus is not PLAYING.  You should also call
        // getStatus again after making the call to play, in order to update the
        // value held in currentStatus.
        // --- END INFORMATION ---
        
        switch (currentStatus) {
            case PLAYING: {
                // If the tracking lost timer is scheduled, terminate it
                if (nil != trackingLostTimer) {
                    // Timer termination must occur on the same thread on which
                    // it was installed
                    [self performSelectorOnMainThread:@selector(terminateTrackingLostTimer) withObject:nil waitUntilDone:YES];
                }
                
                // Upload the decoded video data for the latest frame to OpenGL
                // and obtain the video texture ID
                GLuint videoTexID = [videoPlayerHelper[playerIndex] updateVideoData];
                
                if (0 == videoTextureID[playerIndex]) {
                    videoTextureID[playerIndex] = videoTexID;
                }
                
                // Fallthrough
            }
            case PAUSED:
                if (0 == videoTextureID[playerIndex]) {
                    // No video texture available, display keyframe
                    displayVideoFrame = NO;
                }
                else {
                    // Display the texture most recently returned from the call
                    // to [videoPlayerHelper updateVideoData]
                    frameTextureID = videoTextureID[playerIndex];
                }
                
                break;
                
            default:
                videoTextureID[playerIndex] = 0;
                displayVideoFrame = NO;
                break;
        }
        
        if (YES == displayVideoFrame) {
            // ---- Display the video frame -----
            aspectRatio = (float)[videoPlayerHelper[playerIndex] getVideoHeight] / (float)[videoPlayerHelper[playerIndex] getVideoWidth];
            texCoords = videoQuadTextureCoords;
        }
        else {
            // ----- Display the keyframe -----
            Texture* t = augmentationTexture[OBJECT_KEYFRAME_1]; //[OBJECT_KEYFRAME_1 + playerIndex]; //commenting out playerIndex bc idc
            //frameTextureID = [t textureID]; //DL: Temp removing
            frameTextureID = videoTextureID[playerIndex];
            aspectRatio = (float)[t height] / (float)[t width];
            texCoords = quadTexCoords;
        }
        
        // If the current status is valid (not NOT_READY or ERROR), render the
        // video quad with the texture we've just selected
        if (NOT_READY != currentStatus) {
            // Convert trackable pose to matrix for use with OpenGL
            Vuforia::Matrix44F modelViewMatrixVideo = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
            Vuforia::Matrix44F modelViewProjectionVideo;
            
            //            SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, videoData[playerIndex].targetPositiveDimensions.data[0],
            //                                             &modelViewMatrixVideo.data[0]);
            
            // DL: This is where *stuff* is rendered on the texture...maybe figure out how to swap videoData[playerIndex] here?
            //printf("Player Index: %u\n", playerIndex);

            SampleApplicationUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[0],
                                                    videoData[playerIndex].targetPositiveDimensions.data[0] * aspectRatio,
                                                    videoData[playerIndex].targetPositiveDimensions.data[0],
                                                    &modelViewMatrixVideo.data[0]);
            
            SampleApplicationUtils::multiplyMatrix(projectionMatrix.data,
                                                   &modelViewMatrixVideo.data[0] ,
                                                   &modelViewProjectionVideo.data[0]);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, frameTextureID);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionVideo.data[0]);
            glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
            glDrawElements(GL_TRIANGLES, kNumQuadIndices, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
        }
        
        // If the current status is not PLAYING, render an icon
        if (PLAYING != currentStatus) {
            GLuint iconTextureID; //DL: Removed
            
            switch (currentStatus) {
                case READY:
                case REACHED_END:
                    
                    if(changedJustNow == true){
                        [videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                        changedJustNow = false;
                    }
                    else {
                        changedJustNow = true;
                        printf("HELLO THERE! I REACHED THE END OF THIS VIDEO \n");
                        printf("Current Index BEFORE: %u\n", current_index);
                        current_index++;
                        printf("Current Index AFTER: %u\n", current_index);
                        
                        // DL: INSERT DELEGATE HERE skipNextVideo();
                        // DL: TEST NSNOTIFICATIONCENTER!!! (Post)
                        NSDictionary *dict =  [NSDictionary dictionaryWithObject:@0.8 forKey:@"progress"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"tapRight"
                                                                            object:nil
                                                                          userInfo:dict];
                    }
                    
                    //[videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                    // DL: This, alone, PLAYS the video (you can hear the audio), but its not visible ...
                    //[videoPlayerHelper[touchedTarget] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                    //playerIndex = 1;    // stones
                    
                case PAUSED: {
                    //[videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                }
                case STOPPED: {
//                    if(changedJustNow == true){
//                        [videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
//                        changedJustNow = false;
//                    }

                    
                    // DL: No icon! By Commenting it out
                    // ----- Display play icon -----
                    iconTextureID = [augmentationTexture[OBJECT_PLAY_ICON] textureID];
                    
                    // DL: This is the "on scan moment" where we can add scanned UI !!!
                    //playerIndex += 1;
                    
                    // DL: Autoplay
                    //[videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                    break;
                }
                    
                case ERROR: {
                    // ----- Display error icon -----
                    //iconTextureID = [augmentationTexture[OBJECT_ERROR_ICON] textureID];
                    break;
                }
                    
                default: {
                    // ----- Display busy icon -----
                    //iconTextureID = [augmentationTexture[OBJECT_BUSY_ICON] textureID];
                    break;
                }
            }
            
            // Convert trackable pose to matrix for use with OpenGL
            Vuforia::Matrix44F modelViewMatrixButton = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
            Vuforia::Matrix44F modelViewProjectionButton;
            
            //SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON_TRANSLATION, &modelViewMatrixButton.data[0]);
            SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, 5.0f, &modelViewMatrixButton.data[0]);
            
            SampleApplicationUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                                    videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                                    videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                                    &modelViewMatrixButton.data[0]);
            
            SampleApplicationUtils::multiplyMatrix(projectionMatrix.data,
                                                   &modelViewMatrixButton.data[0] ,
                                                   &modelViewProjectionButton.data[0]);
            
            glDepthFunc(GL_LEQUAL);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, quadTexCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            // Blend the icon over the background
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, iconTextureID); //DL: Removed
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionButton.data[0] );
            glDrawElements(GL_TRIANGLES, kNumQuadIndices, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisable(GL_BLEND);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
            
            glDepthFunc(GL_LESS);
        }
        
        SampleApplicationUtils::checkGlError("VideoPlayback renderFrameVuforia");
    }
    
    // --- INFORMATION ---
    // One could pause automatic playback of a video at this point.  Simply call
    // the pause method of the VideoPlayerHelper object without setting the
    // timer (as below).
    // --- END INFORMATION ---
    
    // If a video is playing on texture and we have lost tracking, create a
    // timer on the main thread that will pause video playback after
    // TRACKING_LOST_TIMEOUT seconds
    for (int i = 0; i < kNumVideoTargets; ++i) {
        if (nil == trackingLostTimer && NO == videoData[i].isActive && PLAYING == [videoPlayerHelper[i] getStatus]) {
            [self performSelectorOnMainThread:@selector(createTrackingLostTimer) withObject:nil waitUntilDone:YES];
            break;
        }
    }
    
    

    
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    [self presentFramebuffer];
    
}

// Create the tracking lost timer
- (void)createTrackingLostTimer
{
    trackingLostTimer = [NSTimer scheduledTimerWithTimeInterval:TRACKING_LOST_TIMEOUT target:self selector:@selector(trackingLostTimerFired:) userInfo:nil repeats:NO];
}


// Terminate the tracking lost timer
- (void)terminateTrackingLostTimer
{
    [trackingLostTimer invalidate];
    trackingLostTimer = nil;
}


// Tracking lost timer fired, pause video playback
- (void)trackingLostTimerFired:(NSTimer*)timer
{
    // Tracking has been lost for TRACKING_LOST_TIMEOUT seconds, pause playback
    // (we can safely do this on all our VideoPlayerHelpers objects)
    for (int i = 0; i < kNumVideoTargets; ++i) {
        [videoPlayerHelper[i] pause];
    }
    trackingLostTimer = nil;
    
    // DL: INSERT DELEGATE HERE: OFFICIALLY DISMISS SCANNED UI; TRACKING LOST scanned(false)
    // DL: TEST NSNOTIFICATIONCENTER!!! (Post)
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@0 forKey:@"numberOfVideos"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"scanOn"
                                                        object:nil
                                                      userInfo:dict];
}


- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                                   fragmentShaderFileName:@"Simple.fragsh"];
    
    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}



@end

