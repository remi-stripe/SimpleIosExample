//
//  PaymentViewController.h
//  SimpleIosExample
//
//  Created by Rémi Jannel on 11/3/16.
//  Copyright © 2016 Stripe. All rights reserved.
//


#ifndef PaymentViewController_h
#define PaymentViewController_h

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>

@class PaymentViewController;

@protocol PaymentViewControllerDelegate<NSObject>

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error;

@end

@interface PaymentViewController : UIViewController

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak) id<STPBackendCharging> backendCharger;
@property (nonatomic, weak) id<PaymentViewControllerDelegate> delegate;

@end

#endif /* PaymentViewController_h */
