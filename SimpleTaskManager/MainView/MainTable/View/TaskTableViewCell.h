//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaskTableViewCell : UITableViewCell

@property(nonatomic) BOOL dropped;

@property(nonatomic, strong) CALayer *blinkingLayer;

- (void)blinkCell;
@end