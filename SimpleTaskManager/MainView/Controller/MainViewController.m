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
#import "PresentationOverlayView.h"
#import "STMTask.h"
#import "PresentationOverlayController.h"
#import "SyncGuardService.h"
#import "RemoteLeg.h"
#import "STMTaskModel.h"
#import "MainViewControllerNotificationsObserver.h"

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
    [self prepareNotificationsObserver];
    [self preloadKeyboard];

    [[SyncGuardService sharedInstance] connectToServer];
}
- (void)preloadKeyboard {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 10.0)];
    [self.view addSubview: textField];
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    [textField removeFromSuperview];
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
    self.dialogsPresentationController = [[PresentationOverlayController alloc] initWithView:self.mainView.overlayView];
    self.dialogsPresentationController.delegate = self;
}

- (void)prepareNotificationsObserver {
    self.notificationsObserver = [[MainViewControllerNotificationsObserver alloc] initWithMainViewController:self];
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
    return self.mainView.overlayView;
}

- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel
              representedByCell:(UITableViewCell *)cell
                       animated:(BOOL)animated {
    [self.dialogsPresentationController showOptionsForTaskModel:taskModel representedByCell:cell animated:animated ];
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
