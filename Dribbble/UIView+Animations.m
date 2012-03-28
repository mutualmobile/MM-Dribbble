//
//  UIView+Animations.m
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIView+Animations.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (UIView_Animations)
+ (UIView*)clearZeroRectView{
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
- (void)applyPopUpAnimation:(CGFloat)duration withAlpha:(BOOL)wAlpha{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.01, 0.01, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.11, 1.11, 1);
    CATransform3D scale3 = CATransform3DMakeScale(.957, .957, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.8],
                           [NSNumber numberWithFloat:1.0],
                           nil];    
    [animation setKeyTimes:frameTimes];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = duration;
    group.fillMode = kCAFillModeForwards;
    if (wAlpha) {
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [alphaAnimation setFromValue:[NSNumber numberWithFloat:0.f]];
        [alphaAnimation setToValue:[NSNumber numberWithFloat:1.f]];    
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        alphaAnimation.duration = duration;
        group.animations = [NSArray arrayWithObjects:animation,alphaAnimation, nil];
        self.layer.opacity = 1.0;
    }
    else{
        group.animations = [NSArray arrayWithObjects:animation, nil];
    }
    [self.layer addAnimation:group forKey:@"applyPopUpAnimation"];
}

- (void) attachPopUpAnimation:(NSTimeInterval)duration{
    if (duration<.2) {
        duration = .2;
    }
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.05, 1.05, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.975, 0.975, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];    
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [alphaAnimation setFromValue:[NSNumber numberWithFloat:0.f]];
    [alphaAnimation setToValue:[NSNumber numberWithFloat:1.f]];    
    alphaAnimation.duration = duration;
    
    [self.layer addAnimation:animation forKey:@"popup"];
    //[self.layer addAnimation:alphaAnimation forKey:@"alphaIn"];
}
- (void) attachPopOutAnimation:(NSTimeInterval)duration delegate:(id)delegate{
    if (duration<.2) {
        duration = .2;
    }
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale2 = CATransform3DMakeScale(1.0, 1.0, 1);
//    CATransform3D scale3 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale4 = CATransform3DMakeScale(0.35, 0.35, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale2],
                            //[NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           //[NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:1.0],
                           nil];    
    [animation setKeyTimes:frameTimes];        
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    animation.delegate = delegate;
    
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [alphaAnimation setFromValue:[NSNumber numberWithFloat:1.f]];
    [alphaAnimation setToValue:[NSNumber numberWithFloat:0.f]];    
    alphaAnimation.duration = duration;
    alphaAnimation.removedOnCompletion = NO;
    alphaAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:alphaAnimation forKey:@"alphaOut"];
    [self.layer addAnimation:animation forKey:@"popout"];
}
- (void)attachAnnotationPopupAnimation:(NSTimeInterval)duration{
    [UIView animateWithDuration:.1f delay:0.f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.alpha = 1.f;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:.1f delay:0.f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.975f, 0.975f);
        }completion:^(BOOL finished){
            [UIView animateWithDuration:.07f delay:0.f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseInOut animations:^{
                self.transform = CGAffineTransformIdentity; 
            }completion:^(BOOL finished){
                
            }];
        }];
    }];
}

+ (void)exclusiveAnimateWithDuration:(NSTimeInterval)duration 
                               delay:(NSTimeInterval)delay 
                             options:(UIViewAnimationOptions)options 
                          animations:(void (^)(void))animations 
                          completion:(void (^)(BOOL finished))completion {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self animateWithDuration:duration 
                        delay:delay
                      options:options
                   animations:animations 
                   completion:^(BOOL finished){
                       if (completion != NULL) {
                           completion(finished);
                       }
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   }];
}

+ (void)exclusiveAnimateWithDuration:(NSTimeInterval)duration 
                          animations:(void (^)(void))animations 
                          completion:(void (^)(BOOL finished))completion {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self animateWithDuration:duration 
                   animations:animations 
                   completion:^(BOOL finished){
                       if (completion != NULL) {
                           completion(finished);
                       }
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   }];
}

+ (void)exclusiveAnimateWithDuration:(NSTimeInterval)duration 
                          animations:(void (^)(void))animations {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self animateWithDuration:duration 
                   animations:animations 
                   completion:^(BOOL finished){
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   }];
}

@end
