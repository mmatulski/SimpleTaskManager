//
//  MainViewController.h
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableControllerDelegate.h"
#import "PresentationOverlayControllerDelegate.h"

@class MainView;
@class MainTableController;
@class PresentationOverlayController;
@class MainViewControllerStateController;

@interface MainViewController : UIViewController <MainTableControllerDelegate, PresentationOverlayControllerDelegate>

@property(nonatomic, strong) MainTableController * tableController;
@property(nonatomic, strong) PresentationOverlayController *presentationOverlayController;
@property(nonatomic, strong) MainViewControllerStateController *stateController;

-(MainView*) mainView;

@end
