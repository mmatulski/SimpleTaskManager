//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogPresentationController.h"
#import "DPView.h"
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

}

- (void)closeTaskOptionsForTask:(STMTask *)task {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.view closeTaskOptions];
    }
}

- (void)updateTaskOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)offsetChange {
    if(self.currentTaskWithOptionsShown && [self.currentTaskWithOptionsShown isEqual:task]){
        [self.view updateTaskOptionsForTaskBecauseItWasScrolledBy:offsetChange];
    }
}
@end