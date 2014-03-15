//
//  UIView+ScreenshootExtension.m
//
//  Created by Marek  M on 04.02.2012.
//  Copyright (c) 2012 Tomato. All rights reserved.
//

#import "UIView+ScreenshootExtension.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ScreenshootExtension)

- (UIImage *) screenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    
    CGSize imageSize = self.bounds.size;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self.layer renderInContext:context];
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    return image;
}

/*- (CGImageRef) maskImage {
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"draganddropmask" ofType:@"png"]];
    CGImageRef maskRef = image.CGImage;
    
    return maskRef;
    
}
*/


- (UIImage *) screenshotWithWidth:(CGFloat) desiredWidth{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = self.bounds.size;
    imageSize.width = desiredWidth;
    //imageSize.height *= 0.4;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self.layer renderInContext:context];   
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    return image;	
}

@end
