//
//  MainView.m
//  SimpleTaskManager
//
//  Created by Marek M on 12.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainView.h"
#import "DialogsPresentationView.h"

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    [self prepareWrapperViewForAddingTasks];
}


- (void)prepareWrapperViewForAddingTasks {
    self.dialogsPresentationView = [[DialogsPresentationView alloc] initWithDefaultFrame];

    [self addSubview:self.dialogsPresentationView];

    [self.dialogsPresentationView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:self.dialogsPresentationView.cachedLayoutConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
