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

//  Created by Loïc Gardiol on 15.11.16.

#import "NSTimer+LGAAdditions.h"

static NSString* const kBlockUserInfoKey = @"block";

@implementation NSTimer (LGAAdditions)

+ (NSTimer *)lga_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    if ([self respondsToSelector:@selector(scheduledTimerWithTimeInterval:repeats:block:)]) {
        return [self scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
    }
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(lga_fireTimer:) userInfo:@{kBlockUserInfoKey: block} repeats:repeats];
}

+ (void)lga_fireTimer:(NSTimer*)timer {
    void(^block)(void) = timer.userInfo[kBlockUserInfoKey];
    if (block) {
        block();
    }
}

@end
