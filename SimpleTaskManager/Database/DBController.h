//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;

extern NSString * const kSTMTaskEntityName;

@interface DBController : NSObject {
    unsigned long _numberOfAllTasks;
    unsigned long _numberOfAllTasksForUndo;
    bool _numberOfAllTasksEstimated;
}

@property(readonly, nonatomic, strong) NSManagedObjectContext *context;
@property(readonly, nonatomic, strong) DBController *parentController;

- (instancetype)initWithContext:(NSManagedObjectContext *)context;
- (instancetype)initWithParentController:(DBController *)parentController;
- (instancetype)initWithContext:(NSManagedObjectContext *)context parentController:(DBController *)parentController;

- (void)saveWithSuccessFullBlock:(void (^)())successFullBlock
                 andFailureBlock:(void (^)(NSError *))block;

#pragma mar -
- (void)addTaskWithName:(NSString *)name
       successFullBlock:(void (^)(STMTask *))successFullBlock
           failureBlock:(void (^)(NSError *err))failureBlock;

- (void)markAsCompletedTaskWithId:(NSString *)uid
                 successFullBlock:(void (^)())block
                     failureBlock:(void (^)(NSError *))block1;

- (void)renameTaskWithId:(NSString *)uid
                  toName:(NSString *)theNewName
        successFullBlock:(void (^)(STMTask*))successFullBlock
            failureBlock:(void (^)(NSError *))failureBlock;

- (void)reorderTaskWithId:(NSString *)uid
                  toIndex:(int)index successFullBlock:(void (^)())successFullBlock
        failureBlock:(void (^)(NSError *))failureBlock;

- (void)syncAddedTasks:(NSArray *)addedTasks
          removedTasks:(NSArray *)removedTasks
          renamedTasks:(NSArray *)renamedTasks
        reorderedTasks:(NSArray *)reorderedTasks
      successFullBlock:(void (^)(id))successFullBlock
          failureBlock:(void (^)(NSError *))failureBlock;

#pragma mark -

- (void)fetchAllTasks:(void (^)(NSArray *tasks))successFullBlock
         failureBlock:(void (^)(NSError *))failureBlock;

#pragma mark -

- (NSFetchRequest *)createFetchingTasksRequestWithBatchSize:(unsigned int) batchSize;

- (STMTask *)taskWithObjectID:(NSManagedObjectID *)id;
@end