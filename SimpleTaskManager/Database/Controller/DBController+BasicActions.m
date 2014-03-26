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
                DDLogInfo(@"Task set as completedByUser successfully %@", uid);
                [self endUndo];
                if(successBlock){
                    successBlock();
                }
            } andFailureBlock:^(NSError *error) {
                DDLogWarn(@"Problem with marking task (Saving) as completedByUser %@ %@", uid, [err localizedDescription]);
                [self undo];
                if(failureBlock){
                    failureBlock(error);
                }
            }];
        } else {
            DDLogWarn(@"Problem with marking task as completedByUser %@ %@", uid, [err localizedDescription]);
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
            DDLogWarn(@"Problem with marking task as completedByUser %@ %@ %@", uid, theNewName, [err localizedDescription]);
            [self undo];
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (void)reorderTaskWithId:(NSString *)uid
                  toIndex:(NSUInteger)index
         successFullBlock:(void (^)())successBlock
             failureBlock:(void (^)(NSError *))failureBlock {

    [self.context performBlock:^{
        [self beginUndo];

        DDLogInfo(@"Reorder task with uid %@ to index %td", uid, index);

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

- (void)fetchAllTasks:(void (^)(NSArray *tasks))successFullBlock failureBlock:(void (^)(NSError *))failureBlock {

    [self.context performBlockAndWait:^{
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

    [self.context performBlockAndWait:^{
        NSError *err = nil;
        NSArray *entitiesResult = [self fetchAllTasks:&err];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[entitiesResult count]];
        for(STMTask *task in entitiesResult){
            STMTaskModel *taskModel = [[STMTaskModel alloc] initWitTask:task];
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

- (STMTask *)taskWithObjectID:(NSManagedObjectID *)objectId {
    if(objectId){
        NSManagedObject * object = [self.context objectWithID:objectId];
        if(!object){
            DDLogWarn(@"object with objectId: %@ not found", objectId);
            return nil;
        }
        return MakeSafeCast(object, [STMTask class]);
    }

    DDLogWarn(@"taskWithObjectID: but no objectId set");

    return nil;
}

@end