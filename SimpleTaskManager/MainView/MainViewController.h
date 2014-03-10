//
//  MainViewController.h
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBController;

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *addTaskDialog;

@property (nonatomic, strong) DBController *dbController;
@property(nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@end
