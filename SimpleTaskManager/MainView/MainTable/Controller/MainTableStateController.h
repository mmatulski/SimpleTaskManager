//
// Created by Marek M on 22.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationsObserver.h"
#import "SyncNotificationsObserver.h"

@class MainTableController;

@interface MainTableStateController : SyncNotificationsObserver

@property(nonatomic, weak) MainTableController *mainTableController;

@property(nonatomic) BOOL syncing;
@property(nonatomic) BOOL dragging;
@property(nonatomic) BOOL taskSelected;

- (instancetype)initWithMainTableController:(MainTableController *)mainTableController;

- (BOOL)isDraggingAvailableNow;

- (BOOL)isSelectionAvailableNow;

- (void)showInfoThatActionsAreBlockedWhenSyncing;

@end