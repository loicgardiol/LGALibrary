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

//  Created by Loïc Gardiol on 26.09.14.

@import UIKit;

@interface UITableView (LGAAdditions)

/**
 * @discussion calls reloadData and try to scroll to the elements that were visible before the reload.
 * @param elementForIndexPathBlock block that should return the element that corresponds to the passed indexPath.
 * An element is any object on which isEqual can be called. The method will use this block to try to relocate the
 * elements that were visible before the reload.
 */
- (void)lga_reloadDataTryToKeepElementsVisibleWithElementForIndexPathBlock:(id (^)(NSIndexPath* indexPath))elementForIndexPathBlock;

/**
 * @return ordered set if all index paths of the table view
 */
@property (nonatomic, readonly) NSOrderedSet* lga_allIndexPaths;

@end
