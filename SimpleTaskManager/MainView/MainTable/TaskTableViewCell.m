//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "STMColors.h"


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
    self.backgroundColor = [STMColors cellBackgroundColor];
    self.textLabel.textColor = [STMColors cellTextColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
    self.textLabel.backgroundColor = [STMColors cellBackgroundColor];
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
        self.backgroundColor = [UIColor greenColor];
    } else {
        self.backgroundColor = [STMColors cellBackgroundColor];
    }
}

@end