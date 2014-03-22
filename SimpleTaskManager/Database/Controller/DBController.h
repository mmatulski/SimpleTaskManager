//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;

extern NSString * const kSTMTaskEntityName;

@interface DBController : NSObject {
    NSInteger _numberOfAllTasksForUndo;
    BOOL _numberOfAllTasksEstimated;
}

@property(readonly, nonatomic, strong) NSManagedObjectContext *context;
@property(readonly, nonatomic, strong) DBController *parentController;

@property (nonatomic) NSUInteger numberOfAllTasks;

- (instancetype)initWithContext:(NSManagedObjectContext *)context;
- (instancetype)initWithParentController:(DBController *)parentController;
- (instancetype)initWithContext:(NSManagedObjectContext *)context parentController:(DBController *)parentController;

- (void)saveWithSuccessFullBlock:(void (^)())successFullBlock
                 andFailureBlock:(void (^)(NSError *))block;


@end