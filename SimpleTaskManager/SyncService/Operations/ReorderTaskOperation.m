//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "ReorderTaskOperation.h"
#import "DBAccess.h"
#import "DBController.h"
#import "DBController+BasicActions.h"


@implementation ReorderTaskOperation {

}

- (instancetype)initWithTaskUid:(NSString *)taskUid targetIndex:(NSUInteger)targetIndex {
    self = [super init];
    if (self) {
        self.taskUid = taskUid;
        self.targetIndex = targetIndex;
    }

    return self;
}

- (void)main {
    DDLogInfo(@"ReorderTaskOperation BEGIN %@ %td", self.taskUid, self.targetIndex);

    DBController *dbController = [DBAccess createBackgroundWorker];
    [dbController reorderTaskWithId:self.taskUid toIndex:self.targetIndex successFullBlock:^() {
        DDLogInfo(@"ReorderTaskOperation END S %@ END", self.taskUid);
        [self finishedSuccessFully];
    } failureBlock:^(NSError *err) {
        DDLogError(@"ReorderTaskOperation END FAILED");
        [self failedWithError:err];
    }];
}

@end