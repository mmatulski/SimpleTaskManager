//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+DragAndDrop.h"
#import "STMTask.h"
#import "DragAndDropHandler.h"
#import "STMTaskModel.h"
#import "DBController.h"
#import "SyncGuardService.h"
#import "LocalUserLeg.h"
#import "MessagesHelper.h"
#import "MainTableDataSource.h"


@implementation MainTableController (DragAndDrop)

- (void)userHasPressedLongOnIndexPath:(NSIndexPath *)indexPath andWindowPoint:(CGPoint)pointRelatedToWindow {
    STMTask *task = [self.dataSource taskForIndexPath:indexPath];

    if(task){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        self.draggedItemModel = [[STMTaskModel alloc] initWitEntity:task];

        [self disableTableGestureRecognizerForScrolling];

        [self.dragAndDropHandler dragView:cell fromPoint:pointRelatedToWindow];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];

    }
}

- (void)cancelDragging {
    NSIndexPath *indexPathSource = [self indexPathForDraggedItem];
    NSIndexPath *indexPathTarget = self.temporaryTargetForDraggedIndexPath;

    self.draggedItemModel = nil;
    self.temporaryTargetForDraggedIndexPath = nil;

    [self.tableView beginUpdates];

    if(indexPathSource){
        [self.tableView insertRowsAtIndexPaths:@[indexPathSource] withRowAnimation:UITableViewRowAnimationFade];
    }

    if(indexPathTarget){
        [self.tableView deleteRowsAtIndexPaths:@[indexPathTarget] withRowAnimation:UITableViewRowAnimationFade];
    }

    [self.tableView endUpdates];

    if(!indexPathSource && !indexPathTarget){
        [self.tableView reloadData];
    }

    [self.dragAndDropHandler stopDragging];

    [self enableTableGestureRecognizerForScrolling];
}

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

- (void)userHasDroppedItem {
    NSIndexPath *indexPathSource = [self indexPathForDraggedItem];
    NSIndexPath *indexPathTarget = self.temporaryTargetForDraggedIndexPath;

    self.draggedItemModel = nil;
    self.temporaryTargetForDraggedIndexPath = nil;

    if(indexPathTarget){
        [self changeOrderForTaskFromIndexPath:indexPathSource toIndexPath:indexPathTarget];
    } else if(indexPathSource){
        [self.tableView insertRowsAtIndexPaths:@[indexPathSource] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }

    [self.dragAndDropHandler stopDragging];
    [self enableTableGestureRecognizerForScrolling];
}


- (NSIndexPath *)getPath:(CGPoint)point globalPoint:(CGPoint)globalPoint noCell:(BOOL *)noCellFound {
    NSIndexPath * result = nil;

    NSIndexPath *indexPathUnderTheFinger = [self.tableView indexPathForRowAtPoint:point];
    //STMTask * task = [self.fetchedResultsController objectAtIndexPath:indexPathUnderTheFinger];
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
            NSIndexPath *currentDraggedIndexPath = [self indexPathForDraggedItem];
            if([currentDraggedIndexPath isEqual:result]){
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



-(void) emergencyCancelDragging{
    self.draggedItemModel = nil;
    self.temporaryTargetForDraggedIndexPath = nil;

    [self.dragAndDropHandler stopDragging];

    [self enableTableGestureRecognizerForScrolling];

    [MessagesHelper showMessage:@"Task was changed by someone else ..."];
}

- (NSIndexPath *)indexPathForDraggedItem {
    if(!self.draggedItemModel){
        return nil;
    }

    return [self.dataSource indexPathForTaskModel:self.draggedItemModel];
}

- (void)changeOrderForTaskFromIndexPath:(NSIndexPath *)sourcePath toIndexPath:(NSIndexPath *)targetPath {
    STMTask *task = [self.dataSource taskForIndexPath:sourcePath];

    int change = sourcePath.row - targetPath.row;
    int theNewOrder = [task.index intValue] + change;

    if(task){
        [[SyncGuardService singleUser] reorderTaskWithId:task.uid toIndex:theNewOrder successFullBlock:^(id o) {

        } failureBlock:^(NSError *error) {
            runOnMainThread(^{
                [self.tableView reloadData];
            });
        }];
    }
}

@end