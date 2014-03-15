//
//  UIView+ScreenshootExtension.h
//
//  Created by Marek  M on 04.02.2012.
//  Copyright (c) 2012 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (ScreenshootExtension)

- (UIImage *) screenshot;
- (UIImage *) screenshotWithWidth:(CGFloat) desiredWidth;

@end
