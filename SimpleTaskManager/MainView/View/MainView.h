//
//  MainView.h
//  SimpleTaskManager
//
//  Created by Marek M on 12.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PresentationOverlayView;

@interface MainView : UIView

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *centralPanel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) PresentationOverlayView *overlayView;

- (void)viewDidAppear;
@end
