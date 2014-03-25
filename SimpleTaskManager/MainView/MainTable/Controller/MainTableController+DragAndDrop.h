//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@class STMTask;

@interface MainTableController (DragAndDrop) <UIGestureRecognizerDelegate>

- (void)addLongPressRecognizer;

- (void)cancelDraggingAnimate:(BOOL)animate;

@end