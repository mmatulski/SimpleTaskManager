//
//  CommonActivityView.h
//
//  Created by Marek M on 09.10.2013.
//  Copyright (c) 2013 Tomato. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommonActivityViewDelegate;

@interface CommonActivityView : UIView {
    CGAffineTransform rotationTransform;
    CGFloat currentWidth;
    CGFloat currentHeight;
    BOOL parentIsMainWindow;
}

@property BOOL cancelable;
@property (nonatomic, weak) id<CommonActivityViewDelegate> delegate;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel* mainLabel;
@property (nonatomic, strong) UIView* mainWindowBackgroundView;
@property (nonatomic, strong) UIButton* cancelButton;
@property (nonatomic, strong) UIFont* labelFont;
@property (nonatomic, strong) UIColor* labelColor;
@property (nonatomic, copy) NSString* labelText;

-(id) initCancelable:(BOOL) shouldBeCancelable withDelegate:(id<CommonActivityViewDelegate>) delegate;
-(void) show;
-(BOOL) isShown;
-(void) close;

@end

@protocol CommonActivityViewDelegate <NSObject>

-(void) activityViewCancelled;

@optional
-(UIView*) parentViewForActivityView:(CommonActivityView *) activityView;

@end
