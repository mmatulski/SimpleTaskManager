//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;
@class STMTaskModel;

@protocol MainTableControllerDelegate <NSObject>

-(UIView *) viewForTemporaryViewsPresentation;

- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell animated:(BOOL)animated;

- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel;

- (void)updatePositionOfOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)by;
@end