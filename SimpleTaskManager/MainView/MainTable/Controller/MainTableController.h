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

@interface MainTableController : NSObject <UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <MainTableControllerDelegate> delegate;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) MainTableDataSource *dataSource;

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property(nonatomic, strong) DragAndDropHandler *dragAndDropHandler;
@property(nonatomic, strong) STMTaskModel * draggedItemModel;
@property(nonatomic, strong) NSIndexPath *lastTargetForDraggedIndexPath;

@property(nonatomic, strong) STMTaskModel * selectedTaskModel;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)disableDataChangesListening:(BOOL)shouldStopListening;

- (void)showNewTask:(STMTask *)task;

- (void)highlightCellForTaskModel:(STMTaskModel *)model;

@end