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

//  Created by Loïc Gardiol on 26.09.14.

#import "LGAEditableTableViewCell.h"

@interface LGAEditableTableViewCell ()

@property (nonatomic, strong, readwrite) UITextField* textField;

@end

@implementation LGAEditableTableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    [NSException raise:@"Unsupported constructor" format:@"LGAEditableTableViewCell does not support initWithStyle:reuseIdentifier: please use -init"];
    return nil;
}

- (instancetype)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.textField.font = self.textLabel.font;
        [self.contentView addSubview:self.textField];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

#pragma mark - UIView overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    [self repositionTextField];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
        [self repositionTextField];
    }
}

#pragma mark - Private

- (void)repositionTextField {
    CGFloat textLabelTextWidth = [self.textLabel textRectForBounds:CGRectMake(0, 0, 1000, self.frame.size.height) limitedToNumberOfLines:self.textLabel.numberOfLines].size.width;
    CGFloat x = self.textLabel.frame.origin.x+textLabelTextWidth+15.0;
    self.textField.frame = CGRectMake(x, self.textLabel.frame.origin.y, self.frame.size.width - x - 5.0, self.textLabel.frame.size.height > 0.0 ? self.textLabel.frame.size.height : self.frame.size.height);
}

#pragma mark - Dealloc

- (void)dealloc {
    @try {
        [self.textLabel removeObserver:self forKeyPath:@"text"];
    }
    @catch (NSException *exception) {}
}


@end
