//
// Copyright (c) 2014 Loic Gardiol <loic.gardiol@gmail.com>
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
//

#import "NSLayoutConstraint+LGAAdditions.h"

CGFloat const kNoInsetConstraint = CGFLOAT_MIN;

@implementation NSLayoutConstraint (LGAAdditions)

+ (NSLayoutConstraint*)widthConstraint:(CGFloat)width forView:(UIView*)view {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
}

+ (NSLayoutConstraint*)heightConstraint:(CGFloat)height forView:(UIView*)view {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
}

+ (NSArray*)width:(CGFloat)width height:(CGFloat)height constraintsForView:(UIView*)view {
    return @[[self widthConstraint:width forView:view], [self heightConstraint:height forView:view]];
}

+ (NSArray*)constraintsToSuperview:(UIView*)superview forView:(UIView*)view edgeInsets:(UIEdgeInsets)edgeInsets {
    NSMutableArray* constraints = [NSMutableArray arrayWithCapacity:4];
    if (edgeInsets.top != kNoInsetConstraint) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:edgeInsets.top]];
    }
    if (edgeInsets.left != kNoInsetConstraint) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:edgeInsets.left]];
    }
    if (edgeInsets.bottom != kNoInsetConstraint) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:edgeInsets.bottom]];
    }
    if (edgeInsets.right != kNoInsetConstraint) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:edgeInsets.right]];
    }
    return constraints;
}

+ (NSLayoutConstraint*)constraintForCenterXtoSuperview:(UIView*)superview forView:(UIView*)view constant:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:constant];
}

+ (NSLayoutConstraint*)constraintForCenterYtoSuperview:(UIView*)superview forView:(UIView*)view constant:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:constant];
}

+ (NSArray*)constraintsForCenterXYtoSuperview:(UIView*)superview forView:(UIView*)view {
    return @[[self constraintForCenterXtoSuperview:superview forView:view constant:0.0],
             [self constraintForCenterYtoSuperview:superview forView:view constant:0.0]];
}

@end
