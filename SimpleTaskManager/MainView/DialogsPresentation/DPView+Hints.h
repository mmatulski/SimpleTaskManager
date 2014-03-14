//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPView.h"

@interface DPView (Hints)

- (void)showOpeningTheNewTaskViewHint;

- (void)animatedHintViewForTheNewTaskView:(void (^)(void))completion;

- (void)removeConfirmationHintView;

- (void)removeCancelHintView;

- (void)showConfirmationHint;

- (void)showCancelHint;
@end