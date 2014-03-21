//
//  MainViewController.h
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableControllerDelegate.h"
#import "UserActionsHelperControllerDelegate.h"

@class MainView;
@class MainTableController;
@class UserActionsController;
@class MainViewControllerNotificationsObserver;

@interface MainViewController : UIViewController <MainTableControllerDelegate, UserActionsHelperControllerDelegate>

@property(nonatomic, strong) MainTableController * tableController;
@property(nonatomic, strong) UserActionsController *dialogsPresentationController;
@property(nonatomic, strong) MainViewControllerNotificationsObserver *notificationsObserver;

-(MainView*) mainView;

@end
