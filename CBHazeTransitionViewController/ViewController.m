//
//  ViewController.m
//  CBHazeTransitionViewController
//
//  Created by coolbeet on 4/3/14.
//  Copyright (c) 2014 suyu zhang. All rights reserved.
//

#import "ViewController.h"
#import "RefreshView.h"
#import <AudioToolbox/AudioServices.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <stdlib.h>
#include <ctype.h>

#define TEXT_COLOR1 [UIColor colorWithRed:117.f/255.f green:117.f/255.f blue:117.f/255.f alpha:1.f]
#define TEXT_COLOR2 [UIColor colorWithRed:181.f/255.f green:181.f/255.f blue:181.f/255.f alpha:0.8f]
#define kBannerViewHeight 60.f
#define kUpperBottomLabelHeight 118.f
#define kLowerRefreshViewTriggeredHeight 120.f

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIScrollView *upperScrollView;
@property (nonatomic, strong) UIScrollView *lowerScrollView;
@property (nonatomic, strong) NSLayoutConstraint *upperRefreshTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *lowerRefreshBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bgViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *lowerBottomLabelBottomConstraint;
@property (nonatomic, strong) UIImageView *chicagoView;
@property (nonatomic, strong) UIImageView *settingView;
@property (nonatomic, strong) UILabel *lowerBottomLabel;
@property (nonatomic, strong) UILabel *upperBottomLabel;
@property (nonatomic, strong) RefreshView *upperRefreshView;
@property (nonatomic, strong) RefreshView *lowerRefreshView;
@property BOOL upperTrigered;
@property BOOL lowerTrigered;
@property BOOL vibrated;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bgView = [UIView new];
    self.bgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bgView];
    
    self.upperScrollView = [UIScrollView new];
    self.upperScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.upperScrollView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:self.upperScrollView];
    self.upperScrollView.delegate = self;
    self.upperScrollView.alwaysBounceVertical = YES;
    
    UIView *upperContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settingBg"]];
    upperContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.upperScrollView addSubview:upperContentView];
    
    self.upperBottomLabel = [UILabel new];
    self.upperBottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.upperBottomLabel.backgroundColor = [UIColor clearColor];
    self.upperBottomLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16.f];
    self.upperBottomLabel.textColor = TEXT_COLOR1;
    self.upperBottomLabel.textAlignment = NSTextAlignmentCenter;
    self.upperBottomLabel.text = @"What will your verse be?";
    self.upperBottomLabel.numberOfLines = 0;
    [self.upperScrollView addSubview:self.upperBottomLabel];
    
    self.upperRefreshView = [[RefreshView alloc] initWithFrame:CGRectZero inScrollView:self.upperScrollView withDirection:RefreshViewDirectionDown];
    self.upperRefreshView.translatesAutoresizingMaskIntoConstraints = NO;
    self.upperRefreshView.backgroundColor = [UIColor clearColor];
    [self.upperScrollView addSubview:self.upperRefreshView];
    
    self.chicagoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weatherRefresh"]];
    self.chicagoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chicagoView.alpha = 0.7f;
    [self.upperScrollView addSubview:self.chicagoView];
    
    self.lowerScrollView = [UIScrollView new];
    self.lowerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lowerScrollView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:self.lowerScrollView];
    self.lowerScrollView.delegate = self;
    self.lowerScrollView.alwaysBounceVertical = YES;
    
    UIImageView *lowerContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBg"]];
    lowerContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.lowerScrollView addSubview:lowerContentView];

    self.lowerBottomLabel = [UILabel new];
    self.lowerBottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.lowerBottomLabel.backgroundColor = [UIColor clearColor];
    self.lowerBottomLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14.f];
    self.lowerBottomLabel.textColor = TEXT_COLOR2;
    self.lowerBottomLabel.textAlignment = NSTextAlignmentCenter;
    self.lowerBottomLabel.text = @"made by coolbeet.";
    [self.lowerScrollView addSubview:self.lowerBottomLabel];
    
    [self.lowerScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lowerBottomLabel]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_lowerBottomLabel)]];
    self.lowerBottomLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:lowerContentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.lowerBottomLabel attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    [self.lowerScrollView addConstraint:self.lowerBottomLabelBottomConstraint];
    [self.lowerScrollView bringSubviewToFront:lowerContentView];
    
    self.lowerRefreshView = [[RefreshView alloc] initWithFrame:CGRectZero inScrollView:self.lowerScrollView withDirection:RefreshViewDirectionUp];
    self.lowerRefreshView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lowerRefreshView.backgroundColor = [UIColor clearColor];
    [self.lowerScrollView addSubview:self.lowerRefreshView];
    
    self.settingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settingRefresh"]];
    self.settingView.translatesAutoresizingMaskIntoConstraints = NO;
    self.settingView.alpha = 0.7f;
    [self.lowerScrollView addSubview:self.settingView];
    
    self.bgViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.bgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:-self.view.bounds.size.height];
    [self.view addConstraint:self.bgViewTopConstraint];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bgView(bgViewHeight)]" options:0 metrics:@{@"bgViewHeight": @(self.view.bounds.size.height*2)} views:NSDictionaryOfVariableBindings(_bgView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bgView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bgView)]];

    NSDictionary *bgViewBindings = NSDictionaryOfVariableBindings(_upperScrollView, _lowerScrollView);
    NSDictionary *bgViewMetrics = @{@"scrollViewHeight": @(self.view.bounds.size.height),
                                    @"scrollViewWidth": @(self.view.bounds.size.width)};
    [self.bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_upperScrollView(scrollViewHeight)][_lowerScrollView(scrollViewHeight)]|" options:NSLayoutFormatAlignAllCenterX metrics:bgViewMetrics views:bgViewBindings]];
    [self.bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upperScrollView(scrollViewWidth)]|" options:0 metrics:bgViewMetrics views:bgViewBindings]];
    [self.bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lowerScrollView(scrollViewWidth)]|" options:0 metrics:bgViewMetrics views:bgViewBindings]];

    NSDictionary *upperScrollViewBindings = NSDictionaryOfVariableBindings(upperContentView, _chicagoView, _upperBottomLabel, _upperRefreshView);
    NSDictionary *upperScrollViewMetrics = @{@"upperContentViewHeight": @(self.view.bounds.size.height-118),
                                             @"everybodysWidth": @(320),
                                             @"upperBottomLabelHeight": @(kUpperBottomLabelHeight),
                                             @"aVeryHighHeight": @(1000), //just make sure the refresh view is high enough to show the animation
                                             };
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[upperContentView(upperContentViewHeight)]" options:NSLayoutFormatAlignAllCenterX metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upperContentView(everybodysWidth)]|" options:0 metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upperBottomLabel(everybodysWidth)]|" options:0 metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_upperBottomLabel(upperBottomLabelHeight)][_chicagoView]" options:0 metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chicagoView(everybodysWidth)]|" options:0 metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[upperContentView][_upperRefreshView(aVeryHighHeight)]" options:0 metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    [self.upperScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upperRefreshView(everybodysWidth)]|" options:0 metrics:upperScrollViewMetrics views:upperScrollViewBindings]];
    
    self.upperRefreshTopConstraint = [NSLayoutConstraint constraintWithItem:upperContentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_chicagoView attribute:NSLayoutAttributeTop multiplier:1.f constant:-kUpperBottomLabelHeight];
    [self.upperScrollView addConstraint:self.upperRefreshTopConstraint];
    [self.upperScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_chicagoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kBannerViewHeight]];
    
    NSDictionary *lowerScrollViewBindings = NSDictionaryOfVariableBindings(lowerContentView, _settingView, _lowerRefreshView);
    NSDictionary *lowerScrollViewMetrics = @{@"lowerContentViewHeight": @(self.view.bounds.size.height),
                                             @"everybodysWidth": @(320),
                                             @"aVeryHighHeight": @(1000), //just make sure the refresh view is high enough to show the animation
                                             };
    [self.lowerScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lowerContentView(lowerContentViewHeight)]" options:NSLayoutFormatAlignAllCenterX metrics:lowerScrollViewMetrics views:lowerScrollViewBindings]];
    [self.lowerScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lowerContentView(everybodysWidth)]|" options:0 metrics:lowerScrollViewMetrics views:lowerScrollViewBindings]];
    [self.lowerScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_settingView(everybodysWidth)]|" options:0 metrics:lowerScrollViewMetrics views:lowerScrollViewBindings]];
    [self.lowerScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lowerRefreshView(everybodysWidth)]|" options:0 metrics:lowerScrollViewMetrics views:lowerScrollViewBindings]];
    [self.lowerScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lowerRefreshView(aVeryHighHeight)][lowerContentView]" options:0 metrics:lowerScrollViewMetrics views:lowerScrollViewBindings]];
    
    self.lowerRefreshBottomConstraint = [NSLayoutConstraint constraintWithItem:lowerContentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_settingView attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    [self.lowerScrollView addConstraint:self.lowerRefreshBottomConstraint];
    [self.lowerScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_settingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kBannerViewHeight]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.upperScrollView) {
        if (scrollView.contentOffset.y > kBannerViewHeight) {
            self.upperRefreshTopConstraint.constant = -scrollView.contentOffset.y+kBannerViewHeight-kUpperBottomLabelHeight;
            self.upperTrigered = YES;
            self.chicagoView.alpha = 1.f;
            self.upperBottomLabel.alpha = 0;
            if (!self.vibrated) {
                [self playSoundEffect:@"bamboo"];
                self.vibrated = YES;
            }
        }
        else{
            self.chicagoView.alpha = 0.7f;
            self.vibrated = NO;
            self.upperTrigered = NO;
            self.upperRefreshTopConstraint.constant = -kUpperBottomLabelHeight;
            self.upperBottomLabel.alpha = 1-scrollView.contentOffset.y/kBannerViewHeight;
        }
    }
    else if (scrollView == self.lowerScrollView) {
        if (scrollView.contentOffset.y < -kBannerViewHeight) {
            self.lowerRefreshBottomConstraint.constant = -scrollView.contentOffset.y-kBannerViewHeight;
            if (scrollView.contentOffset.y < -kLowerRefreshViewTriggeredHeight) {
                self.lowerTrigered = YES;
                self.settingView.alpha = 1.f;
                if (!self.vibrated) {
                    [self playSoundEffect:@"complete"];
                    self.vibrated = YES;
                }
            }
            else {
                self.vibrated = NO;
                self.lowerTrigered = NO;
                self.settingView.alpha = 0.7f;
            }
        }
        else if (scrollView.contentOffset.y > 0) {
            self.lowerBottomLabelBottomConstraint.constant = -scrollView.contentOffset.y/2;
        }
        else{
            self.lowerTrigered = NO;
            self.lowerRefreshBottomConstraint.constant = 0;
            self.lowerBottomLabelBottomConstraint.constant = 0;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.upperTrigered) {
        [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.bgViewTopConstraint.constant = -self.view.bounds.size.height;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.upperScrollView scrollsToTop];
            self.upperTrigered = NO;
        }];
    }
    else if (self.lowerTrigered) {
        [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.bgViewTopConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.lowerScrollView scrollsToTop];
            self.lowerTrigered = NO;
        }];
    }
}

- (void) playSoundEffect:(NSString*)soundName
{
    NSString *path  = [[NSBundle mainBundle] pathForResource:soundName ofType:@"m4r"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
