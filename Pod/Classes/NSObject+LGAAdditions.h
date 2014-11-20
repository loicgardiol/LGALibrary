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

@import Foundation;

@interface NSObject (LGAAdditions)

/**
 * @discussion Use this method to swizzle methods. You should call this method in +load
 * @param originalSelector the original selector of the method you want to swizzle
 * @param swizzledSelector the selector in its swizzled form (typically xyz_originalSelector)
 # @param isClassMethod pass yes if the selectors are for a class method
 */
+ (void)lga_swizzleMethodWithOriginalSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector isClassMethod:(BOOL)isClassMethod;

/**
 * If YES, all observers added with KVO method addObserver:forKeyPath:options:context:
 * will automatically be removed from self as observers when self is deallocated.
 * This is to prevent the annoying exception "was dealloced while objects were still observing it".
 *
 * Only observers added *after* setting this property to YES will be removed
 * (and the property needs to stay YES until deallocation of the object)
 * 
 * Default: NO
 */
@property (atomic) BOOL lga_automaticallyRemovesObserversOnDealloc;

@end
