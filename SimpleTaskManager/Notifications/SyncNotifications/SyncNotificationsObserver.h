//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationsObserver.h"


@interface SyncNotificationsObserver : NotificationsObserver

- (instancetype)initWithDefaultNotifications;

+ (NSArray *)notificationsKeysToObserve;

@end