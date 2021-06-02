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

@import UIKit;

@interface UIApplication (LGAAdditions)

/**
 * The last UIEvent, with at least one touch in its "began" phase, that was sent to the UIApplication.
 * WARNING: as an event cannot be copied, the event is retained by reference, and can thus become stale (its content changes).
 */
@property (nonatomic, readonly, nullable) UIEvent* lga_lastTouchEvent;

/**
 * A copy of the reference to lga_lastTouchEvent.allTouches at the time the UIEvent occured.
 * As UIEvent.allTouches might change with time, this property might hold a reference to UITouch(es) that are no longer valid.
 */
@property (nonatomic, readonly, nullable) NSSet<UITouch*>* lga_lastTouches;

/**
 * The last timestamp (UNIX) at which an lga_lastTouchEvent was recorded.
 */
@property (nonatomic, readonly) NSTimeInterval lga_lastTouchTimestamp;

@end
