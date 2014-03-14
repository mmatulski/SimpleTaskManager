//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DPView+Hints.h"
#import "MiniHintView.h"
#import "DPView+Constraints.h"
#import "TheNewTaskHintView.h"
#import "DPView+TheNewTaskDialogHandling.h"


@implementation DPView (Hints)

-(void) showOpeningTheNewTaskViewHint{
    self.hintViewForTheNewTask = [[TheNewTaskHintView alloc] initWithFrame:CGRectMake(0, 0, 70.0, 30.0)];
    [self.hintViewForTheNewTask setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.hintViewForTheNewTask];

    [self prepareHintViewLayoutsConstraintsForNewTask];

    [self.hintViewForTheNewTask setTarget:self];
    [self.hintViewForTheNewTask setAction:@selector(userDidTapOnTheNewTaskHintView)];
}

- (void)userDidTapOnTheNewTaskHintView {
    if([self canShowTheNewTaskDialog]){
        [self userStartsOpeningTheNewTaskDialog];
        [self animatedMovingTheNewTaskDialogToOpenedStatePosition:0.0 completion:NULL];
    }
}


-(void) animatedHintViewForTheNewTaskView:(void (^)(void)) completion{
    if(!self.hintViewForTheNewTask){
        [self showOpeningTheNewTaskViewHint];
    }

    [_widthConstraintForNewTaskHintView setConstant:70];
    [self layoutSubviews];
    [UIView animateWithDuration:0.5 animations:^{
        [_widthConstraintForNewTaskHintView setConstant:110];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [_widthConstraintForNewTaskHintView setConstant:50];
            [self layoutSubviews];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [_widthConstraintForNewTaskHintView setConstant:90];
                [self layoutSubviews];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [_widthConstraintForNewTaskHintView setConstant:70];
                    [self layoutSubviews];
                } completion:^(BOOL finished) {
                    [_widthConstraintForNewTaskHintView setConstant:70];
                    if(completion){
                        completion();
                    }
                }];
            }];
        }];
    }];
}

- (void)prepareHintViewLayoutsConstraintsForNewTask {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                 multiplier:1.0
                                                                                   constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _trailingConstraintForNewTaskHintView = H1;
    _widthConstraintForNewTaskHintView = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:60.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _hintViewForTheNewTaskLayoutConstraints = @[H1, H2, V1, V2];
    [self addConstraints:_hintViewForTheNewTaskLayoutConstraints];
}

@end