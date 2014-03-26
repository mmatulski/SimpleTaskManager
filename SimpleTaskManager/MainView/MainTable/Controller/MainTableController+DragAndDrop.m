//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+DragAndDrop.h"
#import "STMTask.h"
#import "DragAndDropHandler.h"
#import "STMTaskModel.h"
#import "SyncGuardService.h"
#import "LocalUserLeg.h"
#import "MainTableDataSource.h"
#import "TaskTableViewCell.h"
#import "MainViewConsts.h"
#import "AppMessages.h"

@implementation MainTableController (DragAndDrop)

- (void)addLongPressRecognizer {
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressRecognizer.minimumPressDuration = kLongPressReactionTimeForDragAndDrop;
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
        if(indexPath){
            [self userHasPressedLongOnIndexPath:indexPath andWindowPoint:pointRelatedToWindow];
        }
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
        [self disableTableGestureRecognizerForScrolling];

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        self.draggedItemModel = [[STMTaskModel alloc] initWitTask:task];
        [self.dragAndDropHandler dragView:cell fromPoint:pointRelatedToWindow];

        [self.dataSource cellForTaskModel:self.draggedItemModel hasBeenDraggedFromIndexPath:indexPath animateHiding:true];
        [self.delegate taskHasBeenDragged];
    } else {
        DDLogWarn(@"Task at index path not found %d", [indexPath row]);
        [self.tableView reloadData];
    }
}

- (void)userWantsToMoveDraggingItemToLocalViewPoint:(CGPoint)point andRelatedToWindowPoint:(CGPoint)pointRelatedToWindow {
    [self.dragAndDropHandler moveDraggedViewToPoint:pointRelatedToWindow];
    [self dropOrHideDraggedCellForPoint:point globalPoint:pointRelatedToWindow];
}

- (void)userHasDroppedItem {
    if(self.lastTargetForDraggedIndexPath){
        [self.dataSource resetDraggedCell];
        [self changeOrderForDraggedItemToIndexPath:self.lastTargetForDraggedIndexPath];
    } else {
        [self.dataSource draggedCellHasBeenReturned:true];
    }

    self.draggedItemModel = nil;
    self.lastTargetForDraggedIndexPath = nil;

    [self.dragAndDropHandler stopDragging];
    [self enableTableGestureRecognizerForScrolling];

    [self.delegate taskHasBeenDropped];
}

- (void)draggingHasBeenFailedOrCancelled {
    [self cancelDraggingAnimate:true];
}

#pragma mark -

- (void)dropOrHideDraggedCellForPoint:(CGPoint)point globalPoint:(CGPoint)globalPoint {

    BOOL noCellFound = false;
    NSIndexPath *suggestedIndexPath = [self suggestIndexPathForDraggedCellAtPoint:point globalPoint:globalPoint noCell:&noCellFound];
    DDLogTrace(@"suggestedIndexPath %zd", [suggestedIndexPath row]);
   if(self.lastTargetForDraggedIndexPath){
        if(suggestedIndexPath){
            if(![self.lastTargetForDraggedIndexPath isEqual:suggestedIndexPath]){
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
    self.lastTargetForDraggedIndexPath = indexPath;
    [self.dataSource draggedCellHasBeenMovedToIndexPath:indexPath animateShowing:true];
}

- (NSIndexPath *)suggestIndexPathForDraggedCellAtPoint:(CGPoint)point globalPoint:(CGPoint)globalPoint noCell:(BOOL *)noCellFound {
    NSIndexPath * result = nil;

    NSIndexPath *indexPathForThePoint = [self.tableView indexPathForRowAtPoint:point];
    UITableViewCell *cellForCurrentPoint = [self.tableView cellForRowAtIndexPath:indexPathForThePoint];

    if(self.lastTargetForDraggedIndexPath){
        if([self.lastTargetForDraggedIndexPath isEqual:indexPathForThePoint]){
            return self.lastTargetForDraggedIndexPath;
        }
    }

    CGPoint currentPointForCellCoordinates = [cellForCurrentPoint convertPoint:globalPoint fromView:nil];
    CGRect cellBounds = cellForCurrentPoint.bounds;
    if(cellBounds.size.height != 0){
        CGFloat cellFactor = currentPointForCellCoordinates.y / cellBounds.size.height;

        NSInteger row = [indexPathForThePoint row];
        BOOL showAtBottom = cellFactor > 0.5;
        NSInteger finalRow = showAtBottom ? row + 1 : row;

        if (finalRow >= [self.dataSource numberOfAllTasksInFetchedResultsController]) {
            return nil;
        }

        result = [NSIndexPath indexPathForRow:finalRow inSection:0];
        NSIndexPath *currentDraggedIndexPath = [self indexPathForDraggedItem];
        if ([currentDraggedIndexPath isEqual:result]) {
            result = nil;
        }


    } else {
        if(noCellFound){
            *noCellFound = true;
        }
    }

    return result;
}

- (void)cancelDraggingAnimate:(BOOL) animate {
    self.draggedItemModel = nil;
    self.lastTargetForDraggedIndexPath = nil;

    [self.dataSource draggedCellHasBeenReturned:animate];

    [self.dragAndDropHandler stopDragging];

    [self enableTableGestureRecognizerForScrolling];

    [self.delegate taskDraggingCancelled];
}

- (NSIndexPath *)indexPathForDraggedItem {
    if(!self.draggedItemModel){
        return nil;
    }

    return [self.dataSource indexPathForTaskModel:self.draggedItemModel];
}

- (BOOL)isDraggedModelStillAvailable {
    return [self.dataSource doesTaskForModelStillExistInFetchedResultsControllerData:self.draggedItemModel];
}

- (void)changeOrderForDraggedItemToIndexPath:(NSIndexPath *)targetPath {
    NSUInteger theNewOrder = [self.dataSource estimatedTaskIndexForTargetIndexPath:targetPath];
    if(self.draggedItemModel){
        STMTaskModel *taskModel = self.draggedItemModel;
        [AppMessages showActivity];
        BlockWeakSelf selfWeak = self;
        [[SyncGuardService singleUser] reorderTaskWithId:taskModel.uid toIndex:theNewOrder successFullBlock:^(id obj) {
            [AppMessages closeActivity];
            runOnMainThread(^{
                [self.tableView reloadData];
                [selfWeak highlightCellForTaskModel:taskModel];
            });
        } failureBlock:^(NSError *error) {
            [AppMessages closeActivity];
            runOnMainThread(^{
                [self.tableView reloadData];
                [selfWeak highlightCellForTaskModel:taskModel];
            });
        }];
    }
}

- (void)refreshDraggedItemBecauseTableHasBeenReloaded {
    if (![self isDraggedModelStillAvailable]) {
        [self cancelDraggingAnimate:false];
        [AppMessages showError:@"Dragging Task has been closed"];
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