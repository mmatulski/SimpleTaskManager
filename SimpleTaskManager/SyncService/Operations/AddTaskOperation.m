//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "AddTaskOperation.h"
#import "DBController.h"
#import "DBAccess.h"


@implementation AddTaskOperation {

}

- (instancetype)initWithTaskName:(NSString *)taskName {
    self = [super init];
    if (self) {
        self.taskName = taskName;
    }

    return self;
}

- (void)main {
    DDLogInfo(@"AddTaskOperation BEGIN %@", _taskName);

    DBController *dbController = [DBAccess createBackgroundController];
    [dbController addTaskWithName:self.taskName successFullBlock:^(STMTask *task) {
        DDLogInfo(@"SUCCESS");
        [self finishedSuccessFully];
    } failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
        [self failedWithError:err];
    }];
}


@end