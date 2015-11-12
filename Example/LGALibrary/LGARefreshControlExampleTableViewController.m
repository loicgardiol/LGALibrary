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

//  Created by Loic Gardiol on 08/05/2014.

#import "LGARefreshControlExampleTableViewController.h"

#import "LGARefreshControl.h"

@interface LGARefreshControlExampleTableViewController ()

@property (nonatomic, strong) LGARefreshControl* lgaRefreshControl;

@end

@implementation LGARefreshControlExampleTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lgaRefreshControl = [[LGARefreshControl alloc] initWithTableViewController:self refreshedDataIdentifier:@"list_name"];
    [self.lgaRefreshControl setTarget:self selector:@selector(refresh)];
    [self refresh];
}

#pragma mark - Actions

- (void)refresh {
    /*
     * Will show default loading message (Loading...) under the spinning wheel
     */
    //[self.lgaRefreshControl startRefreshing];
    
    [self.lgaRefreshControl startRefreshingSilently:YES withMessage:@"test"];
    
    /*
     * Start your request... assuming requestFinishedWithSuccess: called back on finish
     * Here using timer for the example.
     */
    __weak __typeof(self) welf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [welf requestFinishedWithSuccess:YES];
    });
}

#pragma mark - Request callback

- (void)requestFinishedWithSuccess:(BOOL)success {
    if (success) {
        [self.lgaRefreshControl endRefreshingAndMarkSuccessful];
        /*
         * Indicate that refresh was successfull (saves last refresh date)
         */
    } else {
        /*
         * Indicate that refresh failed, will show message in red under the spinning wheel for 2 seconds
         */
        [self.lgaRefreshControl endRefreshingWithDelay:2.0 indicateErrorWithMessage:@"Error"];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"Pull to refresh...";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
