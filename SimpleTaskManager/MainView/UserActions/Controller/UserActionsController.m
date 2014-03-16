//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "UserActionsController.h"
#import "STMTask.h"
#import "TaskOptionsView.h"
#import "UserActionsHelperView+TaskOptions.h"


@implementation UserActionsController {

}

- (instancetype)initWithView:(UserActionsHelperView *)view {
    self = [super init];
    if (self) {
        self.helperView = view;
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
    }
}

- (void)updateTaskOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)offsetChange {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.helperView updateTaskOptionsForTaskBecauseItWasScrolledBy:offsetChange];
        self.helperView.taskOptionsView.delegate = self;
    }
}

#pragma mark TaskOptionsViewDelegate methods

- (void)userHasCompletedTask {

}

- (void)userWantsDeselectTask {

}


@end