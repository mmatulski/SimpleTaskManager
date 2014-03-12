//
//  MainViewController.m
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainViewController.h"
#import "DBAccess.h"
#import "DBController.h"
#import "STMTask.h"
#import "MainView.h"
#import "MainTableController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    [self prepareTableController];
}

- (void)prepareTableController {
    self.tableController = [[MainTableController alloc] initWithTableView:self.mainView.tableView];
}

- (MainView *)mainView {
    return MakeSafeCast(self.view, [MainView class]);
}




//- (void)showAddTaskDialog {
//    self.addTaskDialog.hidden = false;
//    [self.addTaskDialog.superview bringSubviewToFront:self.addTaskDialog];
//}
//
//- (IBAction)confirmAddingTask:(id)sender {
//
//    self.addTaskDialog.hidden = true;
//    [self.tableView.superview bringSubviewToFront:self.tableView];
//
//    DBController *dbController = [DBAccess createBackgroundController];
//    [dbController addTaskWithName:@"Go to sleep" successFullBlock:^(STMTask *task) {
//        DDLogInfo(@"SUCCESS");
//    } failureBlock:^(NSError *err) {
//        DDLogError(@"FAILED");
//    }];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    [self.tableController handleMemoryWarning];
}




@end
