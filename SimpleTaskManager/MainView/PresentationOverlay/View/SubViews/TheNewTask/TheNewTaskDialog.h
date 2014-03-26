//
// Created by Marek M on 11.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TheNewTaskDialog : UIView

@property(nonatomic, strong) UITextView *textView;;

- (void)setEditing:(BOOL)editing;

- (BOOL)isNameValid;

- (NSString *)taskName;
@end