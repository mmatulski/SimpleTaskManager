//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayController.h"
#import "STMTask.h"
#import "TaskOptionsView.h"
#import "PresentationOverlayView+TaskOptions.h"
#import "PresentationOverlayView+TheNewTaskDialogHandling.h"
#import "PresentationOverlayControllerDelegate.h"
#import "SyncGuardService.h"
#import "SyncingLeg.h"
#import "LocalUserLeg.h"
#import "STMTaskModel.h"
#import "AppMessages.h"
#import "NSError+Log.h"


@implementation PresentationOverlayController {

}

- (instancetype)initWithView:(PresentationOverlayView *)view {
    self = [super init];
    if (self) {
        self.presentationOverlayView = view;
        self.presentationOverlayView.delegate = self;
    }

    return self;
}

#pragma mark - Task Options

- (void)showTaskOptionsForCellWithFrame:(CGRect)cellFrame animated:(BOOL)animated {
    [self.presentationOverlayView showTaskOptionsForCellWithFrame:cellFrame animated:animated];
    self.presentationOverlayView.taskOptionsView.delegate = self;
}

- (void)updateOptionsViewFrameForCellWithFrame:(CGRect)cellFrame animated:(BOOL)animated {
    [self.presentationOverlayView showTaskOptionsForCellWithFrame:cellFrame animated:animated];
}

- (void)closeTaskOptionsAnimated:(BOOL)animated {
    [self.presentationOverlayView closeTaskOptionsAnimated:animated];
}

#pragma mark -

-(void) theNewTaskSaved{
    [self.presentationOverlayView theNewTaskSaved];
}

#pragma mark - TaskOptionsViewDelegate methods

- (void)userHasCompletedTask {
    [self.delegate userHasChosenToMarkTaskAsCompleted];
}

- (void)userWantsDeselectTask {
    [self.delegate userHasChosenToCloseTaskOptions];
}

#pragma mark - PresentationOverlayViewDelegate methods

- (void)theNewTaskDialogOpened {
    [self.delegate userHasOpenedNewTaskDialog];
}

- (void)theNewTaskDialogClosed {
    [self.delegate userHasClosedNewTaskDialog];
}

- (void)userWantsToSaveTheNewTask:(NSString *)taskName {

    [self.delegate userWantsToSaveTheNewTask:taskName];

}


@end