//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;

@protocol PresentationOverlayControllerDelegate <NSObject>

-(void) userHasChosenToMarkTaskAsCompleted;
-(void) userHasChosenToCloseTaskOptions;

@end