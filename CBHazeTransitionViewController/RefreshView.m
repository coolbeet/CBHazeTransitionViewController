//
//  RefreshView.m
//  CBHazeTransitionViewController
//
//  Created by coolbeet on 4/5/14.
//  Copyright (c) 2014 suyu zhang. All rights reserved.
//

#import "RefreshView.h"
#import <math.h>

#define kRadius 15.f
#define kSkipedHeight 60.f

@interface RefreshView ()
{
    CGFloat offsetY;
    RefreshViewDirection moveDirection;
}

@property (nonatomic, assign) UIScrollView *scrollView;

@end

@implementation RefreshView

static inline CGFloat lerp(CGFloat a, CGFloat b, CGFloat p)
{
    return a + (b - a) * p;
}

- (id)initWithFrame:(CGRect)frame inScrollView:(UIScrollView *)scrollView withDirection:(RefreshViewDirection)direction;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = scrollView;
        moveDirection = direction;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    offsetY = [[change objectForKey:@"new"] CGPointValue].y;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (moveDirection == RefreshViewDirectionDown) {
        [[UIColor colorWithPatternImage:[UIImage imageNamed:@"settingPattern"]] setFill];
        CGFloat circleY;
        if (offsetY <= kSkipedHeight)
            circleY = offsetY*118.f/kSkipedHeight-kRadius;
        else
            circleY = kSkipedHeight*118.f/kSkipedHeight-kRadius+offsetY-kSkipedHeight;
        [path moveToPoint:CGPointMake(0, 0)];
        CGPoint leftCp1 = CGPointMake(lerp(0, 160-kRadius, 0.4), lerp(0, circleY, 0.1));
        CGPoint leftCp2 = CGPointMake(lerp(0, 160-kRadius, 1), lerp(0, circleY, 0.0));
        [path addCurveToPoint:CGPointMake(160-kRadius, circleY) controlPoint1:leftCp1 controlPoint2:leftCp2];
        [path addArcWithCenter:CGPointMake(CGRectGetMidX(rect), circleY) radius:kRadius startAngle:M_PI endAngle:0 clockwise:NO];
        CGPoint rightCp1 = CGPointMake(lerp(320, 160+kRadius, 1), lerp(0, circleY, 0.0));
        CGPoint rightCp2 = CGPointMake(lerp(320, 160+kRadius, 0.4), lerp(0, circleY, 0.1));
        [path addCurveToPoint:CGPointMake(320, 0) controlPoint1:rightCp1 controlPoint2:rightCp2];
        [path addLineToPoint:CGPointMake(0, 0)];
        [path closePath];
        [path fill];
    }
    else if (offsetY <= -kSkipedHeight) {
        [[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainPattern"]] setFill];
        CGFloat circleY = rect.size.height+offsetY+kRadius+kSkipedHeight;
        [path moveToPoint:CGPointMake(0, rect.size.height)];
        CGPoint leftCp1 = CGPointMake(lerp(0, 160-kRadius, 0.4), lerp(circleY, circleY-offsetY-kSkipedHeight, 0.6));
        CGPoint leftCp2 = CGPointMake(lerp(0, 160-kRadius, 1), lerp(circleY, circleY-offsetY-kSkipedHeight, 0.6));
        [path addCurveToPoint:CGPointMake(160-kRadius, circleY) controlPoint1:leftCp1 controlPoint2:leftCp2];
        [path addArcWithCenter:CGPointMake(CGRectGetMidX(rect), circleY) radius:kRadius startAngle:-M_PI endAngle:0 clockwise:YES];
        CGPoint rightCp1 = CGPointMake(lerp(320, 160+kRadius, 0.4), lerp(circleY, circleY-offsetY-kSkipedHeight, 0.6));
        CGPoint rightCp2 = CGPointMake(lerp(320, 160+kRadius, 1), lerp(circleY, circleY-offsetY-kSkipedHeight, 0.6));
        [path addCurveToPoint:CGPointMake(320, rect.size.height) controlPoint1:rightCp2 controlPoint2:rightCp1];
        [path addLineToPoint:CGPointMake(0, rect.size.height)];
        [path closePath];
        [path fill];
    }

}

@end
