//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogPresentationController.h"
#import "STMTask.h"
#import "TaskOptionsView.h"
#import "DPView+TaskOptions.h"


@implementation DialogPresentationController {

}

- (instancetype)initWithView:(DPView *)view {
    self = [super init];
    if (self) {
        self.view = view;
    }

    return self;
}


- (void)showOptionsForTask:(STMTask *)task representedByCell:(UITableViewCell *)cell {
    self.currentTaskWithOptionsShown = task;
    [self.view showTaskOptionsViewForTask:task representedByCell:cell];
    self.view.taskOptionsView.delegate = self;
}

- (void)closeTaskOptionsForTask:(STMTask *)task {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.view closeTaskOptions];
    }
}

- (void)updateTaskOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)offsetChange {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.view updateTaskOptionsForTaskBecauseItWasScrolledBy:offsetChange];
        self.view.taskOptionsView.delegate = self;
    }
}

#pragma mark TaskOptionsViewDelegate methods

- (void)userHasCompletedTask {

}

- (void)taskWantsDeselectTask {

}


@end