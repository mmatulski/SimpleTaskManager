//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController.h"
#import "DBController+Undo.h"
#import "NSError+Log.h"

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
                [self.parentController saveWithSuccessFullBlock:^{
                    if(successFullBlock){
                        successFullBlock();
                    }
                } andFailureBlock:^(NSError *error) {
                    DDLogError(@"DBController saving parentController failed");
                    [error log];

                    if(failureBlock){
                        failureBlock(err);
                    }
                }];
            } else {
                if(successFullBlock){
                    successFullBlock();
                }
            }
        } else {
            DDLogError(@"DBController saving failed");
            [err log];

            if(failureBlock){
                failureBlock(err);
            }
        }
    }];
}

@end