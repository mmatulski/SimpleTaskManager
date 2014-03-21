//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainViewControllerNotificationsObserver.h"
#import "MainViewController.h"


@implementation MainViewControllerNotificationsObserver {

}

- (instancetype)initWithMainViewController:(MainViewController *)mainViewController {
    self = [super initWithDefaultNotifications];
    if (self) {
        self.mainViewController = mainViewController;
    }

    return self;
}

//OVERRIDEN
- (void)remoteSyncStarted {
    DDLogInfo(@"MainViewControllerNotificationsObserver remoteSyncStarted");
}

- (void)remoteSyncFinished {
    DDLogInfo(@"MainViewControllerNotificationsObserver remoteSyncFinished");
}

@end