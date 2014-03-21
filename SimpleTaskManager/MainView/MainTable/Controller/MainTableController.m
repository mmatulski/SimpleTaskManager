//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController.h"
#import "STMTask.h"
#import "DragAndDropHandler.h"
#import "MainTableController+SelectedItem.h"
#import "MainTableController+DragAndDrop.h"
#import "STMTaskModel.h"
#import "MainTableDataSource.h"

@implementation MainTableController {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.draggedItemModel = nil;
        self.tableView = tableView;

        self.dataSource = [[MainTableDataSource alloc] initWithTableView:self.tableView];
        self.tableView.delegate = self;

        [self addLongPressRecognizer];
    }

    return self;
}

- (DragAndDropHandler *)dragAndDropHandler {
    if(!_dragAndDropHandler){
        [self prepareDragAndDropHelper];
    }

    return _dragAndDropHandler;
}


- (void)prepareDragAndDropHelper {
    self.dragAndDropHandler = [[DragAndDropHandler alloc] initWithDraggingSpace:[self.delegate viewForTemporaryViewsPresentation]];
}

- (void)setSelectedItemModel:(STMTaskModel *)selectedItemModel {

    if(![_selectedItemModel.objectId isEqual:selectedItemModel.objectId]){
        if(selectedItemModel){
            NSIndexPath *indexPath = [self.dataSource indexPathForTaskModel:selectedItemModel];
            [self showOptionsForItemAtIndexPath:indexPath taskModel:selectedItemModel];
        }

        if(_selectedItemModel && !selectedItemModel){
            NSIndexPath *selectedIndexPath = [self.dataSource indexPathForTaskModel:_selectedItemModel];
            [self hideOptionsForItemAtIndexPath:selectedIndexPath taskModel:_selectedItemModel];
        }

        self.scrollOffsetWhenItemWasSelected = self.tableView.contentOffset.y;

        _selectedItemModel = selectedItemModel;
    }
}


- (void)handleMemoryWarning {
    //TODO clean fetched cache
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return nil;
}


- (void)addLongPressRecognizer {
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressRecognizer.minimumPressDuration = 0.8; //seconds
    self.longPressRecognizer.delegate = self;

    [self.tableView addGestureRecognizer:self.longPressRecognizer];
}

#pragma mark UILongPressGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}


- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView: gestureRecognizer.view];
    CGPoint pointRelatedToWindow = [gestureRecognizer locationInView:nil];

    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){

        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        [self userHasPressedLongOnIndexPath:indexPath andWindowPoint:pointRelatedToWindow];

    } else if(gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled){

        if(self.draggedItemModel){
            [self cancelDragging];
        }

    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        if(self.draggedItemModel){

            [self.dragAndDropHandler moveDraggedViewToPoint:pointRelatedToWindow];
            [self dropOrHideDraggedCellForPoint:point globalPoint:pointRelatedToWindow];
        }

    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        if(self.draggedItemModel){

           [self userHasDroppedItem];
        }
    }
}






- (void)enableTableGestureRecognizerForScrolling {
   [self.tableView panGestureRecognizer].enabled = true;
}

- (void)disableTableGestureRecognizerForScrolling {
   [self.tableView panGestureRecognizer].enabled = false;
}

- (void)deselectTaskModel:(STMTaskModel *)taskModel {
    NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
    if(selectedIndexPath){
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
    }

    self.selectedItemModel = nil;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
    if(selectedIndexPath && [selectedIndexPath isEqual:indexPath]){
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        self.selectedItemModel = nil;
    } else {
        STMTask *task = [self.dataSource taskForIndexPath:indexPath];
        if(task){
            STMTaskModel *model = [[STMTaskModel alloc] initWitEntity:task];
            self.selectedItemModel = model;
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.selectedItemModel){
        NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
        [self updateOptionsPositionForItemAtIndexPath:selectedIndexPath taskModel:self.selectedItemModel];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}






@end