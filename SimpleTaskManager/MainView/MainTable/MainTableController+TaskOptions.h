//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@interface MainTableController (TaskOptions)
- (void)showOptionsForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)hideOptionsForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)updateOptionsPositionForItemAtIndexPath:(NSIndexPath *)indexPath;
@end