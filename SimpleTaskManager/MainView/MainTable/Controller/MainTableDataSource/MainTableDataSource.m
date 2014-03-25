//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableDataSource.h"
#import "DBController.h"
#import "STMTaskModel.h"
#import "STMTask.h"
#import "DBController+BasicActions.h"
#import "MainTableConsts.h"
#import "DBAccess.h"
#import "TaskTableViewCell.h"

NSUInteger const kDefaultBatchSize = 20;

@implementation MainTableDataSource {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;

        [self.tableView registerClass:[TaskTableViewCell class] forCellReuseIdentifier:kCellIdentifier];

        [self prepareDBController];
        [self prepareFetchedResultsController];

        self.tableView.dataSource = self;
    }

    return self;
}

- (void)prepareDBController {
    self.dbController = [[DBAccess sharedInstance] controllerOnMainQueue];
}

- (void)prepareFetchedResultsController {

    NSFetchRequest *fetchRequest = [self.dbController createFetchingTasksRequestWithBatchSize:kDefaultBatchSize];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.dbController.context sectionNameKeyPath:nil
                                                                                   cacheName:kFetchedResultsControllerCacheName];
    self.fetchedResultsController.delegate = self;

    [self reloadDataSourceAndTable];
}

- (void) reloadDataSourceAndTable {
    NSError *err = nil;
    if(![self.fetchedResultsController performFetch:&err]){
        DDLogError(@"prepareFetchedResultsController performFetch failed %@", [err localizedDescription]);
    }

    [self.tableView reloadData];
}

- (void)setPaused:(BOOL)paused {

    if(_paused != paused){
        _paused = paused;

        if (paused) {
            self.fetchedResultsController.delegate = nil;
//            [NSFetchedResultsController deleteCacheWithName:kFetchedResultsControllerCacheName];
        } else {
            self.fetchedResultsController.delegate = self;
            [self reloadDataSourceAndTable];
            //TODO updatuj selecteditem, draggeditem, droppeditem
        }
    }
}

#pragma mark - IndexPath

/*
    Returns indexpath in tableview for taskmodel even if task is already removed from db but still shown in tableview.
 */
-(NSIndexPath *) indexPathForTaskModel:(STMTaskModel *) model{

    //fetchedResultsController shows number od cells which can be not the same as in DB
    STMTask *task = [self taskFromDBForModel:model];
    if (task) {
        NSIndexPath *result = [self.fetchedResultsController indexPathForObject:task];
        return result;
    }

    return nil;
}

-(NSIndexPath *) indexPathOnlyForExistingInDBTaskModel:(STMTaskModel *) model{
    STMTask *task = [self existingTaskFromDBForModel:model];
    if(task){
        return [self.fetchedResultsController indexPathForObject:task];
    }

    return nil;
}

#pragma mark - Checking if exists

-(BOOL) doesTaskStillExistInDB:(STMTask *) task{
    return [self existingTaskForObjectId:task.objectID] != nil;
}

-(BOOL) doesTaskForModelStillExistInFetchedResultsControllerData:(STMTaskModel *)model{
        return [self indexPathForTaskModel:model] != nil;
}

#pragma mark - Finding task

- (STMTask *)taskForIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (STMTask *) existingTaskFromDBForModel:(STMTaskModel *)model {
    return [self existingTaskForObjectId:model.objectId];
}

- (STMTask *)existingTaskForObjectId:(NSManagedObjectID *) objectID {
    STMTask* task = [self.dbController existingTaskWithObjectID:objectID];
    return task;
}

/*
    Task can not exist - be careful
 */
- (STMTask *)taskFromDBForModel:(STMTaskModel *)model {
    STMTask* task = [self.dbController taskWithObjectID:model.objectId];
    return task;
}

#pragma mark -

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path {

    DDLogTrace(@"configureCell %zd '%@' %zd", [path row], self.modelForTaskBeingMoved.name, [self.currentTargetIndexPathForItemBeingMoved row]);

    NSIndexPath *pathToRequest = path;

    BOOL thisCellShowsMovedItem = false;

    STMTask * task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];

    if(self.modelForTaskBeingMoved){
        NSIndexPath *originalIndexPathOfMovedModel = [self indexPathForTaskModel:self.modelForTaskBeingMoved];

        if([originalIndexPathOfMovedModel row] >= [path row]){
            pathToRequest = [NSIndexPath indexPathForRow:(path.row + 1) inSection:path.section];
        }

        if(self.currentTargetIndexPathForItemBeingMoved){
            if([self.currentTargetIndexPathForItemBeingMoved row] < [path row]){
                pathToRequest = [NSIndexPath indexPathForRow:(path.row - 1) inSection:path.section];
            }

            if ([path isEqual:self.currentTargetIndexPathForItemBeingMoved]) {
                thisCellShowsMovedItem = true;
                task = [self existingTaskFromDBForModel:self.modelForTaskBeingMoved];
                //TODO just change pathToRequest
            }
        }
    }

    if(!thisCellShowsMovedItem){
        task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];
    }

    if(task){
        if([self doesTaskStillExistInDB:task]){
            cell.textLabel.text = [NSString stringWithFormat:@"[%d] %@", [[task index] intValue] , task.name];
        } else {
            DDLogWarn(@"Showing task which is no longer in DB");
            cell.textLabel.text = @"Task completed";
        }
    }

    TaskTableViewCell *taskCell = MakeSafeCast(cell, [TaskTableViewCell class]);
    taskCell.dropped = thisCellShowsMovedItem;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * sections = [_fetchedResultsController sections];
    if(sections && [sections count] > section){
        id  sectionInfo = [sections objectAtIndex:(NSUInteger) section];
        NSInteger result = [sectionInfo numberOfObjects];
        if(self.modelForTaskBeingMoved && !self.currentTargetIndexPathForItemBeingMoved){
            result--;
        }

        DDLogInfo(@"numberOfRowsInSection %zd [%td]", result, self.dbController.numberOfAllTasks);

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
//    DDLogTrace(@"didChangeObject %@ %@ %d", changedTask.objectID, changedTask.name, [changedTask.index intValue]);
//    if(self.draggedItemModel){
//        if([changedTask.objectID isEqual:self.draggedItemModel.objectId]){
//            if(type == NSFetchedResultsChangeDelete){
//                DDLogInfo(@"========= DRAGGED ITEM DELETED %@", self.draggedItemModel.name);
//                self.shouldCancelDragging = true;
//
//            } else {
//                DDLogInfo(@"========= DRAGGED ITEM CHANGED %@", self.draggedItemModel.name);
//            }
//        }
//    }

    NSString *stringType = @"";
    switch (type){

        case NSFetchedResultsChangeInsert: stringType = @"INSERT";break;
        case NSFetchedResultsChangeDelete:stringType = @"DELETE";break;
        case NSFetchedResultsChangeMove:stringType = @"MOVE";break;
        case NSFetchedResultsChangeUpdate:stringType = @"UPDATE";break;
    }

    DDLogInfo(@"didChangeObject %@ %@ %@ %td", stringType, changedTask.objectID, changedTask.name, [changedTask.index unsignedIntegerValue]);


//    if(self.selectedItemModel && !self.selectedItemWillBeRemoved){
//        if([changedTask.objectID isEqual:self.selectedItemModel.objectId]){
//            if(type == NSFetchedResultsChangeDelete){
//                DDLogInfo(@"========= SELECTED ITEM DELETED %@", self.selectedItemModel.name);
//                if(!self.selectedItemModel.completedByUser){
//                    self.shouldCancelSelection = true;
//                }
//            } else {
//                DDLogInfo(@"========= SELECTED ITEM CHANGED %@", self.selectedItemModel.name);
//            }
//        }
//    }

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
    DDLogInfo(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    DDLogInfo(@"controllerDidChangeContent");

//    if(self.shouldCancelDragging){
//        [self emergencyCancelDragging];
//        self.shouldCancelDragging = false;
//    }
//
//    if(self.shouldCancelSelection){
//        [self emergencyCancelSelection];
//        self.shouldCancelSelection = false;
//    } else {
//        [self updateSelectedItemVisibility];
//    }
}

- (void)cellForTaskModel:(STMTaskModel *)draggedModel hasBeenDraggedFromIndexPath:(NSIndexPath *)indexPath animateHiding:(bool)animated {
    self.modelForTaskBeingMoved = draggedModel;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animated ? UITableViewRowAnimationMiddle : UITableViewRowAnimationNone];
}

- (void)draggedCellHasBeenMovedToIndexPath:(NSIndexPath *)indexPath animateShowing:(bool)animated {

    [self.tableView beginUpdates];

    if(self.currentTargetIndexPathForItemBeingMoved){
        [self.tableView deleteRowsAtIndexPaths:@[self.currentTargetIndexPathForItemBeingMoved] withRowAnimation:animated ? UITableViewRowAnimationMiddle : UITableViewRowAnimationNone];
    }

    self.currentTargetIndexPathForItemBeingMoved = indexPath;

    if(self.currentTargetIndexPathForItemBeingMoved){
        [self.tableView insertRowsAtIndexPaths:@[self.currentTargetIndexPathForItemBeingMoved]  withRowAnimation:animated ? UITableViewRowAnimationMiddle : UITableViewRowAnimationNone];
    }

    [self.tableView endUpdates];

    if(self.currentTargetIndexPathForItemBeingMoved){
        [self.tableView scrollToRowAtIndexPath:self.currentTargetIndexPathForItemBeingMoved atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
    }

}

- (void)draggedCellHasBeenReturned:(BOOL) animateShowingItAgain {
    if(self.modelForTaskBeingMoved){
        NSIndexPath *indexPath = [self indexPathForTaskModel:self.modelForTaskBeingMoved];

        self.modelForTaskBeingMoved = nil;
        self.currentTargetIndexPathForItemBeingMoved = nil;

        if(indexPath){
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation: animateShowingItAgain ? UITableViewRowAnimationMiddle : UITableViewRowAnimationNone];
        } else {
            [self.tableView reloadData];
        }
    }

    self.modelForTaskBeingMoved = nil;
    self.currentTargetIndexPathForItemBeingMoved = nil;
}

- (NSUInteger)estimatedTaskIndexForTargetIndexPath:(NSIndexPath *)indexPath {
    NSUInteger numberOfAllTasks = self.dbController.numberOfAllTasks;
    if([indexPath row] == 0){
        DDLogInfo(@"estimatedTaskIndexForTargetIndexPath R %td", numberOfAllTasks);
        return numberOfAllTasks;
    }

    NSInteger result = numberOfAllTasks - [indexPath row];
    if(result < 1){
        DDLogInfo(@"estimatedTaskIndexForTargetIndexPath B 1");

        return 1;
    }

    DDLogInfo(@"estimatedTaskIndexForTargetIndexPath %zd", result);

    return (NSUInteger) result;
}

- (void)resetDraggedCell {
    self.modelForTaskBeingMoved = nil;
    self.currentTargetIndexPathForItemBeingMoved = nil;
}

- (NSUInteger)numberOfAllTasksInDB {
    //we should be careful here because tableview can have shown less items
    return self.dbController.numberOfAllTasks;
}

- (NSUInteger) numberOfAllTasksInFetchedResultsController {
    NSArray * sections = [_fetchedResultsController sections];
    if([sections count] > 0){
        id  sectionInfo = [sections firstObject];
        return [sectionInfo numberOfObjects];
    }

    return 0;
}

- (void)taskCompleted {
    [self reloadDataSourceAndTableIfPaused];
}

- (void)reloadDataSourceAndTableIfPaused {
    if(self.paused){
        [self reloadDataSourceAndTable];
    }
}

@end