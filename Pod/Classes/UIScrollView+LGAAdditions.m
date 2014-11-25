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

#import "NSObject+LGAAdditions.h"

#import <objc/runtime.h>

static NSString* kKVOContext = 0;

@interface UIScrollView ()<UIScrollViewDelegate>

@property (nonatomic) CGFloat lga_lastContentOffsetY;

@property (nonatomic) CGFloat lga_accumulatedContentOffsetY;

@property (nonatomic) LGAUIScrollViewScrollDirection lga_lastScrollDirection;

@end

@implementation UIScrollView (LGAAdditions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self lga_swizzleMethodWithOriginalSelector:@selector(observeValueForKeyPath:ofObject:change:context:) withSwizzledSelector:@selector(lga_uiscrollview_observeValueForKeyPath:ofObject:change:context:) isClassMethod:NO];
        [self lga_swizzleMethodWithOriginalSelector:NSSelectorFromString(@"dealloc") withSwizzledSelector:@selector(lga_uiscrollview_dealloc) isClassMethod:NO];
    });
}

#pragma mark - Public

static NSString* const kToggleElementsVisiblityOnScrollBlockKey = @"lga_toggleElementsVisiblityOnScrollBlock";

- (void (^)(BOOL))lga_toggleElementsVisiblityOnScrollBlock {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kToggleElementsVisiblityOnScrollBlockKey));
    return value;
}

- (void)setLga_toggleElementsVisiblityOnScrollBlock:(void (^)(BOOL))lga_toggleElementsVisiblityOnScrollBlock {
    if (self.lga_toggleElementsVisiblityOnScrollBlock) {
        @try {
            [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
        }
        @catch (NSException *exception) {}
    }
    objc_setAssociatedObject(self, (__bridge const void *)(kToggleElementsVisiblityOnScrollBlockKey), lga_toggleElementsVisiblityOnScrollBlock, OBJC_ASSOCIATION_COPY);
    if (lga_toggleElementsVisiblityOnScrollBlock) {
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:&kKVOContext];
    }
}

- (LGAUIScrollViewScrollDirection)lga_scrollDirection {
    if (self.contentOffset.y <= 0.0 || self.contentOffset.y >= self.contentSize.height) {
        return LGAUIScrollViewScrollDirectionStatic;
    }
    //NSLog(@"%lf %lf", self.contentOffset.y, self.contentSize.height);
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

- (BOOL)lga_isAtTop {
    return self.contentOffset.y <= -self.contentInset.top;
}

- (BOOL)lga_isAtBottom {
    return self.contentOffset.y >= (self.contentSize.height + self.contentInset.bottom - self.bounds.size.height);
}

#pragma mark - KVO

- (void)lga_uiscrollview_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && context == &kKVOContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self lga_handleScroll];
        });
    } else {
        [self lga_uiscrollview_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private

- (void)lga_handleScroll {
    
    CGFloat diff = self.contentOffset.y - self.lga_lastContentOffsetY;
    self.lga_lastContentOffsetY = self.contentOffset.y;
    
    self.lga_accumulatedContentOffsetY += diff;
    
    if (self.lga_accumulatedContentOffsetY >= 30.0 && self.contentOffset.y >= 0.0) {
        self.lga_accumulatedContentOffsetY = 0.0;
        if (self.lga_lastScrollDirection != LGAUIScrollViewScrollDirectionDown) {
            self.lga_lastScrollDirection = LGAUIScrollViewScrollDirectionDown;
            void (^toggleBlock)(BOOL hidden) = self.lga_toggleElementsVisiblityOnScrollBlock;
            if (toggleBlock) {
                toggleBlock(YES);
            }
        }
    } else if (self.lga_accumulatedContentOffsetY <= -100.0) {
        self.lga_accumulatedContentOffsetY = 0.0;
        if (self.lga_lastScrollDirection != LGAUIScrollViewScrollDirectionUp) {
            self.lga_lastScrollDirection = LGAUIScrollViewScrollDirectionUp;
            void (^toggleBlock)(BOOL hidden) = self.lga_toggleElementsVisiblityOnScrollBlock;
            if (toggleBlock) {
                toggleBlock(NO);
            }
        }
    }
}

#pragma mark Properties

static NSString* const kLastContentOffsetY = @"lga_lastContentOffsetY";

- (CGFloat)lga_lastContentOffsetY {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kLastContentOffsetY));
    return [value floatValue];
}

- (void)setLga_lastContentOffsetY:(CGFloat)lga_lastContentOffsetY {
    objc_setAssociatedObject(self, (__bridge const void *)(kLastContentOffsetY), @(lga_lastContentOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static NSString* const kAccumulatedContentOffsetY = @"lga_accumulatedContentOffsetY";

- (CGFloat)lga_accumulatedContentOffsetY {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kAccumulatedContentOffsetY));
    return [value floatValue];
}

- (void)setLga_accumulatedContentOffsetY:(CGFloat)lga_accumulatedContentOffsetY{
    objc_setAssociatedObject(self, (__bridge const void *)(kAccumulatedContentOffsetY), @(lga_accumulatedContentOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (void)lga_uiscrollview_dealloc
{
    if (self.lga_toggleElementsVisiblityOnScrollBlock) {
        @try {
            [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
        }
        @catch (NSException *exception) {}
    }
    [self lga_uiscrollview_dealloc]; //calling original implementation
}

@end
