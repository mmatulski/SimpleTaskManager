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


//- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell animated:(BOOL)animated {
//    self.currentTaskWithOptionsShown = taskModel;
//    [self.presentationOverlayView showTaskOptionsViewForCell:cell animated:animated];
//    self.presentationOverlayView.taskOptionsView.delegate = self;
//}
//
//- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel {
//
//}
//
//- (void)updateTaskOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)offsetChange {
//    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:taskModel]){
//        [self.presentationOverlayView updateTaskOptionsForTaskBecauseItWasScrolledBy:offsetChange];
//        self.presentationOverlayView.taskOptionsView.delegate = self;
//    }
//}

#pragma mark - TaskOptionsViewDelegate methods

- (void)userHasCompletedTask {
    [self.delegate userHasChosenToMarkTaskAsCompleted];
}

- (void)userWantsDeselectTask {
    [self.delegate userHasChosenToCloseTaskOptions];
}

#pragma mark - UserActionsHelperViewDelegate methods

-(void)userWantsToSaveTheNewTask:(NSString *) taskName {

    [[SyncGuardService singleUser] addTaskWithName:taskName successFullBlock:^(id o) {
        DDLogInfo(@"SUCCESS");
        runOnMainThread(^{
            [self.presentationOverlayView theNewTaskSaved];
        });
    } failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
    }];
}



@end