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

//  Created by Loïc Gardiol on 03.06.15.

#import "UITabBarController+LGAAdditions.h"

#import "NSObject+LGAAdditions.h"

#import <objc/runtime.h>

#import "LGALayoutGuide.h"

@implementation UITabBarController (LGAAdditions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self lga_swizzleMethodWithOriginalSelector:@selector(viewDidLayoutSubviews) withSwizzledSelector:@selector(lga_viewDidLayoutSubviews) isClassMethod:NO];
        [self lga_swizzleMethodWithOriginalSelector:@selector(bottomLayoutGuide) withSwizzledSelector:@selector(lga_bottomLayoutGuide) isClassMethod:NO];
    });
}

#pragma mark - Public

static NSString* const kTabBarHidden = @"lga_TabBarHidden";

- (void)setLga_TabBarHidden:(BOOL)hidden {
    [self setLga_TabBarHidden:hidden animated:NO];
}

- (void)setLga_TabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self setLga_TabBarHidden:hidden animated:animated force:NO];
}

- (BOOL)lga_TabBarHidden {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kTabBarHidden));
    return [value boolValue];
}

#pragma mark - UIViewController overrides

- (void)lga_viewDidLayoutSubviews {
    [self lga_viewDidLayoutSubviews]; //calling original implementation
    [self setLga_TabBarHidden:self.lga_TabBarHidden animated:NO force:YES]; //make sure tab bar is in the hidden state we want
}

- (id<UILayoutSupport>)lga_bottomLayoutGuide {
    if (self.lga_TabBarHidden) {
        return [LGALayoutGuide layoutGuideWithLength:0.0];
    } else {
        return [self lga_bottomLayoutGuide]; //calling original implementation
    }
}

#pragma mark - Private

- (void)setLga_TabBarHidden:(BOOL)hidden animated:(BOOL)animated force:(BOOL)force {
    if (!force && (hidden == self.lga_TabBarHidden)) {
        return;
    }
    objc_setAssociatedObject(self, (__bridge const void *)(kTabBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    CGFloat offsetY = self.tabBar.frame.size.height * (hidden ? 1.0 : -1.0);
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.tabBar.frame = CGRectOffset(self.tabBar.frame, 0, offsetY);
    } completion:^(BOOL finished) {
        [self.view setNeedsLayout];
    }];
}

@end
