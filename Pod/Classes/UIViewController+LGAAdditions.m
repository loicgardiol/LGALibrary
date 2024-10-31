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

#import "UIViewController+LGAAdditions.h"

@implementation UIViewController (LGAAdditions)

- (BOOL)lga_isInSplitViewControllerMasterHierarchy {
    if (!self.splitViewController) {
        return NO;
    }
    UIViewController* masterViewController = self.splitViewController.viewControllers[0];
    if (masterViewController == self) {
        return YES;
    }
    return [masterViewController.lga_recursiveChildViewControllers containsObject:self];
}

- (NSArray<UIViewController*>*)lga_recursiveChildViewControllers {
    NSMutableArray* buffer = [NSMutableArray array];
    [self _lga_fillRecursiveChildViewControllersWithBuffer:buffer];
    return buffer;
}

// Private
- (void)_lga_fillRecursiveChildViewControllersWithBuffer:(NSMutableArray*)buffer {
    for (UIViewController* child in self.childViewControllers) {
        [buffer addObject:child];
        [child _lga_fillRecursiveChildViewControllersWithBuffer:buffer];
    }
}

- (BOOL)lga_forceToucheAvailable {
    return [self respondsToSelector:@selector(traitCollection)]
    && [self.traitCollection respondsToSelector:@selector(forceTouchCapability)]
    && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
}

@end
