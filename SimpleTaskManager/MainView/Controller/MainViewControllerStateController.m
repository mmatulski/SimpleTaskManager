//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainViewControllerStateController.h"
#import "MainViewController.h"
#import "MainTableController.h"
#import "MainTableController+SelectedItem.h"
#import "MainView.h"


@implementation MainViewControllerStateController {

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
    DDLogInfo(@"MainViewControllerStateController remoteSyncStarted");
    self.syncing = true;
}

- (void)remoteSyncFinished {
    DDLogInfo(@"MainViewControllerStateController remoteSyncFinished");
    self.syncing = false;
}

- (void)setTaskIsDragged:(BOOL)taskIsDragged {
    if(_taskIsDragged != taskIsDragged){
        _taskIsDragged = taskIsDragged;

        if(_taskIsSelected && _taskIsDragged){
            [self.tableController cancelSelectionAnimated:true];
        }
    }
}

- (void)setSyncing:(BOOL)syncing {
    if(_syncing != syncing){
        _syncing = syncing;

        [self.tableController disableDataChangesListening:syncing];
        [self.mainViewController.mainView showSyncing:_syncing];
    }
}

- (void)setTaskAdding:(BOOL)taskAdding {
    if(_taskAdding != taskAdding){
        _taskAdding = taskAdding;

        if(_taskIsSelected && _taskAdding){
            [self.tableController cancelSelectionAnimated:true];
        }
    }
}


-(MainTableController *) tableController{
    return self.mainViewController.tableController;
}

@end