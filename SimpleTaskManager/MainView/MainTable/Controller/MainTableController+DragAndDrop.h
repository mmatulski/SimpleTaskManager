//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@class STMTask;

@interface MainTableController (DragAndDrop)

- (void)dropOrHideDraggedCellForPoint:(CGPoint)point globalPoint:(CGPoint)point1;

- (void)userHasDroppedItem;

- (void)cancelDragging;

- (void)emergencyCancelDragging;

- (void)userHasPressedLongOnIndexPath:(NSIndexPath *)path andWindowPoint:(CGPoint)point;
@end