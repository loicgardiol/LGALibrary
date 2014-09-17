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

#import "UIScrollView+LGAAdditions.h"

#import <objc/runtime.h>

static NSString* kKVOContext = 0;

@interface UIScrollView ()<UIScrollViewDelegate>

@property (nonatomic) CGFloat lga_lastContentOffsetY;

@property (nonatomic) LGAUIScrollViewScrollDirection lga_lastScrollDirection;

@end

@implementation UIScrollView (LGAAdditions)

#pragma mark - Public

static NSString* const kToggleElementsVisiblityOnScrollBlockKey = @"lga_toggleElementsVisiblityOnScrollBlock";

- (void (^)(BOOL))lga_toggleElementsVisiblityOnScrollBlock {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kToggleElementsVisiblityOnScrollBlockKey));
    return value;
}

- (void)setLga_toggleElementsVisiblityOnScrollBlock:(void (^)(BOOL))lga_toggleElementsVisiblityOnScrollBlock {
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
    @catch (NSException *exception) {}
    objc_setAssociatedObject(self, (__bridge const void *)(kToggleElementsVisiblityOnScrollBlockKey), lga_toggleElementsVisiblityOnScrollBlock, OBJC_ASSOCIATION_COPY);
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:&kKVOContext];
}

- (LGAUIScrollViewScrollDirection)lga_scrollDirection {
    if (self.contentOffset.y <= 0.0) {
        return LGAUIScrollViewScrollDirectionStatic;
    }
    CGFloat diff = self.contentOffset.y - self.lga_lastContentOffsetY;
    self.lga_lastContentOffsetY = self.contentOffset.y;
    if (diff > 0.0) {
        return LGAUIScrollViewScrollDirectionDown;
    } else if (diff < 0.0) {
        return LGAUIScrollViewScrollDirectionUp;
    } else {
        return LGAUIScrollViewScrollDirectionStatic;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && context == &kKVOContext) {
        LGAUIScrollViewScrollDirection scrollDirection = self.lga_scrollDirection;
        if (scrollDirection == LGAUIScrollViewScrollDirectionStatic) {
            return;
        }
        BOOL hidden = (scrollDirection == LGAUIScrollViewScrollDirectionDown);
        if (self.lga_lastScrollDirection != scrollDirection) {
            void (^toggleBlock)(BOOL hidden) = self.lga_toggleElementsVisiblityOnScrollBlock;
            toggleBlock(hidden);
        }
        self.lga_lastScrollDirection = scrollDirection;
    }
}

#pragma mark - Private

static NSString* const kLastContentOffsetY = @"lga_lastContentOffsetY";

- (CGFloat)lga_lastContentOffsetY {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kLastContentOffsetY));
    return [value floatValue];
}

- (void)setLga_lastContentOffsetY:(CGFloat)lga_lastContentOffsetY {
    objc_setAssociatedObject(self, (__bridge const void *)(kLastContentOffsetY), @(lga_lastContentOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static NSString* const kLastScrollDirection = @"lga_lastScrollDirection";

- (LGAUIScrollViewScrollDirection)lga_lastScrollDirection {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kLastScrollDirection));
    return [value integerValue];
}

- (void)setLga_lastScrollDirection:(LGAUIScrollViewScrollDirection)lga_lastScrollDirection {
    objc_setAssociatedObject(self, (__bridge const void *)(kLastScrollDirection), @(lga_lastScrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Dealloc

- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
    @catch (NSException *exception) {}
}

@end
