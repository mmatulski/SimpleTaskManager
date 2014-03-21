//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableDataSourceNotificationsObserver.h"
#import "MainTableDataSource.h"


@implementation MainTableDataSourceNotificationsObserver {

}

- (instancetype)initWithMainTableDataSource:(MainTableDataSource *)mainTableDataSource {
    self = [super initWithDefaultNotifications];
    if (self) {
        self.mainTableDataSource = mainTableDataSource;
    }

    return self;
}

//OVERRIDEN
- (void)remoteSyncStarted {
    DDLogInfo(@"MainTableDataSourceNotificationsObserver remoteSyncStarted");
    self.mainTableDataSource.paused = true;
}

- (void)remoteSyncFinished {
    DDLogInfo(@"MainTableDataSourceNotificationsObserver remoteSyncFinished");
    self.mainTableDataSource.paused = false;
}

@end