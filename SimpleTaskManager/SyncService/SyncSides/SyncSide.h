//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleOperationDelegate.h"

@class STMTask;
@class SyncGuardService;

@class SingleOperation;

@interface SyncSide : NSObject <SingleOperationDelegate>

@property(nonatomic, strong) NSMutableArray *operationsWaitingToSyncWidthLocalDB;
@property(nonatomic, weak) SyncGuardService *syncGuardService;

- (void)addTaskWithName:(NSString *)name successFullBlock:(void (^)(id))successFullBlock failureBlock:(void (^)(NSError *err))failureBlock;
- (void)markAsCompletedTaskWithId:(NSString *)uid successFullBlock:(void (^)(id*))successFullBlock failureBlock:(void (^)(NSError *))failureBlock;
- (void)reorderTaskWithId:(NSString *)uid toIndex:(int)targetIndex successFullBlock:(void (^)(id))successFullBlock failureBlock:(void (^)(NSError *))failureBlock;

-(void) allTasksOnTheOtherSide:(void (^)(id))successFullBlock failureBlock:(void (^)(NSError *err))failureBlock;

- (SingleOperation *)nextOperation;
@end