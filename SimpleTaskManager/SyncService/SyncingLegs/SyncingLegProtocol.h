//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SyncingLegProtocol <NSObject>

- (void)addTaskWithName:(NSString *)name
       successFullBlock:(void (^)(id))successFullBlock
           failureBlock:(void (^)(NSError *err))failureBlock;

- (void)markAsCompletedTaskWithId:(NSString *)uid
                 successFullBlock:(void (^)(id))successFullBlock
                     failureBlock:(void (^)(NSError *))failureBlock;

- (void)reorderTaskWithId:(NSString *)uid
                  toIndex:(NSUInteger)targetIndex
         successFullBlock:(void (^)(id))successFullBlock
             failureBlock:(void (^)(NSError *))failureBlock;

- (void)renameTaskWithId:(NSString *)uid
                  toName:(NSString *)theNewName
        successFullBlock:(void (^)(id))successFullBlock
            failureBlock:(void (^)(NSError *))failureBlock;

- (void)syncAddedTasks:(NSArray *)addedTasks
          removedTasks:(NSArray *)removedTasks
          renamedTasks:(NSArray *)renamedTasks
        reorderedTasks:(NSArray *)reorderedTasks
      successFullBlock:(void (^)(id))successFullBlock
          failureBlock:(void (^)(NSError *))failureBlock;

@end