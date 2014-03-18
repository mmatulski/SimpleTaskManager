//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController.h"
#import "STMTask.h"
#import "DBController+Internal.h"
#import "DBController+Undo.h"
#import "STMTaskModel.h"

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

#pragma mark - basic methods

- (void)addTaskWithName:(NSString *)name successFullBlock:(void (^)(STMTask *))successFullBlock failureBlock:(void (^)(NSError *err))failureBlock {

    [self beginUndo];

    STMTask *task = [self addTaskWithName:name withUid:nil withIndex:nil];

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

    [self beginUndo];

    NSError *err = nil;
    if([self markAsCompletedTaskWithId:uid error:&err]){
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

- (void)renameTaskWithId:(NSString *)uid
                  toName:(NSString *)theNewName
        successFullBlock:(void (^)(STMTask *))successBlock
            failureBlock:(void (^)(NSError *))failureBlock{

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
        DDLogWarn(@"Problem with marking task as completed %@ %@ %@", uid, theNewName, [err localizedDescription]);
        [self undo];
        if(failureBlock){
            failureBlock(err);
        }
    }
}

- (void)reorderTaskWithId:(NSString *)uid toIndex:(int)index successFullBlock:(void (^)())successBlock failureBlock:(void (^)(NSError *))failureBlock {
    
    [self beginUndo];

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
}

- (void)syncAddedTasks:(NSArray *)addedTasks
          removedTasks:(NSArray *)removedTasks
          renamedTasks:(NSArray *)renamedTasks
        reorderedTasks:(NSArray *)reorderedTasks
      successFullBlock:(void (^)(id))successFullBlock
          failureBlock:(void (^)(NSError *))failureBlock{

    [self beginUndo];

    NSError *err = nil;

    for(STMTaskModel *taskModel in addedTasks){
        if(![self addTaskWithName:taskModel.name withUid:taskModel.uid withIndex:taskModel.index]){
            [self undo];

            if(failureBlock){
                failureBlock(nil);
            }
            return;
        }
    }

    for(STMTaskModel *taskModel in removedTasks){
        if(![self markAsCompletedTaskWithId:taskModel.uid error:&err]){
            [self undo];

            if(failureBlock){
                failureBlock(err);
            }
            return;
        }
    }

    for(STMTaskModel *taskModel in renamedTasks){
        if(![self renameTaskWithId:taskModel.uid withName:taskModel.name error:&err]){
            [self undo];

            if(failureBlock){
                failureBlock(err);
            }
            return;
        }
    }

    for(STMTaskModel *taskModel in reorderedTasks){
        if(![self reorderTaskWithId:taskModel.uid toIndex:[taskModel.index intValue] error:&err]){
            [self undo];
            if(failureBlock){
                failureBlock(err);
            }
            return;
        }
    }

    [self saveWithSuccessFullBlock:^{
        [self endUndo];
        if(successFullBlock){
            successFullBlock(nil);
        }
    } andFailureBlock:^(NSError *error){
        [self undo];
        if(failureBlock){
            failureBlock(error);
        }
    }];
}

- (void)fetchAllTasks:(void (^)(NSArray *tasks))successFullBlock failureBlock:(void (^)(NSError *))failureBlock {
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
}

- (NSFetchRequest *)createFetchingTasksRequestWithBatchSize:(unsigned int) batchSize {
    NSFetchRequest *fetchRequest= [self prepareTaskFetchRequest];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"index" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    [fetchRequest setFetchBatchSize:batchSize];

    return fetchRequest;
}




@end