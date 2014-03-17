//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;


@interface SyncService : NSObject

+ (instancetype) sharedInstance;

//user actions
- (void)addTaskWithName:(NSString *)name successFullBlock:(void (^)(STMTask *))successFullBlock failureBlock:(void (^)(NSError *err))failureBlock;
- (void)markAsCompletedTaskWithId:(NSString *)uid successFullBlock:(void (^)())block failureBlock:(void (^)(NSError *))block1;
- (void)reorderTaskWithId:(NSString *)uid toIndex:(int)index successFullBlock:(void (^)())block failureBlock:(void (^)(NSError *))block1;


//server actions

@end