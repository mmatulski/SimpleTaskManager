//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;

@protocol MainTableControllerDelegate <NSObject>

-(UIView *) viewForTemporaryViewsPresentation;

- (void)showOptionsForTask:(STMTask *)task representedByCell:(UITableViewCell *)cell;

- (void)closeTaskOptionsForTask:(STMTask *)task;

- (void)updatePositionOfOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)by;
@end