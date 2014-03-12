//
//  MainViewController.h
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainView;
@class MainTableController;

@interface MainViewController : UIViewController

@property(nonatomic, strong) MainTableController * tableController;

-(MainView*) mainView;

@end
