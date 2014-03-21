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
#import "MainTableDataSourceDelegate.h"

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
                                                                                   cacheName:@"Root"];
    self.fetchedResultsController.delegate = self;

    NSError *err = nil;
    if(![self.fetchedResultsController performFetch:&err]){
        DDLogError(@"prepareFetchedResultsController performFetch failed %@", [err localizedDescription]);
    }
}

#pragma mark -

-(NSIndexPath *) indexPathForTaskModel:(STMTaskModel *) model{
    STMTask *task = [self taskForModel:model];
    if(task){
        return [self.fetchedResultsController indexPathForObject:task];
    }

    return nil;
}

- (STMTask *)taskForIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];;
}

- (STMTask *)taskForModel:(STMTaskModel *)model {
    STMTask* task = [self.dbController existingTaskWithObjectID:model.objectId];
    return task;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path {

    NSIndexPath *pathToRequest = path;

    STMTask * task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];


    BOOL thisCellShowsMovedItem = false;

    STMTaskModel *modelForTaskBeingMoved = [self.delegate taskBeingMoved];
    if(modelForTaskBeingMoved){
        if([modelForTaskBeingMoved.uid isEqualToString:task.uid]){
            pathToRequest = [NSIndexPath indexPathForRow:(path.row + 1) inSection:path.section];
            task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];
        }

        NSIndexPath * currentTargetIndexPathForItemBeingMoved = [self.delegate currentTargetIndexPathForItemBeingMoved];

        if(currentTargetIndexPathForItemBeingMoved && [path isEqual:currentTargetIndexPathForItemBeingMoved]){
            thisCellShowsMovedItem = true;
            task = [self taskForIndexPath:currentTargetIndexPathForItemBeingMoved];
        }
    }

    if(task){
        cell.textLabel.text = [NSString stringWithFormat:@"[%d] %@", [[task index] intValue] , task.name];
    }

    TaskTableViewCell *taskCell = MakeSafeCast(cell, [TaskTableViewCell class]);
    taskCell.dropped = thisCellShowsMovedItem;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * sections = [_fetchedResultsController sections];
    if(sections && [sections count] > section){
        id  sectionInfo = [sections objectAtIndex:(NSUInteger) section];
        int result = [sectionInfo numberOfObjects];
        if([self.delegate taskBeingMoved] && ![self.delegate currentTargetIndexPathForItemBeingMoved]){
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

    DDLogInfo(@"didChangeObject %@ %@ %@ %d", stringType, changedTask.objectID, changedTask.name, [changedTask.index integerValue]);


//    if(self.selectedItemModel && !self.selectedItemWillBeRemoved){
//        if([changedTask.objectID isEqual:self.selectedItemModel.objectId]){
//            if(type == NSFetchedResultsChangeDelete){
//                DDLogInfo(@"========= SELECTED ITEM DELETED %@", self.selectedItemModel.name);
//                if(!self.selectedItemModel.completed){
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

@end