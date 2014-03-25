//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationsObserver.h"
#import "SyncNotificationsObserver.h"

@class MainViewController;


@interface MainViewControllerStateController : SyncNotificationsObserver

@property(nonatomic, weak) MainViewController *mainViewController;

@property(nonatomic) BOOL taskAdding;
@property(nonatomic) BOOL taskIsSelected;
@property(nonatomic) BOOL taskIsDragged;

@property(nonatomic) BOOL syncing;

- (instancetype)initWithMainViewController:(MainViewController *)mainViewController;

@end