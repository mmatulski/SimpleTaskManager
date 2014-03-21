//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationsObserver.h"
#import "SyncNotificationsObserver.h"

@class MainViewController;


@interface MainViewControllerNotificationsObserver : SyncNotificationsObserver

@property(nonatomic, weak) MainViewController *mainViewController;

- (instancetype)initWithMainViewController:(MainViewController *)mainViewController;

@end