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

@import UIKit;

extern CGFloat const kNoInsetConstraint;

@interface NSLayoutConstraint (LGAAdditions)

/**
 * @return a width constraint for the view with constant <width> and multiplier 1.0
 */
+ (NSLayoutConstraint*)widthConstraint:(CGFloat)width forView:(UIView*)view;

/**
 * @return a height constraint for the view with constant <height> and multiplier 1.0
 */
+ (NSLayoutConstraint*)heightConstraint:(CGFloat)height forView:(UIView*)view;

/**
 * @return an array with the following content [<width_constraint>, <height_constraint>]
 * populated using widthConstraint:forView: and heightConstraint:forView:
 */
+ (NSArray*)width:(CGFloat)width height:(CGFloat)height constraintsForView:(UIView*)view;

/**
 * @return an array of constraints between <superview> and <view>, to be added to <superview>.
 * @param edgeInsets defines, for each edge, what the margin should be between the view and the superview.
 * Pass kNoInsertConstraint constant for the edges you don't want to apply a constraint to (these
 * will then not be present in the array).
 */
+ (NSArray*)constraintsToSuperview:(UIView*)superview forView:(UIView*)view edgeInsets:(UIEdgeInsets)edgeInsets;

/**
 * @return a constraint to center X <view> to a <superview> with constant <constant>
 */
+ (NSLayoutConstraint*)constraintForCenterXtoSuperview:(UIView*)superview forView:(UIView*)view constant:(CGFloat)constant;

/**
 * @return a constraint to center Y <view> to a <superview> with constant <constant>
 */
+ (NSLayoutConstraint*)constraintForCenterYtoSuperview:(UIView*)superview forView:(UIView*)view constant:(CGFloat)constant;

/**
 * @return an array with the following content [<center_x_constraint>, <center_y_constraint>]
 * populated using constraintForCenterXtoSuperview:forView:constant: and constraintForCenterYtoSuperview:forView:constant:
 * @discussion constant is 0.0 for both constraints.
 */
+ (NSArray*)constraintsForCenterXYtoSuperview:(UIView*)superview forView:(UIView*)view;

@end
