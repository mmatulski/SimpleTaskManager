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
#import "LocalUserLeg.h"
#import "STMTaskModel.h"
#import "MainViewControllerStateController.h"
#import "MainTableController+SelectedItem.h"
#import "MainViewController+OperationsForTasks.h"
#import "AppMessages.h"
#import "NSError+Log.h"

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

    self.mainView.generatorSwitch.on = [[SyncGuardService sharedInstance] isConnected];
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
    self.presentationOverlayController = [[PresentationOverlayController alloc] initWithView:self.mainView.overlayView];
    self.presentationOverlayController.delegate = self;
}

- (void)prepareNotificationsObserver {
    self.stateController = [[MainViewControllerStateController alloc] initWithMainViewController:self];
}

- (MainView *)mainView {
    return MakeSafeCast(self.view, [MainView class]);
}

- (IBAction)generatorSwitchChanged:(id)sender {
    if(self.mainView.generatorSwitch.on){
        if(![[SyncGuardService sharedInstance] isConnected]){
            [[SyncGuardService sharedInstance] connectToServer];
        }
    } else {
        if([[SyncGuardService sharedInstance] isConnected]){
            [[SyncGuardService sharedInstance] disconnectFromServer];
        }
    }
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

- (void)taskHasBeenSelected {
    self.stateController.taskIsSelected = true;
    CGRect frameForSelectedTask = [self.tableController selectedTaskFrame];
    [self.presentationOverlayController showTaskOptionsForCellWithFrame:frameForSelectedTask animated:true];

    //self.stateController.syncing = true;
}

- (void)taskHasBeenUnselected {
    self.stateController.taskIsSelected = false;
    [self.presentationOverlayController closeTaskOptionsAnimated:true];
}

- (void)anotherTaskHasBeenSelected {

    // in this case the behaviour is the same
    // because method for showing options view chooses movement
    // if optionsview is shown

    [self taskHasBeenSelected];
}

- (void)selectedTaskFrameChanged:(CGRect)changedFrame {
    [self.presentationOverlayController updateOptionsViewFrameForCellWithFrame:changedFrame
                                                                      animated:false];
}

- (void)taskHasBeenDragged {
    self.stateController.taskIsDragged = true;
}

- (void)taskHasBeenDropped {
    self.stateController.taskIsDragged = false;
}

- (void)taskDraggingCancelled {
    self.stateController.taskIsDragged = false;
}

#pragma mark - PresentationOverlayControllerDelegate methods

- (void)userHasChosenToMarkTaskAsCompleted {

    [self markSelectedTaskAsCompleted];
}

- (void)userHasChosenToCloseTaskOptions {
    [self.tableController cancelSelectionAnimated:true];
}

- (void)userWantsToSaveTheNewTask:(NSString *)taskName {
    BlockWeakSelf selfWeak = self;
    [[SyncGuardService singleUser] addTaskWithName:taskName successFullBlock:^(id obj) {
        DDLogInfo(@"SUCCESS");
        runOnMainThread(^{
            STMTask *addedTask = MakeSafeCast(obj, [STMTask class]);
            [selfWeak.presentationOverlayController theNewTaskSaved];
            selfWeak.stateController.taskAdding = false;
            [selfWeak.tableController showNewTask:addedTask];
        });
    } failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
        [AppMessages showMessage:[NSString stringWithFormat:@"Problem with adding new task %@", [err localizedDescription]]];
        [err log];
    }];
}


- (void)userHasOpenedNewTaskDialog {
    self.stateController.taskAdding = true;
}

- (void)userHasClosedNewTaskDialog {
    self.stateController.taskAdding = false;
}


@end
