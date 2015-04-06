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

//  Created by Loïc Gardiol on 06.04.15.

#import "UIGestureRecognizer+LGAAdditions.h"

#import <objc/runtime.h>

@interface UIGestureRecognizer ()

@property (nonatomic, copy) void (^lga_actionBlock)(UIGestureRecognizer* sender);

@end

@implementation UIGestureRecognizer (LGAAdditions)

#pragma mark - Public

- (instancetype)initWith_lga_actionBlock:(void (^)(UIGestureRecognizer* sender))actionBlock {
    self = [self initWithTarget:self action:@selector(lga_actionHandler)];
    if (self) {
        self.lga_actionBlock = actionBlock;
    }
    return self;
}

static NSString* const kActionBlockKey = @"lga_actionBlock";

- (void(^)(UIBarButtonItem*))lga_actionBlock {
    return objc_getAssociatedObject(self, (__bridge const void *)(kActionBlockKey));
}

- (void)setLga_actionBlock:(void (^)(UIBarButtonItem*))lga_actionBlock {
    objc_setAssociatedObject(self, (__bridge const void *)(kActionBlockKey), lga_actionBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark - Private

- (void)lga_actionHandler {
    if (self.lga_actionBlock) {
        self.lga_actionBlock(self);
    }
}

@end
