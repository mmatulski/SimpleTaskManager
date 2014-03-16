//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "UserActionsController.h"
#import "STMTask.h"
#import "TaskOptionsView.h"
#import "UserActionsHelperView+TaskOptions.h"
#import "DBController.h"
#import "DBAccess.h"
#import "UserActionsHelperView+TheNewTaskDialogHandling.h"
#import "UserActionsHelperControllerDelegate.h"


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


- (void)showOptionsForTask:(STMTask *)task representedByCell:(UITableViewCell *)cell {
    self.currentTaskWithOptionsShown = task;
    [self.helperView showTaskOptionsViewForTask:task representedByCell:cell];
    self.helperView.taskOptionsView.delegate = self;
}

- (void)closeTaskOptionsForTask:(STMTask *)task {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.helperView closeTaskOptions];
        self.currentTaskWithOptionsShown = nil;
    }
}

- (void)updateTaskOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)offsetChange {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.helperView updateTaskOptionsForTaskBecauseItWasScrolledBy:offsetChange];
        self.helperView.taskOptionsView.delegate = self;
    }
}

#pragma mark - TaskOptionsViewDelegate methods

- (void)userHasCompletedTask {
    STMTask * task =  self.currentTaskWithOptionsShown;

    if(task){
        DBController *dbController = [DBAccess createBackgroundController];
        [dbController markAsCompletedTaskWithId:task.uid successFullBlock:^() {
            DDLogInfo(@"SUCCESS");
            runOnMainThread(^{
                [self closeTaskOptionsForTask:task];
            }
            );

        } failureBlock:^(NSError *err) {
            DDLogError(@"FAILED");
        }];
    }

}

- (void)userWantsDeselectTask {
    [self.delegate userWantsToDeselectTask:self.currentTaskWithOptionsShown];
}

#pragma mark - UserActionsHelperViewDelegate methods

-(void)userWantsToSaveTheNewTask:(NSString *) taskName {
    DBController *dbController = [DBAccess createBackgroundController];
    [dbController addTaskWithName:taskName successFullBlock:^(STMTask *task) {
        DDLogInfo(@"SUCCESS");
        runOnMainThread(^{
            [self.helperView theNewTaskSaved];
        });
    }                failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
    }];
}


@end