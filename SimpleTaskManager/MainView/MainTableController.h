//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBController;


@interface MainTableController : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBController *dbController;
@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property(nonatomic) int draggedRow;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)handleMemoryWarning;
@end