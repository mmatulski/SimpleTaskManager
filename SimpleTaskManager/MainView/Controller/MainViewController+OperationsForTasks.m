#import "MainViewControllerStateController.h"//
// Created by Marek M on 25.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainViewController+OperationsForTasks.h"
#import "STMTaskModel.h"
#import "SyncGuardService.h"
#import "LocalUserLeg.h"
#import "MainTableController.h"
#import "NSError+Log.h"
#import "PresentationOverlayController.h"
#import "MainTableController+SelectedItem.h"
#import "AppMessages.h"
#import "STMTask.h"


@implementation MainViewController (OperationsForTasks)

- (void)markSelectedTaskAsCompleted {
    STMTaskModel * taskModel = self.tableController.selectedTaskModel;

    if(taskModel){
        [AppMessages showActivity];

        BlockWeakSelf selfWeak = self;
        [[SyncGuardService singleUser] markAsCompletedTaskWithId:taskModel.uid successFullBlock:^(id o) {
            [AppMessages closeActivity];
            DDLogInfo(@"markSelectedTaskAsCompleted finished with success");
            runOnMainThread(^{
                [selfWeak.presentationOverlayController closeTaskOptionsAnimated:true];
                // if tabledatasource was paused because of sync during thie operation, then tableview could not handle update for reomved cell
                // we need to send info to tablecontroller to ensure it is no more shown
                [selfWeak.tableController selectedTaskCompletedByUser];
                self.stateController.taskIsSelected = false;
            });
        } failureBlock:^(NSError *error) {
            [AppMessages closeActivity];
            DDLogError(@"markSelectedTaskAsCompleted failed");
            [error log];
            [AppMessages showError:[NSString stringWithFormat:@"Task could not be set as completed %@", [error localizedDescription]]];
        }];
    }
}

- (void)saveTaskWithName:(NSString *)taskName {
    BlockWeakSelf selfWeak = self;
    [AppMessages showActivity];
    [[SyncGuardService singleUser] addTaskWithName:taskName successFullBlock:^(id obj) {
        [AppMessages closeActivity];
        DDLogInfo(@"SUCCESS");
        runOnMainThread(^{
            STMTask *addedTask = MakeSafeCast(obj, [STMTask class]);
            [selfWeak.presentationOverlayController theNewTaskSaved];
            selfWeak.stateController.taskAdding = false;
            [selfWeak.tableController showNewTask:addedTask];
        });
    } failureBlock:^(NSError *err) {
        [AppMessages closeActivity];
        DDLogError(@"FAILED");
        [AppMessages showMessage:[NSString stringWithFormat:@"Problem with adding new task %@", [err localizedDescription]]];
        [err log];
    }];
}

@end