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

@import MapKit;

@interface LGAUserTrackingBarButtonItem : MKUserTrackingBarButtonItem

/**
 * @return a bar button item that behaves as MKUserTrackingBarButtonItem,
 * but automatically handles the request to OS (if necessary) to get localization authorization.
 * @discussion since iOS 8, -[CLLocationManager requestWhenInUseAuthorization] or -[CLLocationManager requestAlwaysAuthorization]
 * is required prior to locate user on the map. This class takes care of it.
 * @param requiredAuthorizationStatus can be either kCLAuthorizationStatusAuthorizedAlways or kCLAuthorizationStatusAuthorizedWhenInUse on iOS 8.
 * The parameter is ignored on iOS 7.
 */
- (instancetype)initWithMapView:(MKMapView *)mapView requiredAuthorizationStatus:(CLAuthorizationStatus)requiredAuthStatus;

/**
 * Same as initWithMapView:requiredAuthorizationStatus: with requiredAuthorizationStatus kCLAuthorizationStatusAuthorizedWhenInUse on iOS 8, 
 * and kCLAuthorizationStatusAuthorized on iOS 7.
 */
- (instancetype)initWithMapView:(MKMapView *)mapView;

@end
