//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@class STMTaskModel;

@interface MainTableController (SelectedItem)

- (void)showOptionsForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *)taskModel;

- (void)hideOptionsForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *)taskModel;

- (void)updateOptionsPositionForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *)taskModel;

- (NSIndexPath *)indexPathForSelectedItem;

- (void)updateSelectedItemVisibility;

- (void)emergencyCancelSelection;

- (void)cancelSelection;
@end