//
// Created by Marek M on 20.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@interface DBController (BasicActions)

#pragma mark -
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
                  toIndex:(NSUInteger)index
         successFullBlock:(void (^)())successFullBlock
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

- (STMTask *)taskWithObjectID:(NSManagedObjectID *)id;

#pragma mark -

- (NSFetchRequest *)createFetchingTasksRequestWithBatchSize:(NSUInteger) batchSize;



@end