//
//  CommonActivityView.m
//
//  Created by Marek M on 09.10.2013.
//  Copyright (c) 2013 Tomato. All rights reserved.
//

#import "CommonActivityView.h"
#import "WindowHelper.h"
#import "AppColors.h"

@implementation CommonActivityView

#define ACTIVITYVIEW_WIDTH 200.0
#define ACTIVITYVIEW_HEIGTH 140.0
#define CANCELBUTTON_HEIGTH 40.0
#define BOTTOMMARGIN 5.0
#define HORIZONTAL_MARGIN 5.0
#define CANCEL_BUTTON_TOP_MARGIN 10.0
#define LABEL_HEIGTH 40.0
#define YFORINDICATOR 50.0

-(id) initCancelable:(BOOL) shouldBeCancelable withDelegate:(id<CommonActivityViewDelegate>) delegate
{
    self = [super initWithFrame:[CommonActivityView defaultFrameForView]];
    if (self) {
        // Initialization code
        
        self.cancelable = shouldBeCancelable;
        self.delegate = delegate;
        self.backgroundColor = [AppColors messageDialogsBackgroundColor];
        
        [self prepareMainWindowBackgroundView];
        [self.mainWindowBackgroundView addSubview:self];
        
        if (self.cancelable) {
            [self addCancelButton];
        }
        
        self.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        self.labelColor = [UIColor blackColor];
        self.labelText = __(@"Please wait");
        
        [self addMainLabel];
        
        [self addActivityIndicator];
        
        [self estimateInitialSize];
        [self updateFrame];
        [self registerForNotifications];
        
//        self.cornersSize = 3.0;
//        [self roundAllCorners];
        
       // [self prepareBlurImageView];
    }
    return self;
}

-(void) dealloc{
    [self unregisterFromNotifications];
}

-(void) show{
    CGRect rect = [self frameForMainBackgroundView];
    self.mainWindowBackgroundView.frame = rect;
    
    [self updateFrame];
    [self setTransformForCurrentOrientation:false];
    [[self parentView] addSubview:self.mainWindowBackgroundView];
    
  //  [self updateBlur];
}

-(UIView*) parentView{
    UIView* parentView = nil;
    
    if ([self.delegate respondsToSelector:@selector(parentViewForActivityView:)]) {
        parentView = [self.delegate parentViewForActivityView:self];
    }
    
    if (parentView) {
        parentIsMainWindow = false;
    } else {
        parentView = [WindowHelper mainWindow];
        parentIsMainWindow = true;
    }
    return parentView;
}

-(void) checkIfHasManualParentView{
    UIView* parentView = nil;
    if ([self.delegate respondsToSelector:@selector(parentViewForActivityView:)]) {
        parentView = [self.delegate parentViewForActivityView:self];
    }
    
    parentIsMainWindow = parentView == nil;
}

-(BOOL) isShown{
    return self.mainWindowBackgroundView.superview != nil;
}

-(void) close{
    [self.mainWindowBackgroundView removeFromSuperview];
}

-(void) prepareMainWindowBackgroundView{
    self.mainWindowBackgroundView = [[UIView alloc] initWithFrame:[self frameForMainBackgroundView]];
    //self.mainWindowBackgroundView.backgroundColor = [UIColor colorWithHue:10.0f/360.0f saturation:0.0f brightness:0.0f alpha:0.5f];
    self.mainWindowBackgroundView.backgroundColor = [UIColor colorWithHue:10.0f/360.0f saturation:0.0f brightness:0.0f alpha:0.1f];
    // self.mainWindowBackgroundView.backgroundColor = [UIColor clearColor];
}

-(void) addCancelButton{
    
    UIButton* button = [[UIButton alloc] init]; //[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:__(@"Cancel") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton = button;
    
    [self addSubview:self.cancelButton];
    self.cancelButton.frame = [self frameForCancelButton];
}

-(void) addActivityIndicator{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setHidesWhenStopped:true];
    [self.activityIndicatorView startAnimating];
    
    [self addSubview:self.activityIndicatorView];
    
    self.activityIndicatorView.center = [self positionForActivityIndicatorView];
}

-(void) addMainLabel{
    self.mainLabel = [[UILabel alloc] initWithFrame:self.bounds];
	self.mainLabel.adjustsFontSizeToFitWidth = NO;
	self.mainLabel.textAlignment = NSTextAlignmentCenter;
	self.mainLabel.opaque = NO;
	self.mainLabel.backgroundColor = [UIColor clearColor];
	self.mainLabel.textColor = self.labelColor;
	self.mainLabel.font = self.labelFont;
	self.mainLabel.text = self.labelText;
    
    [self addSubview:self.mainLabel];
    
    self.mainLabel.frame = [self frameForMainLabel];
}

-(void) cancelTapped:(id) sender{
    [self.delegate activityViewCancelled];
    [self close];
}

#pragma mark - layout handling
-(void) layoutSubviews{
    [super layoutSubviews];
    
    self.cancelButton.frame = [self frameForCancelButton];
    self.mainLabel.frame = [self frameForMainLabel];
    self.activityIndicatorView.center = [self positionForActivityIndicatorView];
}

-(void) estimateInitialSize{
    currentHeight = ACTIVITYVIEW_HEIGTH;
    currentWidth = ACTIVITYVIEW_WIDTH;
    if (self.cancelable) {
        currentHeight += CANCELBUTTON_HEIGTH + CANCEL_BUTTON_TOP_MARGIN;
    }
}

+(CGRect) defaultFrameForView{
    return [self frameForViewWithWith:ACTIVITYVIEW_WIDTH andHeight:ACTIVITYVIEW_HEIGTH];
}

-(CGRect) frameForView{
    return  parentIsMainWindow ? [CommonActivityView frameForViewWithWith:currentWidth andHeight:currentHeight] : [self frameForViewWithWith:currentWidth andHeight:currentHeight];
}

-(CGRect) frameForViewWithWith:(CGFloat) width andHeight:(CGFloat) height{
    CGRect mainWindowBounds = [self parentView].bounds;
    CGPoint midPoint = CGPointMake(CGRectGetMidX(mainWindowBounds), CGRectGetMidY(mainWindowBounds));
    CGRect result = CGRectMake(midPoint.x - width/2.0, midPoint.y - height/2.0, width, height);
    return result;
}

+(CGRect) frameForViewWithWith:(CGFloat) width andHeight:(CGFloat) height{

    CGRect mainWindowBounds = [WindowHelper mainWindowBoundsIOnCurrentOrientation];
    CGPoint midPoint = CGPointMake(CGRectGetMidX(mainWindowBounds), CGRectGetMidY(mainWindowBounds));
    CGRect result = CGRectMake(midPoint.x - width/2.0, midPoint.y - height/2.0, width, height);
    return result;
}

-(CGRect) frameForMainBackgroundView{
    if (parentIsMainWindow) {
        return [CommonActivityView frameForMainBackgroundView];
    } else {
        return [self parentView].bounds;
    }
}

+(CGRect) frameForMainBackgroundView{
    CGRect result = CGRectZero;
    UIWindow* mainWindow = [WindowHelper mainWindow];
    if (mainWindow) {
        result = mainWindow.bounds;
    }
    return result;
}

-(CGRect) frameForCancelButton{
    CGRect viewBounds = self.bounds;
    CGRect result, temp;
    CGRectDivide(viewBounds, &temp, &result, BOTTOMMARGIN, CGRectMaxYEdge);
    CGRectDivide(result, &result, &temp, CANCELBUTTON_HEIGTH, CGRectMaxYEdge);
    result = CGRectInset(result, HORIZONTAL_MARGIN, 0.0);
    return result;
}

-(CGRect) frameForMainLabel{
    CGRect viewBounds = self.bounds;
    CGRect result, temp;
    
    CGRect rectForCancel = [self frameForCancelButton];
    
    if (self.cancelable) {
        CGRectDivide(viewBounds, &temp, &result, viewBounds.size.height - rectForCancel.origin.y + CANCEL_BUTTON_TOP_MARGIN, CGRectMaxYEdge);
        CGRectDivide(result, &result, &temp, LABEL_HEIGTH, CGRectMaxYEdge);
        result = CGRectInset(result, HORIZONTAL_MARGIN, 0.0);
        
    } else {
        CGRectDivide(viewBounds, &temp, &result, BOTTOMMARGIN, CGRectMaxYEdge);
        CGRectDivide(result, &result, &temp, LABEL_HEIGTH, CGRectMaxYEdge);
        result = CGRectInset(result, HORIZONTAL_MARGIN, 0.0);
    }
    
    return result;
}

-(CGPoint) positionForActivityIndicatorView{
    
    CGPoint result = CGPointMake(CGRectGetMidX(self.bounds), YFORINDICATOR);
    return result;
}

-(void) updateFrame{
    self.frame = [self frameForView];
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
    [self checkIfHasManualParentView];
    
    if (parentIsMainWindow) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat radians = 0;
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
            else { radians = (CGFloat)M_PI_2; }
            // Window coordinates differ!
        } else {
            if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
            else { radians = 0; }
        }
        
        CGRect mainWindowBounds = [WindowHelper mainWindowBoundsIOnCurrentOrientation];
        
        rotationTransform = CGAffineTransformMakeRotation(radians);
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
        }
        self.mainWindowBackgroundView.bounds = mainWindowBounds;
        [self updateFrame];
        [self.mainWindowBackgroundView setTransform:rotationTransform];
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

#pragma mark - Notifications

- (void)registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceOrientationDidChange:)
			   name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	UIView *superview = self.mainWindowBackgroundView.superview;
	if (!superview) {
		return;
	} else {
        [self setTransformForCurrentOrientation:NO];
	}
}

@end
