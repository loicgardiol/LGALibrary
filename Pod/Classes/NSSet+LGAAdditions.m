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

#import "NSSet+LGAAdditions.h"

@implementation NSSet (LGAAdditions)

- (NSMutableSet*)lga_mutableSetWithMinusSet:(NSSet*)set {
    if (![set isKindOfClass:[NSSet class]]) {
        [NSException raise:@"Illegal argument" format:@"set cannot be nil and must be of class NSSet"];
    }
    NSMutableSet* mSelf = [self mutableCopy];
    [mSelf minusSet:set];
    return mSelf;
}

- (NSMutableSet*)lga_mutableSetWithMinusOrderedSet:(NSOrderedSet*)orderedSet {
    if (![orderedSet isKindOfClass:[NSOrderedSet class]]) {
        [NSException raise:@"Illegal argument" format:@"orderedSet cannot be nil and must be of class NSOrderedSet"];
    }
    NSMutableSet* mSelf = [self mutableCopy];
    [mSelf minusSet:orderedSet.set];
    return mSelf;
}

- (NSUInteger)lga_transitiveHash {
    static SEL transHashSelector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transHashSelector = @selector(lga_transitiveHash);
    });
    
    NSUInteger result = 1;
    for (id element in self) {
        result ^= [element hash];
        if ([element respondsToSelector:transHashSelector]) {
            result ^= [element lga_transitiveHash];
        }
    }
    return result;
}

@end
