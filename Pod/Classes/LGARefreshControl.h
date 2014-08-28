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

//  Created by Loïc Gardiol on 30.10.12.

@import UIKit;

@interface LGARefreshControl : NSObject

@property (nonatomic, weak, readonly) UITableViewController* tableViewController;
@property (nonatomic, readonly, copy) NSString* refreshedDataIdentifier;
@property (nonatomic, copy) UIColor* tintColor; //will be used for activitiy view and message default state color
@property (nonatomic, strong) UIColor* errorMessageColor;
@property (nonatomic, copy) NSString* message;
@property (nonatomic) BOOL showsDefaultRefreshingMessage; //Default: YES
@property (nonatomic, readonly) BOOL isVisible;

/**
 * Readonly. Use method markRefreshSuccessful to update it.
 */
@property (nonatomic, readonly) NSDate* lastSuccessfulRefreshDate;

/**
 * refreshedDataIdentifier will be use to save last refresh timestamp. Pass nil if you don't want to keep track of refresh date.
 * See markRefreshSuccessful method for more explanations.
 */
- (id)initWithTableViewController:(UITableViewController*)tableViewController refreshedDataIdentifier:(NSString*)dataIdentifier;

/**
 * [target selector] will be called when user pulls to refresh
 */
- (void)setTarget:(id)target selector:(SEL)selector;

/**
 * Trigger refresh start/end manually
 */
- (void)startRefreshing;
- (void)startRefreshingWithMessage:(NSString*)message;
- (void)endRefreshing;
- (void)endRefreshingAndMarkSuccessful;
- (void)endRefreshingWithDelay:(NSTimeInterval)delay indicateErrorWithMessage:(NSString*)message;

/**
 * Call this method just after endRefresh to signal that the last refresh was successful.
 * This will set the default text to "last refresh <date>". 
 * This feature is only supported if refreshedDataIdentifier was indicated at init.
 */
- (void)markRefreshSuccessful;

/**
 * This method can be used to know wether the data managed by the refresh control
 * should be refreshed, for a specified validity (seconds).
 * If the device is not connected to the internet, this method returns NO.
 * If refresh control was initiated without data identifier, this method always returns YES.
 */
- (BOOL)shouldRefreshDataForValidity:(NSTimeInterval)validitySeconds;

/**
 * Will delete saved info concerning last successful refresh date for specific identifier
 */
+ (void)deleteRefreshDateInfoForDataIdentifier:(NSString*)dataIdentifier;

/**
 * Same as deleteRefreshDateInfoForDataIdentifier:, with self.refreshedDataIdentifier as dataIdentifier
 */
- (void)deleteRefreshDateInfo;

@end

