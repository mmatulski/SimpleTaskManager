//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+DragAndDrop.h"
#import "STMTask.h"


@implementation MainTableController (DragAndDrop)

- (void)dropOrHideDraggedCellForPoint:(CGPoint)point globalPoint:(CGPoint)globalPoint {

    BOOL noCellFound = false;
    NSIndexPath *suggestedIndexPath = [self getPath:point globalPoint:globalPoint noCell:&noCellFound];

   if(self.temporaryTargetForDraggedIndexPath){
        if(suggestedIndexPath){
            if(![self.temporaryTargetForDraggedIndexPath isEqual:suggestedIndexPath]){
                [self changeTargetTo:suggestedIndexPath];
            }
        } else if(!noCellFound){
            [self changeTargetTo:nil];
        }
    } else {
        if(suggestedIndexPath){
            [self changeTargetTo:suggestedIndexPath];
        }
    }
}

- (void)changeTargetTo:(NSIndexPath *) indexPath {
    [self.tableView beginUpdates];

    if(self.temporaryTargetForDraggedIndexPath){
        [self.tableView deleteRowsAtIndexPaths:@[self.temporaryTargetForDraggedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    self.temporaryTargetForDraggedIndexPath = indexPath;

    if(self.temporaryTargetForDraggedIndexPath){
        [self.tableView insertRowsAtIndexPaths:@[self.temporaryTargetForDraggedIndexPath]  withRowAnimation:UITableViewRowAnimationFade];
    }

    [self.tableView endUpdates];

    if(self.temporaryTargetForDraggedIndexPath){
        [self.tableView scrollToRowAtIndexPath:self.temporaryTargetForDraggedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
    }
}

- (NSIndexPath *)getPath:(CGPoint)point globalPoint:(CGPoint)globalPoint noCell:(BOOL *)noCellFound {
    NSIndexPath * result = nil;

    NSIndexPath *indexPathUnderTheFinger = [self.tableView indexPathForRowAtPoint:point];
    STMTask * task = [self.fetchedResultsController objectAtIndexPath:indexPathUnderTheFinger];
    UITableViewCell *cellUnderTheFinger = [self.tableView cellForRowAtIndexPath:indexPathUnderTheFinger];

    if(self.temporaryTargetForDraggedIndexPath){
        if([self.temporaryTargetForDraggedIndexPath isEqual:indexPathUnderTheFinger]){
            return self.temporaryTargetForDraggedIndexPath;
        }
    }

    CGPoint pointOnCell = [cellUnderTheFinger convertPoint:globalPoint fromView:nil];
    CGRect cellBounds = cellUnderTheFinger.bounds;
    if(cellBounds.size.height != 0){
        CGFloat cellFactor = pointOnCell.y / cellBounds.size.height;
        //DDLogInfo(@"cF %f %d",  cellFactor, [indexPathUnderTheFinger row]);


        BOOL show = false;
        BOOL showOnBottom = false;
        if(cellFactor < 0.5){
            show = true;
        } else if(cellFactor >= 0.5){
            show = true;
            showOnBottom = true;
        } else {

        }

        int row = [indexPathUnderTheFinger row];

        if(show){
            result = [NSIndexPath indexPathForRow:showOnBottom ? row + 1 : row inSection:0];
            if([self.draggedIndexPath isEqual:result]){
                result = nil;
            }
        }



    } else {
        if(noCellFound){
            *noCellFound = true;
        }
    }

    return result;
}

@end