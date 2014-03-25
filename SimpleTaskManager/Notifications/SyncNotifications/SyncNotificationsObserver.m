//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "CommonNotifications.h"
#import "MainViewControllerStateController.h"
#import "SyncNotificationsObserver.h"


@implementation SyncNotificationsObserver {

}

- (instancetype)initWithDefaultNotifications {
    self = [super initWithNotificationsKeys:[SyncNotificationsObserver notificationsKeysToObserve]];
    if (self) {

    }

    return self;
}

+(NSArray *) notificationsKeysToObserve {
    return @[NTFKEY_REMOTE_SYNC_STARTED, NTFKEY_REMOTE_SYNC_FINISHED];
}

- (void)notificationArrived:(NSNotification *)notification {

    if([notification.name isEqualToString:NTFKEY_REMOTE_SYNC_STARTED]){
        [self remoteSyncStarted];
    } else if([notification.name isEqualToString:NTFKEY_REMOTE_SYNC_FINISHED]){
        [self remoteSyncFinished];
    }

}

- (void)remoteSyncStarted {
    DDLogInfo(@"SyncNotificationsObserver remoteSyncStarted");
}

- (void)remoteSyncFinished {
    DDLogInfo(@"SyncNotificationsObserver remoteSyncFinished");
}

@end