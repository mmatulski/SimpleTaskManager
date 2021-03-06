//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBController;
@class STMTaskModel;
@class STMTask;

@interface MainTableDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBController *dbController;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@property(nonatomic, strong) STMTaskModel *modelForTaskBeingMoved;
@property(nonatomic, strong) NSIndexPath *currentTargetIndexPathForItemBeingMoved;

@property(nonatomic) BOOL paused;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)reloadDataSourceAndTable;

- (NSIndexPath *)indexPathForTaskModel:(STMTaskModel *)model;

- (BOOL)doesTaskForModelStillExistInFetchedResultsControllerData:(STMTaskModel *)model;

- (STMTask *)taskForIndexPath:(NSIndexPath *)indexPath;

- (STMTask *)existingTaskFromDBForModel:(STMTaskModel *)model;

- (void)cellForTaskModel:(STMTaskModel *)model hasBeenDraggedFromIndexPath:(NSIndexPath *)path animateHiding:(bool)animated;

- (void)draggedCellHasBeenMovedToIndexPath:(NSIndexPath *)indexPath animateShowing:(bool)animated;


- (void)draggedCellHasBeenReturned:(BOOL)animateShowingItAgain;

- (NSUInteger)estimatedTaskIndexForTargetIndexPath:(NSIndexPath *)path;

- (void)resetDraggedCell;

- (NSUInteger)numberOfAllTasksInDB;

- (NSUInteger)numberOfAllTasksInFetchedResultsController;

- (void)taskCompleted;

@end