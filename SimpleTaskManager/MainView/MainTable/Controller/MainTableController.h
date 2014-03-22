//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MainTableControllerDelegate.h"

@class DBController;
@class DragAndDropHandler;
@class STMTaskModel;
@class STMTask;
@class MainTableDataSource;
@class MainTableStateController;

@interface MainTableController : NSObject <UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <MainTableControllerDelegate> delegate;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) MainTableDataSource *dataSource;
@property(nonatomic, strong) MainTableStateController *stateController;

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property(nonatomic, strong) DragAndDropHandler *dragAndDropHandler;
@property(nonatomic, strong) STMTaskModel * draggedItemModel;
@property(nonatomic, strong) NSIndexPath * temporaryTargetForDraggedIndexPath;

@property(nonatomic, strong) STMTaskModel * selectedItemModel;
@property(nonatomic) CGFloat scrollOffsetWhenItemWasSelected;

//@property(nonatomic) BOOL shouldCancelSelection;
//
//@property(nonatomic) BOOL shouldCancelDragging;
//
//@property(nonatomic) BOOL selectedItemWillBeRemoved;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)handleMemoryWarning;

- (void)deselectTaskModel:(STMTaskModel *)taskModel;

- (void)refreshSelectedItemBecauseSyncHasBeenPerformed;
@end