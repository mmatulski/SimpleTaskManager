//
// Created by Marek M on 22.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableStateController.h"
#import "MainTableController.h"
#import "MainTableDataSource.h"
#import "MainTableController+DragAndDrop.h"
#import "AppMessages.h"
#import "MainTableController+SelectedItem.h"


@implementation MainTableStateController {

}

- (instancetype)initWithMainTableController:(MainTableController *)mainTableController {
    self = [super initWithDefaultNotifications];
    if (self) {
        self.mainTableController = mainTableController;
    }

    return self;
}

//OVERRIDEN
- (void)remoteSyncStarted {
    DDLogInfo(@"MainTableStateController remoteSyncStarted");
    self.syncing = true;
}

- (void)remoteSyncFinished {
    DDLogInfo(@"MainTableStateController remoteSyncFinished");
    self.syncing = false;
}

- (void)setSyncing:(BOOL)syncing {
    if(_syncing != syncing){
        _syncing = syncing;

        self.mainTableController.dataSource.paused = _syncing;

        if (_dragging && ![self isDraggingAvailableNow]) {
            [self.mainTableController cancelDraggingAnimate:false];
            [self showInfoThatActionsAreBlockedWhenSyncing];
        }

        if (_taskSelected){
            if([self isSelectionAvailableNow]){
                if(!_syncing){
                    [self.mainTableController refreshSelectedItemBecauseSyncHasBeenPerformed];
                }
            } else {
                [self.mainTableController cancelSelection];
                [self showInfoThatActionsAreBlockedWhenSyncing];
            }
        }
    }
}

- (void)setDragging:(BOOL)dragging {
    if(_dragging != dragging){
        _dragging = dragging;

        if(_taskSelected && _dragging){
            [self.mainTableController cancelSelection];
        }
    }
}

-(void)setTaskSelected:(BOOL)taskSelected {
    _taskSelected = taskSelected;
}

//- (void)updateDataSourceState {
//    if(self.syncing){
//        DDLogInfo(@"updateDataSourceState syncing");
//        self.mainTableController.dataSource.paused = true;
//
//        if(self.dragging){
//            DDLogInfo(@"updateDataSourceState syncing _disableDataSourceUntilDraggingFinished");
//            _disableDataSourceUntilDraggingFinished = true;
//        }
//    } else {
//        DDLogInfo(@"updateDataSourceState not syncing");
//        if(_dragging && !_disableDataSourceUntilDraggingFinished){
//            DDLogInfo(@"updateDataSourceState not syncing but dragging and not _disableDataSourceUntilDraggingFinished");
//            self.mainTableController.dataSource.paused = false;
//        }
//
//        if(!_dragging){
//            DDLogInfo(@"updateDataSourceState not syncing not dragging");
//            self.mainTableController.dataSource.paused = false;
//        }
//    }
//}

-(BOOL)isDraggingAvailableNow {
    return ![self blockUserForActionsWhenSyncing] || !_syncing;
}

-(BOOL)isSelectionAvailableNow {
    return ![self blockUserForActionsWhenSyncing] || !_syncing;
}

-(BOOL) blockUserForActionsWhenSyncing{
    //TURNED OFF (it was simple solution to block user, but user could be now happy with this
    return false;
}

- (void)showInfoThatActionsAreBlockedWhenSyncing {
    [AppMessages showError:@"Sync process is in progress now"];
}

@end