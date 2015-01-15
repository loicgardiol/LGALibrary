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

//  Created by Loïc Gardiol on 30.10.12.

#import "LGARefreshControl.h"

#import <AFNetworking/AFNetworking.h>

@interface LGARefreshControl ()

@property (nonatomic, strong) UITableViewController* strongTableViewController; //used when init with tableview, should retain it
@property (nonatomic, weak, readwrite) UITableViewController* tableViewController;

@property (nonatomic, readonly) UITableView* tableView;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic, copy) NSString* refreshedDataIdentifier;
@property (nonatomic, readwrite, strong) NSDate* lastSuccessfulRefreshDate;
@property (nonatomic, strong) NSTimer* showHideTimer;
@property (nonatomic, readwrite) BOOL isVisible;

@end

@implementation LGARefreshControl

- (id)initWithTableViewController:(UITableViewController*)tableViewController refreshedDataIdentifier:(NSString*)dataIdentifier {
    self = [super init];
    if (self) {
        if (!tableViewController) {
            [NSException raise:@"Illegal argument" format:@"tableviewcontroller cannot be nil"];
        }
        if (dataIdentifier && dataIdentifier.length == 0) {
            [NSException raise:@"Illegal argument" format:@"refreshedDataIdentifier cannot be of length 0 if not nil"];
        }
        
        // Need to start monitoring, otherwise sharedManager.networkReachabilityStatus is wrong
        // Bug in AFNetworkReachabilityManager ?
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        self.tableViewController = tableViewController;
        self.refreshedDataIdentifier = dataIdentifier;
        
        _showsDefaultRefreshingMessage = YES;
        self.errorMessageColor = [UIColor colorWithRed:0.827451 green:0.000000 blue:0.000000 alpha:1.0];
        if ([self.tableViewController respondsToSelector:@selector(refreshControl)]) { //>= iOS 6
            self.refreshControl = [[UIRefreshControl alloc] init];;
        } else {
            [NSException raise:@"Unsupported platform" format:@"LGRefreshControl requires iOS 6 or higher"];
        }
        self.message = nil;
        self.tableViewController.refreshControl = self.refreshControl;
    }
    return self;
}

- (void)uiRefreshControlValueChanged {
    [self.target performSelectorOnMainThread:self.selector withObject:nil waitUntilDone:YES];
}

- (void)setTarget:(id)target selector:(SEL)selector {
    [self.refreshControl removeTarget:self.target action:self.selector forControlEvents:UIControlEventValueChanged];
    [self.refreshControl addTarget:self action:@selector(uiRefreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
    self.target = target;
    self.selector = selector;
}

- (void)startRefreshing {
    if (self.showsDefaultRefreshingMessage) {
        [self startRefreshingWithMessage:NSLocalizedStringFromTable(@"Refreshing", @"LGALibrary", nil)];
    } else {
        [self startRefreshingWithMessage:@""];
    }
}

- (void)startRefreshingWithMessage:(NSString*)message {
    [self.showHideTimer invalidate];
    self.message = message;
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES]; //inset.top already contains normal top inset + refresh control height
    }
}

- (void)endRefreshing {
    [self.showHideTimer invalidate];
    self.message = nil;
    [self.refreshControl endRefreshing];
}

- (void)endRefreshingAndMarkSuccessful {
    [self endRefreshing];
    [self markRefreshSuccessful];
}

- (void)endRefreshingWithDelay:(NSTimeInterval)delay indicateErrorWithMessage:(NSString*)message {
    [self setProblemMessage:message];
    [self.showHideTimer invalidate];
    self.showHideTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(endRefreshing) userInfo:nil repeats:NO];
}

- (UITableView*)tableView {
    return self.tableViewController.tableView;
}

- (NSDate*)lastSuccessfulRefreshDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForLastRefresh]];
}

- (void)setLastSuccessfulRefreshDate:(NSDate*)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:[self keyForLastRefresh]];
}

+ (NSString*)keyForLastRefreshForDataIdentifier:(NSString*)dataIdentifier {
    return [NSString stringWithFormat:@"LGRefreshControlLastRefreshDate-%ud", (unsigned int)[dataIdentifier hash]];
}

- (NSString*)keyForLastRefresh {
    return [self.class keyForLastRefreshForDataIdentifier:self.refreshedDataIdentifier];
}

- (void)markRefreshSuccessful {
    if (!self.refreshedDataIdentifier) {
        [NSException raise:@"Unsupported operation" format:@"PCRefreshControl does not support markRefreshSuccessful without being initilized with a nil refreshedDataIdentifier"];
    }
    self.lastSuccessfulRefreshDate = [NSDate date]; //now
    self.message = nil; //will set last message to default => last refresh message
}

- (BOOL)shouldRefreshDataForValidity:(NSTimeInterval)validitySeconds {
    BOOL internetAvailable = NO;
    AFNetworkReachabilityManager* manager = [AFNetworkReachabilityManager sharedManager];
    if (manager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        internetAvailable = YES;
    } else {
        internetAvailable = [manager isReachable];
    }
    if (!self.refreshedDataIdentifier) {
        return internetAvailable;
    }
    NSTimeInterval diffWithLastRefresh = [[NSDate date] timeIntervalSinceDate:self.lastSuccessfulRefreshDate];
    if (diffWithLastRefresh > validitySeconds) {
        return internetAvailable;
    }
    return NO;
}

+ (void)deleteRefreshDateInfoForDataIdentifier:(NSString*)dataIdentifier {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self keyForLastRefreshForDataIdentifier:dataIdentifier]];
}

- (void)deleteRefreshDateInfo {
    [self.class deleteRefreshDateInfoForDataIdentifier:[self keyForLastRefresh]];
}

- (UIFont*)fontForMessage {
    return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

- (NSMutableAttributedString*)attributedTimeStringForLastRefresh {
    NSMutableAttributedString* attrString = nil;
    if (!self.lastSuccessfulRefreshDate) {
        attrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"LastUpdateNever", @"LGALibrary", nil)];
    } else if (fabs([self.lastSuccessfulRefreshDate timeIntervalSinceNow]) < 60.0) {
        attrString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"LastUpdateJustNow", @"LGALibrary", nil)];
    } else {
        NSString* lastUpdateLocalized = NSLocalizedStringFromTable(@"LastUpdate", @"LGALibrary", nil);
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        [dateFormatter setDoesRelativeDateFormatting:YES];
        NSString* dateString = [dateFormatter stringFromDate:self.lastSuccessfulRefreshDate];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        [dateFormatter setDoesRelativeDateFormatting:NO];
        NSString* timeString = [dateFormatter stringFromDate:self.lastSuccessfulRefreshDate];
       
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@", lastUpdateLocalized, dateString, timeString]];
    }
    if (self.tintColor) {
        [attrString addAttribute:NSForegroundColorAttributeName value:self.tintColor range:NSMakeRange(0, attrString.string.length)];
    }
    return attrString;
}

- (NSMutableAttributedString*)attributedStringForMessage:(NSString*)message {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:message];
    if (self.tintColor) {
        [attrString addAttribute:NSForegroundColorAttributeName value:self.tintColor range:NSMakeRange(0, attrString.string.length)];
    }
    return attrString;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    NSMutableAttributedString* attrString = ((NSMutableAttributedString*)self.refreshControl.attributedTitle); //we can assume that because UIRefreshControl retains it and we never set a non-mutable instance
    [attrString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSForegroundColorAttributeName value:tintColor range:NSMakeRange(0, attrString.length)];
}

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    NSMutableAttributedString* attrMessage = nil;
    if (message) {
        attrMessage = [self attributedStringForMessage:message];
    } else if (self.refreshedDataIdentifier) {
        attrMessage = [self attributedTimeStringForLastRefresh];
    }
    self.refreshControl.attributedTitle = attrMessage;
}

- (void)setProblemMessage:(NSString *)message {
    self.message = message;
    NSMutableAttributedString* attrString = ((NSMutableAttributedString*)self.refreshControl.attributedTitle); //we can assume that because UIRefreshControl retains it and we never set a non-mutable instance
    [attrString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSForegroundColorAttributeName value:self.errorMessageColor range:NSMakeRange(0, attrString.length)];
    self.refreshControl.attributedTitle = [attrString mutableCopy];
}

- (BOOL)isVisible {
    return self.refreshControl.refreshing;
}

@end
