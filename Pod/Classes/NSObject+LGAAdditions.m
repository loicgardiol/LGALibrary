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

//  Created by Loïc Gardiol on 20.11.14.

#import "NSObject+LGAAdditions.h"

#import <objc/runtime.h>

/**
 * Private internal class to hold registered observers info
 */
@interface LGAKVOObservationInfo : NSObject

@property (nonatomic, unsafe_unretained) NSObject* observer;
@property (nonatomic, copy) NSString* keyPath;
@property (nonatomic) NSKeyValueObservingOptions options;
@property (nonatomic, unsafe_unretained) void* context;

@end

@implementation LGAKVOObservationInfo

@end

@interface NSObject ()

@property (nonatomic, strong) NSMutableArray* lga_allObserversInfo;

@end

@implementation NSObject (LGAAdditions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self lga_swizzleMethodWithOriginalSelector:@selector(addObserver:forKeyPath:options:context:) withSwizzledSelector:@selector(lga_nsobject_addObserver:forKeyPath:options:context:) isClassMethod:NO];
        [self lga_swizzleMethodWithOriginalSelector:@selector(removeObserver:forKeyPath:) withSwizzledSelector:@selector(lga_nsobject_removeObserver:forKeyPath:) isClassMethod:NO];
        [self lga_swizzleMethodWithOriginalSelector:@selector(removeObserver:forKeyPath:context:) withSwizzledSelector:@selector(lga_nsobject_removeObserver:forKeyPath:context:) isClassMethod:NO];
        [self lga_swizzleMethodWithOriginalSelector:NSSelectorFromString(@"dealloc") withSwizzledSelector:@selector(lga_nsobject_dealloc) isClassMethod:NO];
    });
}

#pragma mark - Public

+ (void)lga_swizzleMethodWithOriginalSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector isClassMethod:(BOOL)isClassMethod {
    
    Class class;
    if (isClassMethod) {
        class = object_getClass((id)self);
    } else {
        class = [self class];
    }
    
    if (!originalSelector) {
        [NSException raise:@"Illegal argument" format:@"originalSelector cannot be nil"];
    }
    
    if (!swizzledSelector) {
        [NSException raise:@"Illegal argument" format:@"swizzledSelector cannot be nil"];
    }
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BOOL)lga_automaticallyRemovesObserversOnDealloc {
    return (self.lga_allObserversInfo != nil);
}

- (void)setLga_automaticallyRemovesObserversOnDealloc:(BOOL)lga_automaticallyRemovesObserversOnDealloc {
    if (lga_automaticallyRemovesObserversOnDealloc) {
        if (!self.lga_allObserversInfo) {
            self.lga_allObserversInfo = [NSMutableArray array];
        }
    } else {
        self.lga_allObserversInfo = nil;
    }
}

#pragma mark - KVO

- (void)lga_nsobject_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (self.lga_allObserversInfo) {
        LGAKVOObservationInfo* info = [LGAKVOObservationInfo new];
        info.observer = observer;
        info.keyPath = keyPath;
        info.options = options;
        info.context = context;
        [self.lga_allObserversInfo addObject:info];
    }
    [self lga_nsobject_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)lga_nsobject_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if (self.lga_allObserversInfo) {
        for (LGAKVOObservationInfo* info in [self.lga_allObserversInfo copy]) {
            if (info.observer == observer && [info.keyPath isEqualToString:keyPath]) {
                [self.lga_allObserversInfo removeObject:info];
            }
        }
    }
    [self lga_nsobject_removeObserver:observer forKeyPath:keyPath];
}

- (void)lga_nsobject_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if (self.lga_allObserversInfo) {
        for (LGAKVOObservationInfo* info in [self.lga_allObserversInfo copy]) {
            if (info.observer == observer && [info.keyPath isEqualToString:keyPath] && info.context == context) {
                [self.lga_allObserversInfo removeObject:info];
            }
        }
    }
    [self lga_nsobject_removeObserver:observer forKeyPath:keyPath context:context];
}

#pragma mark - Private

static NSString* const kAllObserversInfo = @"lga_allObserversInfo";

- (NSMutableArray*)lga_allObserversInfo {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kAllObserversInfo));
    return value;
}

- (void)setLga_allObserversInfo:(NSMutableArray *)lga_allObserversInfo {
    objc_setAssociatedObject(self, (__bridge const void *)(kAllObserversInfo), lga_allObserversInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lga_removeAllObservers {
    for (LGAKVOObservationInfo* info in self.lga_allObserversInfo) {
        @try {
            if (info.context) {
                [self removeObserver:info.observer forKeyPath:info.keyPath context:info.context];
            } else {
                [self removeObserver:info.observer forKeyPath:info.keyPath];
            }
        }
        @catch (NSException *exception) {}
    }
}

#pragma mark - Dealloc

- (void)lga_nsobject_dealloc
{
    if (self.lga_allObserversInfo) {
        [self lga_removeAllObservers];
    }
    [self lga_nsobject_dealloc]; //calling original implementation
}


@end
