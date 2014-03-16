//
//  MainViewController.h
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableControllerDelegate.h"

@class MainView;
@class MainTableController;
@class UserActionsController;

@interface MainViewController : UIViewController <MainTableControllerDelegate>

@property(nonatomic, strong) MainTableController * tableController;
@property(nonatomic, strong) UserActionsController *dialogsPresentationController;

-(MainView*) mainView;

@end
