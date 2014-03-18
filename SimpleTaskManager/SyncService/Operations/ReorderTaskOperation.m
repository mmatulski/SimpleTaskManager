//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "ReorderTaskOperation.h"
#import "DBAccess.h"
#import "DBController.h"


@implementation ReorderTaskOperation {

}

- (instancetype)initWithTaskUid:(NSString *)taskUid targetIndex:(int)targetIndex {
    self = [super init];
    if (self) {
        self.taskUid = taskUid;
        self.targetIndex = targetIndex;
    }

    return self;
}

- (void)main {
    DDLogInfo(@"ReorderTaskOperation BEGIN %@ %d", self.taskUid, self.targetIndex);

    DBController *dbController = [DBAccess createBackgroundController];
    [dbController reorderTaskWithId:self.taskUid toIndex:self.targetIndex successFullBlock:^() {
        DDLogInfo(@"ReorderTaskOperation END S %@ END", self.taskUid);
        [self finishedSuccessFully];
    } failureBlock:^(NSError *err) {
        DDLogError(@"ReorderTaskOperation END FAILED");
        [self failedWithError:err];
    }];
}

@end