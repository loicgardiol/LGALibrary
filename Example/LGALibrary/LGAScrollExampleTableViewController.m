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

#import "LGAScrollExampleTableViewController.h"

#import "UIScrollView+LGAAdditions.h"

#import "LGAEditableTableViewCell.h"

static NSInteger const kUsernameSection = 0;
static NSInteger const kNumbersSection = 1;

@implementation LGAScrollExampleTableViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    __weak __typeof(self) welf = self;
    [self.tableView setLga_toggleElementsVisiblityOnScrollBlock:^(BOOL hidden) {
        [welf.navigationController setNavigationBarHidden:hidden animated:YES];
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case kUsernameSection:
        {
            LGAEditableTableViewCell* cell = [LGAEditableTableViewCell new];
            cell.textLabel.text = @"Username";
            cell.textField.placeholder = @"e.g. john";
            return cell;
            break;
        }
        case kNumbersSection:
        {
            static NSString* const kIdentifier = @"number";
            UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
            return cell;
            break;
        }
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kUsernameSection:
            return 1;
         case kNumbersSection:
            return 50;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

@end
