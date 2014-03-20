//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "UserActionsController.h"
#import "STMTask.h"
#import "TaskOptionsView.h"
#import "UserActionsHelperView+TaskOptions.h"
#import "UserActionsHelperView+TheNewTaskDialogHandling.h"
#import "UserActionsHelperControllerDelegate.h"
#import "SyncGuardService.h"
#import "SyncingLeg.h"
#import "LocalUserLeg.h"
#import "STMTaskModel.h"


@implementation UserActionsController {

}

- (instancetype)initWithView:(UserActionsHelperView *)view {
    self = [super init];
    if (self) {
        self.helperView = view;
        self.helperView.delegate = self;
    }

    return self;
}


- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell {
    self.currentTaskWithOptionsShown = taskModel;
    [self.helperView showTaskOptionsViewForTaskModel:taskModel representedByCell:cell];
    self.helperView.taskOptionsView.delegate = self;
}

- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel {
    if(self.currentTaskWithOptionsShown){
        [self.helperView closeTaskOptions];
        self.currentTaskWithOptionsShown = nil;
    }
}

- (void)updateTaskOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)offsetChange {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:taskModel]){
        [self.helperView updateTaskOptionsForTaskBecauseItWasScrolledBy:offsetChange];
        self.helperView.taskOptionsView.delegate = self;
    }
}

#pragma mark - TaskOptionsViewDelegate methods

- (void)userHasCompletedTask {
    STMTaskModel * taskModel =  self.currentTaskWithOptionsShown;
    
    if(taskModel){
        taskModel.completed = true;
        [[SyncGuardService singleUser] markAsCompletedTaskWithId:taskModel.uid successFullBlock:^(id o) {
            DDLogInfo(@"SUCCESS");
            runOnMainThread(^{
                [self closeTaskOptionsForTaskModel:taskModel];
            });
        } failureBlock:^(NSError *error) {
            DDLogError(@"FAILED");
            taskModel.completed = false;
        }];
    }

}

- (void)userWantsDeselectTask {
    [self.delegate userWantsToDeselectTaskModel:self.currentTaskWithOptionsShown];
}

#pragma mark - UserActionsHelperViewDelegate methods

-(void)userWantsToSaveTheNewTask:(NSString *) taskName {

    [[SyncGuardService singleUser] addTaskWithName:taskName successFullBlock:^(id o) {
        DDLogInfo(@"SUCCESS");
        runOnMainThread(^{
            [self.helperView theNewTaskSaved];
        });
    } failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
    }];
}


@end