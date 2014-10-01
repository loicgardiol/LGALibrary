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

#import "UITableView+LGAAdditions.h"

@implementation UITableView (LGAAdditions)

- (void)lga_reloadDataTryToKeepElementsVisibleWithElementForIndexPathBlock:(id (^)(NSIndexPath* indexPath))elementForIndexPathBlock {
    if (!elementForIndexPathBlock) {
        [NSException raise:@"Illegal argument" format:@"elementForIndexPathBlock cannot be nil"];
    }
    NSArray* visibleCells = self.visibleCells;
    
    if (visibleCells.count == 0) {
        [self reloadData];
        return;
    }
    
    NSMutableOrderedSet* priorityIndexPaths = [NSMutableOrderedSet orderedSetWithCapacity:visibleCells.count];
    for (UITableViewCell* cell in visibleCells) {
        NSIndexPath* indexPath = [self indexPathForCell:cell];
        if (indexPath) {
            [priorityIndexPaths addObject:indexPath];
        }
    }
    
    NSInteger middleUpIndex = (NSInteger)ceil((double)(visibleCells.count)/ 2.0);
    
    if (middleUpIndex < 0) {
        middleUpIndex = 0;
    } else if (middleUpIndex > visibleCells.count - 1) {
        middleUpIndex = visibleCells.count - 1;
    }
    
    UITableViewCell* middleUpCell = visibleCells[middleUpIndex];
    NSIndexPath* middleUpIndexPath = [self indexPathForCell:middleUpCell];
    
    [priorityIndexPaths insertObject:middleUpIndexPath atIndex:0]; //highest priority index to restore position
    
    NSMutableArray* priorityElements = [NSMutableArray arrayWithCapacity:priorityIndexPaths.count];
    
    for (NSIndexPath* indexPath in priorityIndexPaths) {
        id element = elementForIndexPathBlock(indexPath);
        if (element) {
            [priorityElements addObject:element];
        }
    }
    
    [self reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMapTable* indexPathForNewElement = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        NSMutableArray* newElements = [NSMutableArray array];
        for (NSIndexPath* indexPath in self.lga_allIndexPaths) {
            id element = elementForIndexPathBlock(indexPath);
            if (element) {
                [newElements addObject:element];
                [indexPathForNewElement setObject:indexPath forKey:element];
            }
        }
        NSIndexPath* indexPath = nil;
        for (id prioElement in priorityElements) {
            NSInteger index = [newElements indexOfObjectIdenticalTo:prioElement];
            if (index != NSNotFound) {
                indexPath = [indexPathForNewElement objectForKey:newElements[index]];
                break;
            }
        }
        if (indexPath) {
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    });
    
}

- (NSOrderedSet*)lga_allIndexPaths {
    NSMutableOrderedSet* set = [NSMutableOrderedSet orderedSet];
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        for (NSInteger row = 0; row < [self numberOfRowsInSection:section]; row++) {
            [set addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    return set;
}

@end
