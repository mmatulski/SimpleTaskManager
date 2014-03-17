//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController.h"
#import "STMTask.h"
#import "DBController+Internal.h"
#import "DBController+Undo.h"

NSString * const kSTMTaskEntityName = @"STMTask";

@implementation DBController

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _numberOfAllTasks = 0;

        [self addUndoManager];
    }

    return self;
}

- (instancetype)initWithParentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _parentController = parentController;
        _numberOfAllTasks = 0;

        NSManagedObjectContext* parentContext = parentController.context;
        if(parentContext){
            _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_context setParentContext:parentContext];

            [self addUndoManager];
        }
    }

    return self;
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context parentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _context = context;
        _parentController = parentController;
        _numberOfAllTasks = 0;

        [self addUndoManager];
    }

    return self;
}

- (void)saveWithSuccessFullBlock:(void (^)())successFullBlock andFailureBlock:(void (^)(NSError *))failureBlock {
    BlockWeakSelf selfWeak = self;
    [self.context performBlock:^{
        NSError *err = nil;
        if ([selfWeak.context save:&err]) {
            if(self.parentController){
                [self.parentController saveWithSuccessFullBlock:successFullBlock andFailureBlock:failureBlock];
            } else {
                if(successFullBlock){
                    successFullBlock();
                }
            }
        } else {
            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

- (void)addTaskWithName:(NSString *)name successFullBlock:(void (^)(STMTask *))successFullBlock failureBlock:(void (^)(NSError *err))failureBlock {
    [self loadNumberOfAllTasksIfNotLoaded];

    [self beginUndo];

    STMTask *task = (STMTask *)[NSEntityDescription insertNewObjectForEntityForName:kSTMTaskEntityName inManagedObjectContext:self.context];
    task.name = [name copy];
    task.uid = [[NSUUID UUID] UUIDString];

    //order is inversely proportional to index value
    task.index = [NSNumber numberWithUnsignedLong:++_numberOfAllTasks];

    [self saveWithSuccessFullBlock:^{
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

}

- (void)markAsCompletedTaskWithId:(NSString *)uid successFullBlock:(void (^)())successBlock failureBlock:(void (^)(NSError *))failureBlock {
    [self loadNumberOfAllTasksIfNotLoaded];

    NSError *err = nil;
    STMTask *task = [self findTaskWithId:uid error:&err];
    if (!task) {
        if (failureBlock) {
            failureBlock(err);
        }
        return;
    }

    [self beginUndo];

    if([self removeTask:task error:&err]){
        [self saveWithSuccessFullBlock:^{
            DDLogInfo(@"Task set as completed  successfully %@", uid);
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
}

//- (void) findTaskWithId:(NSString *)uid successFullBlock:(void (^)(STMTask *))successBlock failureBlock:(void (^)(NSError *))failureBlock{
//
//}

- (void) loadNumberOfAllTasksIfNotLoaded {
    if(!_numberOfAllTasksEstimated){
        BlockWeakSelf selfWeak = self;
        [self.context performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"STMTask" inManagedObjectContext:selfWeak.context]];
            [request setIncludesSubentities:NO];

            NSError *err;
            NSUInteger count = [selfWeak.context countForFetchRequest:request error:&err];
            if(count == NSNotFound) {
                DDLogError(@"There was problem with loading number of all tasks %@", [err localizedDescription]);
            } else {
                _numberOfAllTasks = count;
                _numberOfAllTasksEstimated = true;

                DDLogInfo(@"number of all Tasks is %lu", _numberOfAllTasks);
            }
        }];
    }
}


- (NSFetchRequest *)createFetchingTasksRequestWithBatchSize:(unsigned int) batchSize {
    NSFetchRequest *fetchRequest= [self prepareTaskFetchRequest];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"index" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    [fetchRequest setFetchBatchSize:batchSize];

    return fetchRequest;
}


- (void)reorderTaskWithId:(NSString *)uid toIndex:(int)index successFullBlock:(void (^)())successBlock failureBlock:(void (^)(NSError *))failureBlock {
    [self loadNumberOfAllTasksIfNotLoaded];

    NSError *err = nil;
    STMTask *task = [self findTaskWithId:uid error:&err];
    if (!task) {
        if (failureBlock) {
            failureBlock(err);
        }
        return;
    }

    [self beginUndo];

    if([self reorderTask:task withIndex:index error:&err]){
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
}

@end