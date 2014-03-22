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

        NSMutableArray *tasksSortedByIndexesAndMutable = [tasksSortedByIndex mutableCopy];

        NSSortDescriptor *sortByUid = [[NSSortDescriptor alloc]
                initWithKey:@"uid" ascending:NO];

        NSMutableArray *tasksSortedByUid = [[tasksSortedByIndexesAndMutable sortedArrayUsingDescriptors:@[sortByUid]] mutableCopy];
        NSArray *taskModelsToReorderSortedByUid = [reorderedTasks sortedArrayUsingDescriptors:@[sortByUid]];

        NSEnumerator *taskModelToReorderEnumeratorSortedByUid = [taskModelsToReorderSortedByUid objectEnumerator];
        NSEnumerator *tasksEnumeratorSortedByUid = [tasksSortedByUid objectEnumerator];

        STMTask *task = [tasksEnumeratorSortedByUid nextObject];
        STMTaskModel *taskModel = [taskModelToReorderEnumeratorSortedByUid nextObject];

        while (task){
            DDLogTrace(@"enumerate reorder%@ %@", task.uid, taskModel.uid);
            if([task.uid isEqualToString:taskModel.uid]){
                [tasksSortedByIndexesAndMutable removeObject:task];
                NSUInteger changedIndex = [taskModel.index unsignedIntegerValue];
                if([tasksSortedByIndexesAndMutable count] > (changedIndex - 1)){
                    [tasksSortedByIndexesAndMutable insertObject:task atIndex:
                            (changedIndex - 1)];
                }
                taskModel = [tasksEnumeratorSortedByUid nextObject];

            }

            task = [tasksEnumeratorSortedByUid nextObject];
        }

        taskModelToReorderEnumeratorSortedByUid = [taskModelsToReorderSortedByUid objectEnumerator];
        tasksEnumeratorSortedByUid = [tasksSortedByUid objectEnumerator];

        task = [tasksEnumeratorSortedByUid nextObject];
        taskModel = [taskModelToReorderEnumeratorSortedByUid nextObject];
        while (task){
            DDLogTrace(@"enumerate rename %@ %@", task.uid, taskModel.uid);
            if([task.uid isEqualToString:taskModel.uid]){
                task.name = [taskModel name];
                taskModel = [tasksEnumeratorSortedByUid nextObject];
            }

            task = [tasksEnumeratorSortedByUid nextObject];
        }

        taskModelToReorderEnumeratorSortedByUid = [taskModelsToReorderSortedByUid objectEnumerator];
        tasksEnumeratorSortedByUid = [tasksSortedByUid objectEnumerator];

        task = [tasksEnumeratorSortedByUid nextObject];
        taskModel = [taskModelToReorderEnumeratorSortedByUid nextObject];

        [self loadNumberOfAllTasksIfNotLoaded];
        while (task){
            DDLogTrace(@"enumerate remove %@ %@", task.uid, taskModel.uid);
            if([task.uid isEqualToString:taskModel.uid]){
                [tasksSortedByIndexesAndMutable removeObject:task];
                [self decreaseNumberOfAllTasks];
            }

            task = [tasksEnumeratorSortedByUid nextObject];
        }

        for(STMTaskModel *taskModel in addedTasks){
            [self increaseNumberOfAllTasks];
            STMTask * taskCreated = [self addTaskWithName:taskModel.name withUid:taskModel.uid withIndex:taskModel.index];
            if(!taskCreated){
                DDLogError(@"addTaskWithName %@ failed", taskModel.uid);
                [self undo];

                if(failureBlock){
                    failureBlock(nil);
                }
                return;
            } else {
                [tasksSortedByUid addObject:taskCreated];
            }
        }

        tasksEnumeratorSortedByUid = [tasksSortedByUid objectEnumerator];

        task = [tasksEnumeratorSortedByUid nextObject];

        NSUInteger index = 1;
        while (task){
            DDLogTrace(@"enumerate gives order again %@ %d", task.uid, index);
            task.index = [NSNumber numberWithUnsignedInt:index];

            task = [tasksEnumeratorSortedByUid nextObject];
            index++;
        }



        [self saveWithSuccessFullBlock:^{
            [self endUndo];
            if(successFullBlock){
                successFullBlock(nil);
            }
        } andFailureBlock:^(NSError *error){
            DDLogError(@"syncAddedTasks failed %@", [err localizedDescription] );
            [self undo];
            if(failureBlock){
                failureBlock(error);
            }
        }];
    }];
}

- (NSArray *)fetchAllTasksSorted:(NSError **)pError {
    NSFetchRequest *fetchRequest = [self prepareTaskFetchRequest];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"index" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    NSError* err = nil;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&err];

    return result;
}

@end