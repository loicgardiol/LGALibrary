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

//  Created by Loïc Gardiol on 27.01.15.

#import "NSObject+LGAAdditions.h"

#import "NSNotificationCenter+LGAAdditions.h"

#import "NSMapTable+LGAAdditions.h"

#import <objc/runtime.h>

@interface LGAObserverWrapper : NSObject

@property (nonatomic, strong) id opaqueObserver;
@property (nonatomic, copy) NSString* notifName;
@property (nonatomic, weak) id notifSender;

@end

@implementation LGAObserverWrapper

@end

@interface NSNotificationCenter ()

@property (nonatomic, readonly) NSMapTable* wrappersForObserver; // Key: original observer, as passed in addObserver:... Value: Mutable Array of LGAObserverWrapper

@end

@implementation NSNotificationCenter (LGAAdditions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self lga_swizzleMethodWithOriginalSelector:@selector(removeObserver:) withSwizzledSelector:@selector(lga_removeObserver:) isClassMethod:NO];
        [self lga_swizzleMethodWithOriginalSelector:@selector(removeObserver:name:object:) withSwizzledSelector:@selector(lga_removeObserver:name:object:) isClassMethod:NO];
    });
}

#pragma mark - Public

- (void)lga_addObserver:(id)observer name:(NSString*)notificationName object:(id)object block:(void (^)(NSNotification* notif))block {
    id opaqueObserver = [self addObserverForName:notificationName object:object queue:nil usingBlock:block];
    
    LGAObserverWrapper* wrapper = [LGAObserverWrapper new];
    wrapper.opaqueObserver = opaqueObserver;
    wrapper.notifName = notificationName;
    wrapper.notifSender = object;
    
    NSMutableArray* wrappers = self.wrappersForObserver[observer] ?: [NSMutableArray array];
    [wrappers addObject:wrapper];
    self.wrappersForObserver[observer] = wrappers;
}

#pragma mark - NSNotificationCenter overrides

- (void)lga_removeObserver:(id)observer {
    if (observer) {
        NSMutableArray* wrappers = self.wrappersForObserver[observer];
        for (LGAObserverWrapper* wrapper in wrappers) {
            [self lga_removeObserver:wrapper.opaqueObserver]; //calling original implementation for opaqueObserver
        }
        [self.wrappersForObserver removeObjectForKey:observer]; //all wrappers removed for this observer
    }
    [self lga_removeObserver:observer]; //calling original implementation
}

- (void)lga_removeObserver:(id)observer name:(NSString *)aName object:(id)anObject {
    if (observer) {
        NSMutableArray* wrappers = self.wrappersForObserver[observer];
        for (LGAObserverWrapper* wrapper in [wrappers copy]) {
            [self lga_removeObserver:wrapper.opaqueObserver name:aName object:anObject]; //calling original implementation for opaqueObserver
            if ((aName && ![aName isEqualToString:wrapper.notifName]) || (anObject && (anObject != wrapper.notifSender))) {
                // If name or object was specified and one of them is not equal to the corresponding proerty in registered observer (wrapper), observer was not removed.
                // removeObserver:... does not tell us whether removal was done, that's way we have to determine it ourselves
            } else {
                [wrappers removeObject:wrapper];
            }
        }
    }
    [self lga_removeObserver:observer name:aName object:anObject]; //calling original implementation
}

#pragma mark - Private

- (NSMapTable*)wrappersForObserver {
    static NSString* const kAssocObjectKey = @"lga_wrappersForObserver";
    NSMapTable* table = objc_getAssociatedObject(self, (__bridge const void *)(kAssocObjectKey));
    if (!table) {
        @synchronized (self) {
            if (!table) {
                table = objc_getAssociatedObject(self, (__bridge const void *)(kAssocObjectKey));
                if (!table) {
                    table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
                    objc_setAssociatedObject(self, (__bridge const void *)(kAssocObjectKey), table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }                                                                                                                                                                       
            }
        }
    }
    return table;
}

@end
