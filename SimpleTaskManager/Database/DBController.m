//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController.h"
#import "STMTask.h"

NSString * const kSTMTaskEntityName = @"STMTask";

@implementation DBController {
    int _numberOfAllTasks;
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _numberOfAllTasks = -1;
    }

    return self;
}

- (instancetype)initWithParentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _parentController = parentController;
         _numberOfAllTasks = -1;

        NSManagedObjectContext* parentContext = parentController.context;
        if(parentContext){
            _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_context setParentContext:parentContext];
        }
    }

    return self;
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context parentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _context = context;
        _parentController = parentController;
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
    STMTask *task = (STMTask *)[NSEntityDescription insertNewObjectForEntityForName:kSTMTaskEntityName inManagedObjectContext:self.context];
    task.name = [name copy];
    task.uid = [[NSUUID UUID] UUIDString];

    [self loadNumberOfAllTasksIfNotLoaded];

    //order is inversely proportional to index value
    task.index = [NSNumber numberWithInt:++_numberOfAllTasks];

    [self saveWithSuccessFullBlock:^{
        if(successFullBlock){
            successFullBlock(task);
        }
    } andFailureBlock:failureBlock];
}

- (void) loadNumberOfAllTasksIfNotLoaded {
    if(_numberOfAllTasks < 0){

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

                DDLogInfo(@"number of all Tasks is %d", count);
            }
        }];
    }
}


- (NSFetchRequest *)fetchTasksRequestWithBatchSize:(unsigned int) batchSize {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
            entityForName:kSTMTaskEntityName inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
            initWithKey:@"index" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];

    [fetchRequest setFetchBatchSize:batchSize];

    return fetchRequest;
}
@end