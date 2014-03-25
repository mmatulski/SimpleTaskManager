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

@interface MainTableController : NSObject <UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>{
    UITableViewScrollPosition _scrollPositionWhenSelectingItem;
}

@property(nonatomic, weak) id <MainTableControllerDelegate> delegate;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) MainTableDataSource *dataSource;

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property(nonatomic, strong) DragAndDropHandler *dragAndDropHandler;
@property(nonatomic, strong) STMTaskModel * draggedItemModel;
@property(nonatomic, strong) NSIndexPath * temporaryTargetForDraggedIndexPath;

@property(nonatomic, strong) STMTaskModel * selectedTaskModel;
@property(nonatomic) CGFloat scrollOffsetWhenItemWasSelected;

//@property(nonatomic) BOOL shouldCancelSelection;
//
//@property(nonatomic) BOOL shouldCancelDragging;
//
//@property(nonatomic) BOOL selectedItemWillBeRemoved;

- (instancetype)initWithTableView:(UITableView *)tableView;

//- (void)setSelectedItemModel:(STMTaskModel *)selectedItemModel animated:(BOOL)animated;
//
//
//- (void)deselectTaskModel:(STMTaskModel *)taskModel;
//
//- (void)refreshSelectedItemBecauseTableHasBeenReloaded;

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)disableDataChangesListening:(BOOL)shouldStopListening;

- (void)handleMemoryWarning;

@end