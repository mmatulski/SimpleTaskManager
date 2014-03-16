//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@interface MainTableController (DragAndDrop)
- (void)dropOrHideDraggedCellForPoint:(CGPoint)point globalPoint:(CGPoint)point1;
@end