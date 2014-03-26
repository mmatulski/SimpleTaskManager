//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@class STMTaskModel;

@interface MainTableController (SelectedItem)

-(BOOL)isAnyTaskSelected;

- (BOOL)isSelectedTaskShownAtIndexPath:(NSIndexPath *)path;

#pragma mark - Frames estimations
/*
    returns frame of selected cell (if selected, otherwise returns CGRectNull)
    frame is related to UIWindow
 */
- (CGRect)selectedTaskFrame;

#pragma mark -

-(void) selectedTaskCompletedByUser;

#pragma mark - Selecting and Deselecting tasks

- (void)setSelectedTaskAtForIndexPath:(NSIndexPath *)indexPath;

- (void)changeSelectedTaskToAnotherOneAtIndexPath:(NSIndexPath *)path;

- (void)cancelSelectionAnimated:(BOOL)animated;

- (BOOL)isSelectedModelStillAvailable;

- (void)refreshSelectedItemBecauseTableHasBeenReloaded;

- (void)informDelegateAboutCurrentSelectedTaskFrame;

@end