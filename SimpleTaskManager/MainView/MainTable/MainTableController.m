//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController.h"
#import "DBController.h"
#import "DBAccess.h"
#import "STMTask.h"
#import "DragAndDropHandler.h"
#import "MainTableController+SelectedItem.h"
#import "MainTableController+DragAndDrop.h"
#import "TaskTableViewCell.h"
#import "STMTaskModel.h"

NSString * const kCellIdentifier = @"CellIdentifier";
unsigned int const kDefaultBatchSize = 20;

@implementation MainTableController {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.draggedItemModel = nil;
        self.tableView = tableView;

        [self prepareDBController];
        [self prepareFetchedResultsController];

        [self.tableView registerClass:[TaskTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        self.tableView.dataSource = self;
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

- (void)prepareDBController {
    self.dbController = [[DBAccess sharedInstance] controllerOnMainQueue];
}

- (void)prepareFetchedResultsController {

    NSFetchRequest *fetchRequest = [self.dbController createFetchingTasksRequestWithBatchSize:kDefaultBatchSize];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.dbController.context sectionNameKeyPath:nil
                                                                                   cacheName:@"Root"];
    self.fetchedResultsController.delegate = self;

    NSError *err = nil;
    if(![self.fetchedResultsController performFetch:&err]){
        DDLogError(@"prepareFetchedResultsController performFetch failed %@", [err localizedDescription]);
    }
}

- (void)prepareDragAndDropHelper {
    self.dragAndDropHandler = [[DragAndDropHandler alloc] initWithDraggingSpace:[self.delegate viewForTemporaryViewsPresentation]];
}

- (void)setSelectedItemModel:(STMTaskModel *)selectedItemModel {

    if(![_selectedItemModel.objectId isEqual:selectedItemModel.objectId]){
        if(selectedItemModel){
            NSIndexPath *indexPath = [self indexPathForTaskModel:selectedItemModel];
            [self showOptionsForItemAtIndexPath:indexPath taskModel:selectedItemModel];
        }

        if(_selectedItemModel && !selectedItemModel){
            NSIndexPath *selectedIndexPath = [self indexPathForTaskModel:_selectedItemModel];
            [self hideOptionsForItemAtIndexPath:selectedIndexPath taskModel:_selectedItemModel];
        }

        self.scrollOffsetWhenItemWasSelected = self.tableView.contentOffset.y;

        _selectedItemModel = selectedItemModel;
    }
}


- (void)handleMemoryWarning {
    //TODO clean fetched cache
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path {

    NSIndexPath *pathToRequest = path;

    STMTask * task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];
    if(self.draggedItemModel){

        if([self.draggedItemModel.uid isEqualToString:task.uid]){
            pathToRequest = [NSIndexPath indexPathForRow:(path.row + 1) inSection:path.section];
            task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];
        }

        if(self.temporaryTargetForDraggedIndexPath && [path isEqual:self.temporaryTargetForDraggedIndexPath]){
            task = [self taskForIndexPath:self.temporaryTargetForDraggedIndexPath];
        }
    }

    if(task){
        cell.textLabel.text = [NSString stringWithFormat:@"[%d] %@", [[task index] intValue] , task.name];
        if(self.temporaryTargetForDraggedIndexPath){
            if([self.temporaryTargetForDraggedIndexPath isEqual:path]){
                TaskTableViewCell *taskCell = MakeSafeCast(cell, [TaskTableViewCell class]);
                taskCell.dropped = true;
            }
        }
    }
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
        STMTask *task = [self taskForIndexPath:indexPath];
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * sections = [_fetchedResultsController sections];
    if(sections && [sections count] > section){
        id  sectionInfo = [sections objectAtIndex:(NSUInteger) section];
        int result = [sectionInfo numberOfObjects];
        if(self.draggedItemModel && !self.temporaryTargetForDraggedIndexPath){
            result--;
        }

        return result;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    STMTask *changedTask = MakeSafeCast(anObject, [STMTask class]);
    DDLogTrace(@"didChangeObject %@ %@ %d", changedTask.objectID, changedTask.name, [changedTask.index intValue]);
    if(self.draggedItemModel){
        if([changedTask.objectID isEqual:self.draggedItemModel.objectId]){
            if(type == NSFetchedResultsChangeDelete){
               DDLogInfo(@"========= DRAGGED ITEM DELETED %@", self.draggedItemModel.name);
                self.shouldCancelDragging = true;

            } else {
                DDLogInfo(@"========= DRAGGED ITEM CHANGED %@", self.draggedItemModel.name);
            }
        }
    }

    if(self.selectedItemModel && !self.selectedItemWillBeRemoved){
        if([changedTask.objectID isEqual:self.selectedItemModel.objectId]){
            if(type == NSFetchedResultsChangeDelete){
                DDLogInfo(@"========= SELECTED ITEM DELETED %@", self.selectedItemModel.name);
                if(!self.selectedItemModel.completed){
                    self.shouldCancelSelection = true;
                }
            } else {
                DDLogInfo(@"========= SELECTED ITEM CHANGED %@", self.selectedItemModel.name);
            }
        }
    }

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                    arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                    arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }


}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:break;
        case NSFetchedResultsChangeUpdate:break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];

    if(self.shouldCancelDragging){
        [self emergencyCancelDragging];
        self.shouldCancelDragging = false;
    }

    if(self.shouldCancelSelection){
        [self emergencyCancelSelection];
        self.shouldCancelSelection = false;
    } else {
        [self updateSelectedItemVisibility];
    }
}

-(NSIndexPath *) indexPathForTaskModel:(STMTaskModel *) model{
    STMTask *task = [self taskForModel:model];
    if(task){
        return [self.fetchedResultsController indexPathForObject:task];
    }

    return nil;
}

- (STMTask *)taskForModel:(STMTaskModel *)model {
    STMTask* task = [self.dbController taskWithObjectID:model.objectId];
    return task;
}

@end