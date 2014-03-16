//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MainTableControllerDelegate.h"

@class DBController;
@class DragAndDropHandler;


@interface MainTableController : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <MainTableControllerDelegate> delegate;
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBController *dbController;
@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property(nonatomic, strong) NSIndexPath * draggedIndexPath;
@property(nonatomic, strong) DragAndDropHandler *dragAndDropHandler;

@property(nonatomic, strong) NSIndexPath *selectedIndexPath;

@property(nonatomic) CGFloat scrollOffsetWhenItemWasSelected;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)handleMemoryWarning;

- (void)deselectTask:(STMTask *)task;
@end