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

    /*STMTask *task = [self.dataSource taskForIndexPath:indexPath];
    if(task){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        self.stateController.dragging = true;

        self.draggedItemModel = [[STMTaskModel alloc] initWitEntity:task];

        [self disableTableGestureRecognizerForScrolling];

        [self.dragAndDropHandler dragView:cell fromPoint:pointRelatedToWindow];

        [self.dataSource cellForTaskModel:self.draggedItemModel hasBeenDraggedFromIndexPath:indexPath animateHiding:true];
    } else {
        [self.tableView reloadData];
    }*/
}

- (void)userWantsToMoveDraggingItemToLocalViewPoint:(CGPoint)point andRelatedToWindowPoint:(CGPoint)pointRelatedToWindow {
    [self.dragAndDropHandler moveDraggedViewToPoint:pointRelatedToWindow];
    [self dropOrHideDraggedCellForPoint:point globalPoint:pointRelatedToWindow];
}

- (void)userHasDroppedItem {
//    if(self.temporaryTargetForDraggedIndexPath){
//        [self.dataSource resetDraggedCell];
//        [self changeOrderForDraggedItemToIndexPath:self.temporaryTargetForDraggedIndexPath];
//    } else {
//        [self.dataSource draggedCellHasBeenReturned:true];
//    }
//
//    self.draggedItemModel = nil;
//    self.temporaryTargetForDraggedIndexPath = nil;
//
//    [self.dragAndDropHandler stopDragging];
//    [self enableTableGestureRecognizerForScrolling];
//
//    self.stateController.dragging = false;
}

- (void)draggingHasBeenFailedOrCancelled {
    [self cancelDraggingAnimate:true];
}

#pragma mark -

- (void)dropOrHideDraggedCellForPoint:(CGPoint)point globalPoint:(CGPoint)globalPoint {

    BOOL noCellFound = false;
    NSIndexPath *suggestedIndexPath = [self getPath:point globalPoint:globalPoint noCell:&noCellFound];
    DDLogTrace(@"suggestedIndexPath %zd", [suggestedIndexPath row]);
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

        NSInteger row = [indexPathUnderTheFinger row];

        if(show){

            NSInteger finalRow = showOnBottom ? row + 1 : row;
            if(finalRow >= [self.dataSource numberOfAllTasksInFetchedResultsController]){
                return nil;
            }

            result = [NSIndexPath indexPathForRow:finalRow inSection:0];
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

- (void)cancelDraggingAnimate:(BOOL) animate {
//    NSIndexPath *indexPathSource = [self indexPathForDraggedItem];
//    NSIndexPath *indexPathTarget = self.temporaryTargetForDraggedIndexPath;
//
//    self.draggedItemModel = nil;
//    self.temporaryTargetForDraggedIndexPath = nil;
//
//    [self.tableView beginUpdates];
//
//    if(indexPathSource){
//        [self.tableView insertRowsAtIndexPaths:@[indexPathSource] withRowAnimation:animate ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
//    }
//
//    if(indexPathTarget){
//        [self.tableView deleteRowsAtIndexPaths:@[indexPathTarget] withRowAnimation:animate ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
//    }
//
//    [self.tableView endUpdates];
//
//    if(!indexPathSource && !indexPathTarget){
//        [self.tableView reloadData];
//    }
//
//    [self.dragAndDropHandler stopDragging];
//
//    [self enableTableGestureRecognizerForScrolling];
//
//    self.stateController.dragging = false;
}

//-(void) emergencyCancelDragging{
//    self.draggedItemModel = nil;
//    self.temporaryTargetForDraggedIndexPath = nil;
//
//    [self.dragAndDropHandler stopDragging];
//
//    [self enableTableGestureRecognizerForScrolling];
//
//    [MessagesHelper showMessage:@"Task was changed by someone else ..."];
//}

- (NSIndexPath *)indexPathForDraggedItem {
    if(!self.draggedItemModel){
        return nil;
    }

    return [self.dataSource indexPathForTaskModel:self.draggedItemModel];
}

- (void)changeOrderForDraggedItemToIndexPath:(NSIndexPath *)targetPath {
    NSUInteger theNewOrder = [self.dataSource estimatedTaskIndexForTargetIndexPath:targetPath];
    if(self.draggedItemModel){
        STMTaskModel *taskModel = self.draggedItemModel;
        BlockWeakSelf selfWeak = self;
        [[SyncGuardService singleUser] reorderTaskWithId:taskModel.uid toIndex:theNewOrder successFullBlock:^(id obj) {
            runOnMainThread(^{
                [self.tableView reloadData];
                [selfWeak highlightCellForTaskModel:taskModel];
            });
        } failureBlock:^(NSError *error) {
            runOnMainThread(^{
                [self.tableView reloadData];
                [selfWeak highlightCellForTaskModel:taskModel];
            });
        }];
    }
}

-(void) highlightCellForTaskModel:(STMTaskModel *) model{
    NSIndexPath *indexPath = [self.dataSource indexPathForTaskModel:model];
    if(indexPath){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        TaskTableViewCell *taskCell = MakeSafeCast(cell, [TaskTableViewCell class]);
        [taskCell blinkCell];
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