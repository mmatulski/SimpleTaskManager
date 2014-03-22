//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController.h"
#import "DBController+Undo.h"
#import "NSError+Log.h"
#import "DBController+Internal.h"

@implementation DBController

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        self.numberOfAllTasks = 0;

        [self addUndoManager];
    }

    return self;
}

- (instancetype)initWithParentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _parentController = parentController;
        self.numberOfAllTasks = 0;

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
        self.numberOfAllTasks = 0;

        [self addUndoManager];
    }

    return self;
}

- (void)saveWithSuccessFullBlock:(void (^)())successFullBlock andFailureBlock:(void (^)(NSError *))failureBlock {
    DDLogTrace(@"DBController saveWithSuccessFullBlock %@ BEGIN " , self);
    BlockWeakSelf selfWeak = self;
    [self.context performBlock:^{
        DDLogTrace(@"DBController saveWithSuccessFullBlock %@ performBlock B" , self);
        NSError *err = nil;
        if ([selfWeak.context save:&err]) {
            DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED" , self);

            if(self.parentController){
                DDLogTrace(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT BEGIN" , self);

                [self.parentController saveWithSuccessFullBlock:^{
                    DDLogTrace(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT - PARENT SAVED" , self);

                    if(successFullBlock){
                        successFullBlock();
                    }
                } andFailureBlock:^(NSError *error) {
                    DDLogTrace(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT - PARENT SAVING FAILED" , self);

                    DDLogError(@"DBController saving parentController failed");
                    [error log];

                    if(failureBlock){
                        failureBlock(err);
                    }
                }];
                DDLogTrace(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT END" , self);
            } else {
                if(successFullBlock){
                    successFullBlock();
                }
            }
        } else {
            DDLogTrace(@"DBController saveWithSuccessFullBlock %@ performBlock FAILED" , self);

            DDLogError(@"DBController saving failed");
            [err log];

            if(failureBlock){
                failureBlock(err);
            }
        }
        DDLogTrace(@"DBController saveWithSuccessFullBlock performBlock E %@" , self);
    }];
    DDLogTrace(@"DBController saveWithSuccessFullBlock END %@" , self);
}

- (NSUInteger) numberOfAllTasks {
    [self loadNumberOfAllTasksIfNotLoaded];
    return _numberOfAllTasks;
}

- (void) loadNumberOfAllTasksIfNotLoaded {
    if(!_numberOfAllTasksEstimated){
        BlockWeakSelf selfWeak = self;
        [self.context performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:kSTMTaskEntityName
                                           inManagedObjectContext:selfWeak.context]];
            [request setIncludesSubentities:NO];

            NSError *err;
            NSUInteger count = [selfWeak.context countForFetchRequest:request error:&err];
            if(count == NSNotFound) {
                DDLogError(@"There was problem with loading number of all tasks %@", [err localizedDescription]);
            } else {
                _numberOfAllTasks = count;
                _numberOfAllTasksEstimated = true;

                DDLogInfo(@"number of all Tasks is %u", self.numberOfAllTasks);
            }
        }];
    }
}

- (void)increaseNumberOfAllTasks {
    [self loadNumberOfAllTasksIfNotLoaded];
    _numberOfAllTasks++;
}

- (void)decreaseNumberOfAllTasks {
    [self loadNumberOfAllTasksIfNotLoaded];
    _numberOfAllTasks--;
}

@end