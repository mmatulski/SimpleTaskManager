//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SyncOperation.h"
#import "DBController.h"
#import "DBAccess.h"
#import "DBController+BasicActions.h"


@implementation SyncOperation {

}

- (void)main {
    DDLogInfo(@"SyncOperation BEGIN");

    DBController *dbController = [DBAccess createBackgroundWorker];
    [dbController syncAddedTasks:self.addedTasks
                    removedTasks:self.removedTasks
                    renamedTasks:self.renamedTasks
                  reorderedTasks:self.reorderedTasks
                successFullBlock:^(id o) {
                    DDLogInfo(@"SyncOperation END S");
                    [self finishedSuccessFully];
                } failureBlock:^(NSError *error) {
        DDLogError(@"SyncOperation END FAILED");
        [self failedWithError:error];
    }];
}

@end