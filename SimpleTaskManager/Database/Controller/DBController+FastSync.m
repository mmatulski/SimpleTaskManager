//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController+FastSync.h"
#import "DBController+Undo.h"
#import "STMTaskModel.h"
#import "DBController+Internal.h"
#import "STMTask.h"


@implementation DBController (FastSync)

- (void)fast_sync_AddedTasks:(NSArray *)addedTasks
                     removedTasks:(NSArray *)removedTasks
                     renamedTasks:(NSArray *)renamedTasks
                   reorderedTasks:(NSArray *)reorderedTasks
                 successFullBlock:(void (^)(id))successFullBlock
                     failureBlock:(void (^)(NSError *))failureBlock{

    [self.context performBlock:^{
        [self beginUndo];

        NSError *err = nil;

        DDLogInfo(@"syncAddedTasks (Add %d, Remove %d, Rename %d, Reorder %d",
        [addedTasks count],
        [removedTasks count],
        [renamedTasks count],
        [reorderedTasks count]);

        NSArray * tasksSortedByIndex = [self fetchAllTasksSorted:&err];
        NSMutableArray *tasksSortedByIndexAndMutable = [tasksSortedByIndex mutableCopy];

        NSSortDescriptor *sortByUid = [[NSSortDescriptor alloc]
                initWithKey:@"uid" ascending:NO];

        NSMutableArray *tasksSortedByUid = [[tasksSortedByIndex sortedArrayUsingDescriptors:@[sortByUid]] mutableCopy];
        NSArray *modelsToReorderSortedByUid = [reorderedTasks sortedArrayUsingDescriptors:@[sortByUid]];
        NSArray *modelsToRemoveSortedByUid = [removedTasks sortedArrayUsingDescriptors:@[sortByUid]];
        NSArray *modelsToRenameSortedByUid = [renamedTasks sortedArrayUsingDescriptors:@[sortByUid]];

        [self reorderTasksModels:modelsToReorderSortedByUid inSortedByIndexArray:tasksSortedByIndexAndMutable usingSortedByUIDTasks:tasksSortedByUid];
        [self renameTasksModels:modelsToRenameSortedByUid inSortedByIndexArray:tasksSortedByIndexAndMutable usingSortedByUIDTasks:tasksSortedByUid];
        [self removeTasksModels:modelsToRemoveSortedByUid fromSortedByIndexArray:tasksSortedByIndexAndMutable usingSortedByUIDTasks:tasksSortedByUid];
        [self addTasksModels:addedTasks toSortedByIndexArray:tasksSortedByIndexAndMutable usingSortedByUIDTasks:tasksSortedByUid];
        [self reestimateIndexesInSortedByIndexArray:tasksSortedByIndexAndMutable];

        [self saveWithSuccessFullBlock:^{
            DDLogInfo(@"fast_syncAddedTasks SUCCESS");
            [self endUndo];
            if(successFullBlock){
                successFullBlock(nil);
            }
        } andFailureBlock:^(NSError *error){
            DDLogError(@"fast_syncAddedTasks failed %@", [err localizedDescription] );
            [self undo];
            if(failureBlock){
                failureBlock(error);
            }
        }];
    }];
}

- (void)reorderTasksModels:(NSArray *)models inSortedByIndexArray:(NSMutableArray *)result usingSortedByUIDTasks:(NSArray *)tasks {

    NSMutableArray *modelsStillToReorder = [models mutableCopy];
    NSMutableArray *modelsToProcess = [modelsStillToReorder mutableCopy];

    NSEnumerator *tasksEnumerator = [tasks objectEnumerator];
    NSEnumerator *modelsEnumerator = [modelsToProcess objectEnumerator];

    //------------------ reorder --------------------------------
    STMTask *task = [tasksEnumerator nextObject];
    STMTask *model = [modelsEnumerator nextObject];

    NSInteger numberOfProcessedItems = 0;

    while ([modelsToProcess count] > 0){
        DDLogTrace(@"reordering %d tasks", [modelsToProcess count]);

        while(task){
            DDLogTrace(@"enumerate reorder %@ %@", task.uid, model.uid);
            if([task.uid isEqualToString:model.uid]){
                numberOfProcessedItems++;
                [modelsStillToReorder removeObject:model];

                [result removeObject:task];

                NSUInteger changedIndex = [model.index unsignedIntegerValue];
                NSInteger idxInTable = changedIndex - 1;
                if(idxInTable < 0){
                    DDLogWarn(@"index %d for task %@ not valid (will be added with 1", changedIndex, model.uid);
                    [result insertObject:task atIndex:
                            0];
                } else if(idxInTable >= [result count]){
                    DDLogWarn(@"index %d for task %@ not valid (will be added with top %d", changedIndex, model.uid, ([result count] + 1));
                    [result addObject:task];
                } else {
                    [result insertObject:task atIndex:
                            (changedIndex - 1)];
                }

                model = [modelsEnumerator nextObject];

                if(!model){
                    DDLogTrace(@"No more models to reorder");
                    break;
                }
            }

            task = [tasksEnumerator nextObject];
        }

        if(model){
            DDLogWarn(@"Task to reorder %@ not found. It means task was already removed", model.uid);
            [modelsStillToReorder removeObject:model];
            modelsToProcess = [modelsStillToReorder mutableCopy];

            if([modelsStillToReorder count] > 0){
                modelsEnumerator = [modelsToProcess objectEnumerator];
                model = [modelsEnumerator nextObject];
            }
        } else {
            modelsToProcess = nil;
        }
    }

    DDLogInfo(@"Tasks reorderes [%d/%d]", numberOfProcessedItems, [models count]);
}

- (void)renameTasksModels:(NSArray *)models inSortedByIndexArray:(NSMutableArray *)result usingSortedByUIDTasks:(NSArray *)tasks {

    NSMutableArray *modelsStillToRename = [models mutableCopy];
    NSMutableArray *modelsToProcess = [modelsStillToRename mutableCopy];

    NSEnumerator *tasksEnumerator = [tasks objectEnumerator];
    NSEnumerator *modelsEnumerator = [modelsToProcess objectEnumerator];

    //------------------ rename --------------------------------
    STMTask *task = [tasksEnumerator nextObject];
    STMTask *model = [modelsEnumerator nextObject];

    NSInteger numberOfProcessedItems = 0;

    while ([modelsToProcess count] > 0){
        DDLogTrace(@"rename %d tasks", [modelsStillToRename count]);

        while(task){
            DDLogTrace(@"enumerate rename %@ %@", task.uid, model.uid);
            if([task.uid isEqualToString:model.uid]){
                numberOfProcessedItems++;
                [modelsStillToRename removeObject:model];

                task.name = [model name];

                model = [modelsEnumerator nextObject];

                if(!model){
                    DDLogTrace(@"No more models to rename");
                    break;
                }
            }

            task = [tasksEnumerator nextObject];
        }

        if(model){
            DDLogWarn(@"Task to rename %@ not found. It means that it has been removed before", model.uid);
            [modelsStillToRename removeObject:model];
            modelsToProcess = [modelsStillToRename mutableCopy];

            if([modelsToProcess count] > 0){
                modelsEnumerator = [modelsToProcess objectEnumerator];
                model = [modelsEnumerator nextObject];
            }
        } else {
            modelsToProcess = nil;
        }
    }

    DDLogInfo(@"Tasks renamed [%d/%d]", numberOfProcessedItems, [models count]);
}

- (void)removeTasksModels:(NSArray *)models fromSortedByIndexArray:(NSMutableArray *)result usingSortedByUIDTasks:(NSArray *)tasks {

    NSMutableArray *modelsStillToRemove = [models mutableCopy];
    NSMutableArray *modelsToProcess = [modelsStillToRemove mutableCopy];

    NSEnumerator *tasksEnumerator = [tasks objectEnumerator];
    NSEnumerator *modelsEnumerator = [modelsToProcess objectEnumerator];

    //------------------ remove --------------------------------
    STMTask *task = [tasksEnumerator nextObject];
    STMTask *model = [modelsEnumerator nextObject];

    NSInteger numberOfProcessedItems = 0;

    while ([modelsToProcess count] > 0){
        DDLogTrace(@"rename %d tasks", [modelsStillToRemove count]);

        while(task){
            DDLogTrace(@"enumerate remove %@ %@", task.uid, model.uid);
            if([task.uid isEqualToString:model.uid]){
                numberOfProcessedItems++;
                [modelsStillToRemove removeObject:model];

                [result removeObject:task];
                [self.context deleteObject:task];
                [self decreaseNumberOfAllTasks];

                model = [modelsEnumerator nextObject];

                if(!model){
                    DDLogTrace(@"No more models to remove");
                    break;
                }
            }

            task = [tasksEnumerator nextObject];
        }

        if(model){
            DDLogWarn(@"Task to remove %@ not found. It means that it has been removed before", model.uid);
            [modelsStillToRemove removeObject:model];
            modelsToProcess = [modelsStillToRemove mutableCopy];

            if([modelsToProcess count] > 0){
                modelsEnumerator = [modelsToProcess objectEnumerator];
                model = [modelsEnumerator nextObject];
            }
        } else {
            modelsToProcess = nil;
        }
    }

    DDLogInfo(@"Tasks removed [%d/%d]", numberOfProcessedItems, [models count]);
}

- (void) addTasksModels:(NSArray *)models toSortedByIndexArray:(NSMutableArray *)result usingSortedByUIDTasks:(NSMutableArray *)tasks{
    
    for(STMTaskModel *taskModel in models){
        
        [self increaseNumberOfAllTasks];
        STMTask * taskCreated = [self addTaskWithName:taskModel.name withUid:taskModel.uid withIndex:taskModel.index];
        if(!taskCreated){
            DDLogError(@"addTaskWithName %@ failed", taskModel.uid);
        } else {
            [result addObject:taskCreated];
        }
    }
}

- (void)reestimateIndexesInSortedByIndexArray:(NSArray *)tasks {

    NSEnumerator *tasksEnumerator = [tasks objectEnumerator];
    STMTask * task = [tasksEnumerator nextObject];
    NSUInteger index = 1;
    while (task){
        DDLogTrace(@"enumerate gives order again %@ %d", task.uid, index);
        task.index = [NSNumber numberWithUnsignedInt:index];

        task = [tasksEnumerator nextObject];
        index++;
    }
}

- (NSArray *)fetchAllTasksSorted:(NSError **) error {
    NSFetchRequest *fetchRequest = [self prepareTaskFetchRequest];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"index" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    NSError* err = nil;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&err];

    if(!result){
        forwardError(err, error);
    }

    return result;
}

@end