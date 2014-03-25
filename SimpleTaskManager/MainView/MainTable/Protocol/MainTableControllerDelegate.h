//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;
@class STMTaskModel;

@protocol MainTableControllerDelegate <NSObject>

-(UIView *) viewForTemporaryViewsPresentation;

-(void) taskHasBeenSelected;
-(void) taskHasBeenUnselected;
-(void) anotherTaskHasBeenSelected;
-(void) selectedTaskFrameChanged:(CGRect)changedFrame;

-(void) taskHasBeenDragged;
-(void) taskHasBeenDropped;
-(void) taskDraggingCancelled;

@end