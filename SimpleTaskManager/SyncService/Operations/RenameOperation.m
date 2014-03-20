//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "RenameOperation.h"
#import "DBAccess.h"
#import "DBController.h"
#import "DBController+BasicActions.h"


@implementation RenameOperation {

}

- (instancetype)initWithTaskUid:(NSString *)taskUid theNewName:(NSString *)theNewName {
    self = [super init];
    if (self) {
        self.taskUid = taskUid;
        self.theNewName = theNewName;
    }

    return self;
}

- (void)main {
    DDLogInfo(@"RenameOperation BEGIN %@ %@", self.taskUid, self.theNewName);

    DBController *dbController = [DBAccess createBackgroundWorker];
    [dbController renameTaskWithId:self.taskUid toName:self.theNewName successFullBlock:^(id o) {
        DDLogInfo(@"RenameOperation END S %@ END", self.taskUid);
        [self finishedSuccessFully];
    } failureBlock:^(NSError *error) {
        DDLogError(@"RenameOperation END FAILED");
        [self failedWithError:error];
    }];
}

@end