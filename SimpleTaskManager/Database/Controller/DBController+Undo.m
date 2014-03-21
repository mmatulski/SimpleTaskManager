//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController+Undo.h"


@implementation DBController (Undo)

- (void)addUndoManager {
    if(self.context && !self.context.undoManager){
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        [self.context setUndoManager:undoManager];
        [undoManager disableUndoRegistration];
    }
}

- (void)beginUndo {
    _numberOfAllTasksForUndo = self.numberOfAllTasks;
    [self.context.undoManager enableUndoRegistration];
}

-(void) endUndo{
    [self.context.undoManager removeAllActions];
    [self.context.undoManager disableUndoRegistration];
}

-(void) undo{
    self.numberOfAllTasks = _numberOfAllTasksForUndo;

    //lets estimate it once again
    _numberOfAllTasksEstimated = false;

    [self.context.undoManager undo];
    [self.context.undoManager removeAllActions];
    [self.context.undoManager disableUndoRegistration];

    [self saveWithSuccessFullBlock:^{
        DDLogWarn(@"Saved after undo SUCCESS");
    } andFailureBlock:^(NSError *error) {
        DDLogWarn(@"Save after undo failed %@", [error localizedDescription]);
    }];
}
@end