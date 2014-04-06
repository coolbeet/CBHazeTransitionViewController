//
//  RefreshView.h
//  CBHazeTransitionViewController
//
//  Created by coolbeet on 4/5/14.
//  Copyright (c) 2014 suyu zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RefreshViewDirectionUp = 1,
    RefreshViewDirectionDown,
}RefreshViewDirection;

@interface RefreshView : UIView

- (id)initWithFrame:(CGRect)frame inScrollView:(UIScrollView *)scrollView withDirection:(RefreshViewDirection)direction;

@end
