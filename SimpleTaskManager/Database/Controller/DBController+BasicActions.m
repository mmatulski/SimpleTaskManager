//
// Created by Marek M on 20.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController+BasicActions.h"
#import "DBController+Undo.h"
#import "DBController+Internal.h"
#import "STMTaskModel.h"
#import "STMTask.h"


@implementation DBController (BasicActions)

#pragma mark - basic methods

- (void)addTaskWithName:(NSString *)name
       successFullBlock:(void (^)(STMTask *))successFullBlock
           failureBlock:(void (^)(NSError *err))failureBlock {

    [self.context performBlock:^{
        [self beginUndo];

        STMTask *task = [self addTaskWithName:name withUid:nil withIndex:nil];

        [self saveWithSuccessFullBlock:^{
            DDLogInfo(@"Task added successfully %@", task.uid);
            [self endUndo];
            if(successFullBlock){
                successFullBlock(task);
            }
        } andFailureBlock:^(NSError *error){
            [self undo];
            if(failureBlock){
                failureBlock(error);
            }
        }];
    }];
}

- (void)markAsCompletedTaskWithId:(NSString *)uid
                 successFullBlock:(void (^)())successBlock
                     failureBlock:(void (^)(NSError *))failureBlock {

    [self.context performBlock:^{
        [self beginUndo];

        NSError *err = nil;
        if([self markAsCompletedTaskWithId:uid error:&err]){
            [self saveWithSuccessFullBlock:^{
                DDLogInfo(@"Task set as completed successfully %@", uid);
                [self endUndo];
                if(successBlock){
                    successBlock();
                }
            } andFailureBlock:^(NSError *error) {
                DDLogWarn(@"Problem with marking task (Saving) as completed %@ %@", uid, [err localizedDescription]);
                [self undo];
                if(failureBlock){
                    failureBlock(error);
                }
            }];
        } else {
            DDLogWarn(@"Problem with marking task as completed %@ %@", uid, [err localizedDescription]);
            [self undo];
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (void)renameTaskWithId:(NSString *)uid
                  toName:(NSString *)theNewName
        successFullBlock:(void (^)(STMTask *))successBlock
            failureBlock:(void (^)(NSError *))failureBlock{

    [self.context performBlock:^{
        [self beginUndo];

        NSError *err = nil;
        STMTask *renamedTask = [self renameTaskWithId:uid withName:theNewName error:&err];
        if(renamedTask){
            [self saveWithSuccessFullBlock:^{
                DDLogInfo(@"Task renamed successfully %@ %@", uid, theNewName);
                [self endUndo];
                if(successBlock){
                    successBlock(renamedTask);
                }
            } andFailureBlock:^(NSError *error) {
                DDLogWarn(@"Problem with renaming task (Saving %@ %@ %@", uid, theNewName, [err localizedDescription]);
                [self undo];
                if(failureBlock){
                    failureBlock(error);
                }
            }];
        } else {
            DDLogWarn(@"Problem with marking task as completed %@ %@ %@", uid, theNewName, [err localizedDescription]);
            [self undo];
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (void)reorderTaskWithId:(NSString *)uid
                  toIndex:(NSInteger)index
         successFullBlock:(void (^)())successBlock
             failureBlock:(void (^)(NSError *))failureBlock {

    [self.context performBlock:^{
        [self beginUndo];

        NSError *err = nil;
        STMTask *task = [self reorderTaskWithId:uid toIndex:index error:&err];

        if(task){
            [self saveWithSuccessFullBlock:^{
                DDLogInfo(@"Reorder of task performed successfully %@", uid);
                [self endUndo];
                if(successBlock){
                    successBlock();
                }
            } andFailureBlock:^(NSError *error) {
                DDLogWarn(@"Problem with reordering task (Saving) %@ %@", uid, [err localizedDescription]);
                [self undo];
                if(failureBlock){
                    failureBlock(error);
                }
            }];
        } else {
            DDLogWarn(@"Problem with reordering task %@ %@", uid, [err localizedDescription]);
            [self undo];
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (void)syncAddedTasks:(NSArray *)addedTasks
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

        for(STMTaskModel *taskModel in addedTasks){
            if(![self addTaskWithName:taskModel.name withUid:taskModel.uid withIndex:taskModel.index]){
                DDLogError(@"addTaskWithName %@ failed", taskModel.uid);
                [self undo];

                if(failureBlock){
                    failureBlock(nil);
                }
                return;
            }
        }

        for(STMTaskModel *taskModel in renamedTasks){
            if(![self renameTaskWithId:taskModel.uid withName:taskModel.name error:&err]){
                DDLogError(@"renameTaskWithId %@ failed %@", taskModel.uid, [err localizedDescription] );
                [self undo];

                if(failureBlock){
                    failureBlock(err);
                }
                return;
            }
        }

        for(STMTaskModel *taskModel in reorderedTasks){
            if(![self reorderTaskWithId:taskModel.uid toIndex:[taskModel.index integerValue] error:&err]){
                DDLogError(@"reorderTaskWithId %@ failed %@", taskModel.uid, [err localizedDescription] );
                [self undo];
                if(failureBlock){
                    failureBlock(err);
                }
                return;
            }
        }

        for(STMTaskModel *taskModel in removedTasks){
            if(![self markAsCompletedTaskWithId:taskModel.uid error:&err]){
                DDLogError(@"markAsCompletedTaskWithId %@ failed %@", taskModel.uid, [err localizedDescription] );
                [self undo];

                if(failureBlock){
                    failureBlock(err);
                }
                return;
            }
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

- (void)fetchAllTasks:(void (^)(NSArray *tasks))successFullBlock failureBlock:(void (^)(NSError *))failureBlock {

    [self.context performBlock:^{
        NSError *err = nil;
        NSArray *result = [self fetchAllTasks:&err];

        if(result){
            if(successFullBlock){
                successFullBlock(result);
            }
        } else {
            DDLogWarn(@"Problem with fetchAllTasks %@", [err localizedDescription]);
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (void)fetchAllTasksAsModels:(void (^)(NSArray *tasks))successFullBlock failureBlock:(void (^)(NSError *))failureBlock {

    [self.context performBlock:^{
        NSError *err = nil;
        NSArray *entitiesResult = [self fetchAllTasks:&err];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[entitiesResult count]];
        for(STMTask *task in entitiesResult){
            STMTaskModel *taskModel = [[STMTaskModel alloc] initWitEntity:task];
            [result addObject:taskModel];
        }

        if(result){
            if(successFullBlock){
                successFullBlock([NSArray arrayWithArray:result]);
            }
        } else {
            DDLogWarn(@"Problem with fetchAllTasks %@", [err localizedDescription]);
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (NSFetchRequest *)createFetchingTasksRequestWithBatchSize:(NSUInteger) batchSize {
    NSFetchRequest *fetchRequest = [self prepareTaskFetchRequest];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"index" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    [fetchRequest setFetchBatchSize:batchSize];

    return fetchRequest;
}


- (STMTask *)existingTaskWithObjectID:(NSManagedObjectID *)objectId {
    if(objectId){
        NSError *err = nil;
        NSManagedObject * object = [self.context existingObjectWithID:objectId error:&err];
        if(!object){
            DDLogWarn(@"object with objectId: %@ does not exist", objectId);
            return nil;
        }
        return MakeSafeCast(object, [STMTask class]);
    }

    DDLogWarn(@"existingTaskWithObjectID: but no objectId set");

    return nil;
}

@end