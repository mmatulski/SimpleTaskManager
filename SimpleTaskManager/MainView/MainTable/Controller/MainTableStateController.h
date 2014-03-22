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
@property(nonatomic) BOOL disableDataSourceUntilDraggingFinished;

- (instancetype)initWithMainTableController:(MainTableController *)mainTableController;

- (BOOL)isDraggingAvailabelNow;

- (BOOL)isSelectionAvailabelNow;

- (BOOL)isNewTaskAvailabelNow;

- (void)showInfoThatActionsAreBlockedWhenSyncing;

- (void)refreshSelectedItemBecauseSyncHasBeenPerformed;
@end