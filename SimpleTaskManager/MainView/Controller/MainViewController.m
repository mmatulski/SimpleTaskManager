//
//  MainViewController.m
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "MainTableController.h"
#import "UserActionsHelperView.h"
#import "STMTask.h"
#import "UserActionsController.h"
#import "SyncGuardService.h"
#import "RemoteLeg.h"
#import "STMTaskModel.h"

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
    [self prepareDialogsPresentationController];

    [[SyncGuardService sharedInstance] connectToServer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.mainView viewDidAppear];


}

- (void)prepareTableController {
    self.tableController = [[MainTableController alloc] initWithTableView:self.mainView.tableView];
    self.tableController.delegate = self;
}

- (void)prepareDialogsPresentationController {
    self.dialogsPresentationController = [[UserActionsController alloc] initWithView:self.mainView.dialogsPresentationView];
    self.dialogsPresentationController.delegate = self;
}

- (MainView *)mainView {
    return MakeSafeCast(self.view, [MainView class]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    [self.tableController handleMemoryWarning];
}

#pragma mark MainTableControllerDelegate methods

- (UIView *)viewForTemporaryViewsPresentation {
    return self.mainView.dialogsPresentationView;
}

- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell {
    [self.dialogsPresentationController showOptionsForTaskModel:taskModel representedByCell:cell];
}

- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel {
    [self.dialogsPresentationController closeTaskOptionsForTaskModel:taskModel];
}

- (void)updatePositionOfOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)offsetChange {
    [self.dialogsPresentationController updateTaskOptionsForTaskModel:taskModel becauseItWasScrolledBy: offsetChange];
}

#pragma mark - UserActionsControllerDelegate methods

- (void)userWantsToDeselectTaskModel:(STMTaskModel *)taskModel {
    [self.tableController deselectTaskModel:taskModel];
}

@end
