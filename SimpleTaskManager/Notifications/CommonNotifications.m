//
// Created by Marek M on 15.01.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "CommonNotifications.h"
#import "NotificationsSender.h"


NSString * const NTFKEY_REMOTE_SYNC_STARTED = @"NTFKEY_REMOTE_SYNC_STARTED";
NSString * const NTFKEY_REMOTE_SYNC_FINISHED = @"NTFKEY_REMOTE_SYNC_FINISHED";

@implementation CommonNotifications {

}

+ (void)remoteSyncStarted {
    [NotificationsSender send:NTFKEY_REMOTE_SYNC_STARTED withData:nil];
}

+ (void)remoteSyncFinished {
    [NotificationsSender send:NTFKEY_REMOTE_SYNC_FINISHED withData:nil];
}

@end