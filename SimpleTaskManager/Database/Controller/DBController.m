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
    DDLogInfo(@"DBController saveWithSuccessFullBlock %@ BEGIN " , self);
    BlockWeakSelf selfWeak = self;
    [self.context performBlock:^{
        DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock B" , self);
        NSError *err = nil;
        if ([selfWeak.context save:&err]) {
            DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED" , self);

            if(self.parentController){
                DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT BEGIN" , self);

                [self.parentController saveWithSuccessFullBlock:^{
                    DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT - PARENT SAVED" , self);

                    if(successFullBlock){
                        successFullBlock();
                    }
                } andFailureBlock:^(NSError *error) {
                    DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT - PARENT SAVING FAILED" , self);

                    DDLogError(@"DBController saving parentController failed");
                    [error log];

                    if(failureBlock){
                        failureBlock(err);
                    }
                }];
                DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock SAVED but is has PARENT END" , self);
            } else {
                if(successFullBlock){
                    successFullBlock();
                }
            }
        } else {
            DDLogInfo(@"DBController saveWithSuccessFullBlock %@ performBlock FAILED" , self);

            DDLogError(@"DBController saving failed");
            [err log];

            if(failureBlock){
                failureBlock(err);
            }
        }
        DDLogInfo(@"DBController saveWithSuccessFullBlock performBlock E %@" , self);
    }];
    DDLogInfo(@"DBController saveWithSuccessFullBlock END %@" , self);

}

@end