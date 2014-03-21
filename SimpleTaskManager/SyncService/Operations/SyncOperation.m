//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SyncOperation.h"
#import "DBController.h"
#import "DBAccess.h"
#import "DBController+BasicActions.h"
#import "CommonNotifications.h"


@implementation SyncOperation {

}

- (void)main {
    DDLogInfo(@"SyncOperation BEGIN");

    [CommonNotifications remoteSyncStarted];

    TICK
    DBController *dbController = [DBAccess createBackgroundWorker];
    [dbController syncAddedTasks:self.addedTasks
                    removedTasks:self.removedTasks
                    renamedTasks:self.renamedTasks
                  reorderedTasks:self.reorderedTasks
                successFullBlock:^(id o) {
                    DDLogInfo(@"SyncOperation END S");
                    TOCK
                    [self finishedSuccessFully];
                } failureBlock:^(NSError *error) {
        DDLogError(@"SyncOperation END FAILED");
        TOCK
        [self failedWithError:error];
    }];
    DDLogInfo(@"SyncOperation END");
}

- (void)finish {
    [CommonNotifications remoteSyncFinished];

    [super finish];
}


@end