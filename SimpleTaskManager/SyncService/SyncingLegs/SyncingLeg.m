//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SingleOperation.h"
#import "LocalUserLeg.h"
#import "STMTask.h"
#import "SyncGuardService.h"
#import "AddTaskOperation.h"
#import "CompleteTaskOperation.h"
#import "ReorderTaskOperation.h"
#import "RenameOperation.h"
#import "SyncOperation.h"


@implementation SyncingLeg {

}

- (id)init {
    self = [super init];
    if (self) {
        _operationsWaitingToSyncWidthLocalDB = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)addTaskWithName:(NSString *)name
       successFullBlock:(void (^)(id))successFullBlock
           failureBlock:(void (^)(NSError *err))failureBlock {

    AddTaskOperation *operation = [[AddTaskOperation alloc] initWithTaskName:name];
    [self assignCommonOperationOperation:operation
                        successFullBlock:successFullBlock
                            failureBlock:failureBlock];
}

- (void)markAsCompletedTaskWithId:(NSString *)uid
                 successFullBlock:(void (^)(id))successFullBlock
                     failureBlock:(void (^)(NSError *))failureBlock {
    CompleteTaskOperation *operation = [[CompleteTaskOperation alloc] initWithTaskUid:uid];
    [self assignCommonOperationOperation:operation
                        successFullBlock:successFullBlock
                            failureBlock:failureBlock];
}

- (void) reorderTaskWithId:(NSString *)uid
                  toIndex:(NSUInteger)targetIndex
         successFullBlock:(void (^)(id))successFullBlock
             failureBlock:(void (^)(NSError *))failureBlock {
    ReorderTaskOperation *operation = [[ReorderTaskOperation alloc]
            initWithTaskUid:uid targetIndex:targetIndex];

    [self assignCommonOperationOperation:operation
                        successFullBlock:successFullBlock
                            failureBlock:failureBlock];
}

- (void)renameTaskWithId:(NSString *)uid
                  toName:(NSString *)theNewName
        successFullBlock:(void (^)(id))successFullBlock
            failureBlock:(void (^)(NSError *))failureBlock {
    RenameOperation *operation = [[RenameOperation alloc]
            initWithTaskUid:uid theNewName:theNewName];

    [self assignCommonOperationOperation:operation
                        successFullBlock:successFullBlock
                            failureBlock:failureBlock];
}

- (void)syncAddedTasks:(NSArray *)addedTasks
          removedTasks:(NSArray *)removedTasks
          renamedTasks:(NSArray *)renamedTasks
        reorderedTasks:(NSArray *)reorderedTasks
      successFullBlock:(void (^)(id))successFullBlock
          failureBlock:(void (^)(NSError *))failureBlock {

    SyncOperation *operation = [[SyncOperation alloc] init];

    operation.addedTasks = addedTasks;
    operation.removedTasks = removedTasks;
    operation.renamedTasks = renamedTasks;
    operation.reorderedTasks = reorderedTasks;

    [self assignCommonOperationOperation:operation
                        successFullBlock:successFullBlock
                            failureBlock:failureBlock];
}


- (void)assignCommonOperationOperation:(SingleOperation *)operation
                      successFullBlock:(void (^)(id))successFullBlock
                          failureBlock:(void (^)(NSError *))failureBlock {
    operation.delegate = self;
    operation.successFullBlock = successFullBlock;
    operation.failureBlock = failureBlock;

    [self.operationsWaitingToSyncWidthLocalDB addObject:operation];
    [self.syncGuardService operationIsWaitingForExecutionOnSide:self];
}

#pragma mark - SingleOperationDelegate methods

- (void)operationFinished:(SingleOperation *)operation {
    DDLogInfo(@"Operation finished");

    [operation performAdequateBlock];

    //[self.operationsWaitingToSyncWidthLocalDB removeObjectAtIndex:0];

    if([self.operationsWaitingToSyncWidthLocalDB count] > 0){
        [self.syncGuardService operationIsWaitingForExecutionOnSide:self];
    }
}


- (SingleOperation *)nextOperation {
    return [self.operationsWaitingToSyncWidthLocalDB firstObject];
}

- (void)operationPushedOnQueue:(SingleOperation *)operation {
    [self.operationsWaitingToSyncWidthLocalDB removeObject:operation];
}
@end