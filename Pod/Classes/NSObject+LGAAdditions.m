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
@interface LGAKVOObserverInfo : NSObject

@property (nonatomic, weak) NSObject* observer;
@property (nonatomic, copy) NSString* keyPath;
@property (nonatomic) NSKeyValueObservingOptions options;
@property (nonatomic, unsafe_unretained) void* context;

@end

@implementation LGAKVOObserverInfo

@end

@interface NSObject ()

@property (nonatomic, strong) NSMutableArray* lga_allObserversInfo;

@end

@implementation NSObject (LGAAdditions)

+ (void)load {
    [self swizzleKVO];
    [self swizzleDealloc];
}

+ (void)swizzleKVO {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(addObserver:forKeyPath:options:context:);
        SEL swizzledSelector = @selector(lga_addObserver:forKeyPath:options:context:);
        
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
    });
}

+ (void)swizzleDealloc {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = NSSelectorFromString(@"dealloc"); //cannot use @selector (ARC forbids id)
        SEL swizzledSelector = @selector(lga_dealloc);
        
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
    });
}

#pragma mark - Public

- (BOOL)lga_automaticallyRemovesObserversOnDealloc {
    @synchronized (self) {
        return (self.lga_allObserversInfo != nil);
    }
}

- (void)setLga_automaticallyRemovesObserversOnDealloc:(BOOL)lga_automaticallyRemovesObserversOnDealloc {
    @synchronized (self) {
        if (lga_automaticallyRemovesObserversOnDealloc) {
            if (!self.lga_allObserversInfo) {
                self.lga_allObserversInfo = [NSMutableArray array];
            }
        } else {
            self.lga_allObserversInfo = nil;
        }
    }
}

#pragma mark - KVO

- (void)lga_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (self.lga_allObserversInfo) {
        LGAKVOObserverInfo* info = [LGAKVOObserverInfo new];
        info.observer = observer;
        info.keyPath = keyPath;
        info.options = options;
        info.context = context;
        [self.lga_allObserversInfo addObject:info];
    }
    [self lga_addObserver:observer forKeyPath:keyPath options:options context:context];
}

#pragma mark - Private

static NSString* const kAllObserversInfo = @"lga_allObserversInfo";

- (NSMutableArray*)lga_allObserversInfo {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(kAllObserversInfo));
    return value;
}

- (void)setLga_allObserversInfo:(NSMutableArray *)lga_allObserversInfo {
    @synchronized (self) {
        objc_setAssociatedObject(self, (__bridge const void *)(kAllObserversInfo), lga_allObserversInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)lga_removeAllObservers {
    for (LGAKVOObserverInfo* observerInfo in self.lga_allObserversInfo) {
        @try {
            if (observerInfo.context) {
                [self removeObserver:observerInfo.observer forKeyPath:observerInfo.keyPath context:observerInfo.context];
            } else {
                [self removeObserver:observerInfo.observer forKeyPath:observerInfo.keyPath];
            }
        }
        @catch (NSException *exception) {}
    }
}

#pragma mark - Dealloc

- (void)lga_dealloc
{
    if (self.lga_allObserversInfo) {
        [self lga_removeAllObservers];
    }
    [self lga_dealloc]; //calling original implementation
}


@end
