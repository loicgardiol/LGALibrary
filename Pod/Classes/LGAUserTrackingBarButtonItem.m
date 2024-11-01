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

//  Created by Loïc Gardiol on 01.09.14.

#import "LGAUserTrackingBarButtonItem.h"

#import "LGAUtils.h"

#import "UIView+LGAAdditions.h"

@interface LGAUserTrackingBarButtonItem ()<CLLocationManagerDelegate>

@property (nonatomic) CLAuthorizationStatus requiredAuthStatus;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) UITapGestureRecognizer* bufferTapGesture;
@property (nonatomic) BOOL waitingForAuth;

@end

@implementation LGAUserTrackingBarButtonItem

#pragma mark - Init

- (instancetype)initWithMapView:(MKMapView *)mapView {
    return [self initWithMapView:mapView requiredAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
}

- (instancetype)initWithMapView:(MKMapView *)mapView requiredAuthorizationStatus:(CLAuthorizationStatus)requiredAuthStatus {
    self = [super initWithMapView:mapView];
    if (self) {
        self.requiredAuthStatus = requiredAuthStatus;
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        UIView* view = [self valueForKey:@"view"];
        self.bufferTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTapped)];
        self.bufferTapGesture.cancelsTouchesInView = YES;
        [view addGestureRecognizer:self.bufferTapGesture];
    }
    return self;
}

#pragma mark - Public

- (void)simulateTap {
    [self selfTapped];
}

#pragma mark - Private

- (void)selfTapped {
    CLAuthorizationStatus currentAuthStatus = self.locationManager.authorizationStatus;
    if (currentAuthStatus == kCLAuthorizationStatusDenied || currentAuthStatus == kCLAuthorizationStatusRestricted) {
        UIViewController* viewController = [self.mapView lga_parentViewController];
        if (viewController) {
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"LocationAccessDenied", @"LGALibrary", nil) message:NSLocalizedStringFromTable(@"GrantAccessToLocationExplanations", @"LGALibrary", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"LGALibrary", nil) style:UIAlertActionStyleDefault handler:nil]];
            [viewController presentViewController:alertController animated:YES completion:nil];
        }
        return;
    }
    if (currentAuthStatus == kCLAuthorizationStatusNotDetermined) {
        if ([self requestAuthorizationIfNecessary]) {
            self.waitingForAuth = YES;
            return;
        }
    }
    self.waitingForAuth = NO;
    
    //calling original (super) self.action on self.target safely
    IMP imp = [self methodForSelector:self.action];
    void (*func)(id, SEL, id) = (void *)imp;
    func(self, self.action, self);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (self.waitingForAuth) {
        [self selfTapped];
    }
}

#pragma mark - Private

/**
 * @return YES if auth request was necessary.
 */
- (BOOL)requestAuthorizationIfNecessary {
    CLAuthorizationStatus authStatus = self.locationManager.authorizationStatus;
    if (authStatus == kCLAuthorizationStatusAuthorizedAlways) {
        return NO;
    }
    switch (self.requiredAuthStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                return NO;
            }
            [self.locationManager requestWhenInUseAuthorization];
            return YES;
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager requestAlwaysAuthorization];
            return YES;
        default:
            break;
    }
    return NO;
}

@end
