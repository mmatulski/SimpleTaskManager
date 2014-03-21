//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBController;
@class STMTaskModel;
@class STMTask;
@protocol MainTableDataSourceDelegate;

@interface MainTableDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property(nonatomic, weak) id <MainTableDataSourceDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBController *dbController;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (NSIndexPath *)indexPathForTaskModel:(STMTaskModel *)model;

- (STMTask *)taskForIndexPath:(NSIndexPath *)indexPath;

- (STMTask *)taskForModel:(STMTaskModel *)model;


@end