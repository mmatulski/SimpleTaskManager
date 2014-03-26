//
// Created by Marek M on 20.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@class STMTask;

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

#pragma mark -

- (void)fetchAllTasks:(void (^)(NSArray *tasks))successFullBlock
         failureBlock:(void (^)(NSError *))failureBlock;

- (void)fetchAllTasksAsModels:(void (^)(NSArray *tasks))successFullBlock failureBlock:(void (^)(NSError *))failureBlock;

- (NSFetchRequest *)createFetchingTasksRequestWithBatchSize:(NSUInteger) batchSize;

#pragma mark -

- (STMTask *)existingTaskWithObjectID:(NSManagedObjectID *)id;

- (STMTask *)taskWithObjectID:(NSManagedObjectID *)objectId;



@end