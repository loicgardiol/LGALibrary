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

//  Created by Loïc Gardiol on 26.03.15.

@import UIKit;

@interface UIViewController (LGAAdditions)

/**
 * @return YES if self is or within the master view controller hierarchy of self.splitViewController, NO in all other cases.
 * WARNING: hierarchy here means in the viewControllers of a navigation or tab bar controller. Presented view controllers are not considered.
 */
@property (nonatomic, readonly) BOOL lga_isInSplitViewControllerMasterHierarchy;

/**
 * @return all children view controllers of self, recursively.
 */
@property (nonatomic, readonly, nonnull) NSArray<UIViewController*>* lga_recursiveChildViewControllers;
/**
 * @return YES if force touch API is supported and available in self
 */
@property (nonatomic, readonly) BOOL lga_forceToucheAvailable;

@end
