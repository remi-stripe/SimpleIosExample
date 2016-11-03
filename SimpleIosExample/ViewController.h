//
//  ViewController.h
//  SimpleIosExample
//
//  Created by Rémi Jannel on 11/3/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>

typedef NS_ENUM(NSInteger, STPBackendChargeResult) {
    STPBackendChargeResultSuccess,
    STPBackendChargeResultFailure,
};

typedef void (^STPTokenSubmissionHandler)(STPBackendChargeResult status, NSError *error);

@protocol STPBackendCharging <NSObject>

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion;

@end

@interface ViewController : UIViewController<STPBackendCharging>

@end
