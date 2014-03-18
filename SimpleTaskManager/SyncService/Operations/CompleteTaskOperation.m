//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "CompleteTaskOperation.h"
#import "DBController.h"
#import "DBAccess.h"


@implementation CompleteTaskOperation {

}

- (instancetype)initWithTaskUid:(NSString *)taskUid {
    self = [super init];
    if (self) {
        self.taskUid = taskUid;
    }

    return self;
}

- (void)main {
    DDLogInfo(@"CompleteTaskOperation BEGIN %@", self.taskUid);

    DBController *dbController = [DBAccess createBackgroundController];
    [dbController markAsCompletedTaskWithId:self.taskUid successFullBlock:^() {
        DDLogInfo(@"CompleteTaskOperation END S %@ END", self.taskUid);
        [self finishedSuccessFully];
    } failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
        [self failedWithError:err];
    }];
}



@end