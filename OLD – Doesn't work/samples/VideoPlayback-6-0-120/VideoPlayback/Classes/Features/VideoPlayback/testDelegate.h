//
//  testDelegate.h
//  VideoPlayback
//
//  Created by Daniel Lin on 11/28/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

@interface Objective_CPP : NSObject
- (void)hello_objectiveCpp:(NSString *)name;
@end


@interface testDelegate : NSObject<SampleAppMenuDelegate>

@end


@protocol SampleAppMenuDelegate <NSObject>

- (BOOL) menuProcess:(NSString *)itemName value:(BOOL) value;
- (BOOL) testNumber:(NSString *)itemName value:(int) value;
- (void) menuDidExit;

// DL DELEGATE

@end
