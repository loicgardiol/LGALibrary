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

//  Created by Loïc Gardiol on 24.01.15.

#import "UIApplication+LGAAdditions.h"

#import "NSObject+LGAAdditions.h"

#import <objc/runtime.h>

@interface UIApplication ()

@property (nonatomic, readwrite) NSTimeInterval lga_lastTouchTimestamp;

@end

@implementation UIApplication (LGAAdditions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self lga_swizzleMethodWithOriginalSelector:@selector(sendEvent:) withSwizzledSelector:@selector(lga_sendEvent:) isClassMethod:NO];
    });
}

#pragma mark - UIApplication overrides

- (void)lga_sendEvent:(UIEvent*)event {
    [self lga_sendEvent:event]; //calling original implementation
    
    UITouch* touch = [event.allTouches anyObject];
    if (touch && touch.phase == UITouchPhaseBegan) {
        self.lga_lastTouchTimestamp = [[NSDate date] timeIntervalSince1970];
    }
}

#pragma mark - Public

static NSString* const kLastTouchTimestamp = @"lga_lastTouchTimestamp";

- (NSTimeInterval)lga_lastTouchTimestamp {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kLastTouchTimestamp));
    return [value doubleValue];
}

#pragma mark - Private

- (void)setLga_lastTouchTimestamp:(NSTimeInterval)lga_lastTouchTimestamp {
    objc_setAssociatedObject(self, (__bridge const void *)(kLastTouchTimestamp), @(lga_lastTouchTimestamp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
