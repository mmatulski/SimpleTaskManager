//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "AppColors.h"


@implementation TaskTableViewCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.backgroundColor = [AppColors cellBackgroundColor];
    self.textLabel.textColor = [AppColors cellTextColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
    self.textLabel.backgroundColor = [AppColors cellBackgroundColor];

    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [AppColors selectedCellBackgroundColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.dropped = false;
}

- (void)setDropped:(BOOL)dropped {
    _dropped = dropped;

    [self updateBackgroundColor];

}



- (void)updateBackgroundColor {
    if(self.dropped){
        self.backgroundColor = [AppColors cellDraggingTargetBackgroundColor];
    } else {
        self.backgroundColor = [AppColors cellBackgroundColor];
    }
}

- (void)blinkCell {
    UIView* blinkingView = [[UIView alloc] initWithFrame:self.bounds];
    blinkingView.backgroundColor = [AppColors cellBlinkingColor];
    blinkingView.alpha = 0.0;
    [self.contentView addSubview:blinkingView];
    [UIView animateWithDuration:0.5 delay:0.0 options:nil animations:^{
        blinkingView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [blinkingView removeFromSuperview];
    }];
}

@end