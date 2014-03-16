//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+DragAndDrop.h"


@implementation MainTableController (DragAndDrop)

- (void)dropOrHideDraggedCellForPoint:(CGPoint)point {

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    STMTask * task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if(self.draggedIndexPath){

    }

}

@end