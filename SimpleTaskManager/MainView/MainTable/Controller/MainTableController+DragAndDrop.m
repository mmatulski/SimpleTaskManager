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

- (void)addLongPressRecognizer {
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressRecognizer.minimumPressDuration = 0.8;
    self.longPressRecognizer.delegate = self;

    [self.tableView addGestureRecognizer:self.longPressRecognizer];
}

- (BOOL)isDraggingAnyItem {
    return self.draggedItemModel != nil;
}

- (void)enableTableGestureRecognizerForScrolling {
    [self.tableView panGestureRecognizer].enabled = true;
}

- (void)disableTableGestureRecognizerForScrolling {
    [self.tableView panGestureRecognizer].enabled = false;
}

#pragma mark - Long Press handling

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView: gestureRecognizer.view];
    CGPoint pointRelatedToWindow = [gestureRecognizer locationInView:nil];

    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){

        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        [self userHasPressedLongOnIndexPath:indexPath andWindowPoint:pointRelatedToWindow];

    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){

        if([self isDraggingAnyItem]){
            [self userWantsToMoveDraggingItemToLocalViewPoint:point andRelatedToWindowPoint:pointRelatedToWindow];
        }

    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){

        if([self isDraggingAnyItem]){
            [self userHasDroppedItem];
        }
    } else if(gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled){

        if([self isDraggingAnyItem]){
            [self draggingHasBeenFailedOrCancelled];
        }

    }
}

#pragma mark - Proper Actions

- (void)userHasPressedLongOnIndexPath:(NSIndexPath *)indexPath andWindowPoint:(CGPoint)pointRelatedToWindow {
    STMTask *task = [self.dataSource taskForIndexPath:indexPath];

    if(task){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        self.draggedItemModel = [[STMTaskModel alloc] initWitEntity:task];

        [self disableTableGestureRecognizerForScrolling];

        [self.dragAndDropHandler dragView:cell fromPoint:pointRelatedToWindow];

        [self.dataSource cellForTaskModel:self.draggedItemModel hasBeenDraggedFromIndexPath:indexPath animateHiding:true];
    } else {
        [self.tableView reloadData];
    }
}

- (void)userWantsToMoveDraggingItemToLocalViewPoint:(CGPoint)point andRelatedToWindowPoint:(CGPoint)pointRelatedToWindow {
    [self.dragAndDropHandler moveDraggedViewToPoint:pointRelatedToWindow];
    [self dropOrHideDraggedCellForPoint:point globalPoint:pointRelatedToWindow];
}

- (void)userHasDroppedItem {
    if(self.temporaryTargetForDraggedIndexPath){
        [self.dataSource resetDraggedCell];
        [self changeOrderForDraggedItemToIndexPath:self.temporaryTargetForDraggedIndexPath];
    } else {
        [self.dataSource draggedCellHasBeenReturned:true];
    }

    self.draggedItemModel = nil;
    self.temporaryTargetForDraggedIndexPath = nil;

    [self.dragAndDropHandler stopDragging];
    [self enableTableGestureRecognizerForScrolling];
}

- (void)draggingHasBeenFailedOrCancelled {
    [self cancelDragging];
}

#pragma mark -

- (void)dropOrHideDraggedCellForPoint:(CGPoint)point globalPoint:(CGPoint)globalPoint {

    BOOL noCellFound = false;
    NSIndexPath *suggestedIndexPath = [self getPath:point globalPoint:globalPoint noCell:&noCellFound];
    DDLogTrace(@"suggestedIndexPath %d", [suggestedIndexPath row]);
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
    self.temporaryTargetForDraggedIndexPath = indexPath;
    [self.dataSource draggedCellHasBeenMovedToIndexPath:indexPath animateShowing:true];
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

- (void)changeOrderForDraggedItemToIndexPath:(NSIndexPath *)targetPath {
    NSUInteger theNewOrder = [self.dataSource estimatedTaskIndexForTargetIndexPath:targetPath];
    if(self.draggedItemModel){
        [[SyncGuardService singleUser] reorderTaskWithId:self.draggedItemModel.uid toIndex:theNewOrder successFullBlock:^(id o) {

        } failureBlock:^(NSError *error) {
            runOnMainThread(^{
                [self.tableView reloadData];
            });
        }];
    }
}

#pragma mark UILongPressGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}


@end