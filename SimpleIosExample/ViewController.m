//
//  ViewController.m
//  SimpleIosExample
//
//  Created by Rémi Jannel on 11/3/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

#import "ViewController.h"
#import <Stripe/Stripe.h>
#import "PaymentViewController.h"
#import "Constants.h"


@interface ViewController () <PaymentViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSError *applePayError;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentError:(NSError *)error {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)paymentSucceeded {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Success" message:@"Payment successfully created!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)beginCustomPayment:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    paymentViewController.amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
    paymentViewController.backendCharger = self;
    paymentViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        if (error) {
            [self presentError:error];
        } else {
            [self paymentSucceeded];
        }
    }];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *urlString = [BackendChargeURLString stringByAppendingPathComponent:@"charge_card"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postBody = [NSString stringWithFormat:@"stripe_token=%@&amount=%@", token.tokenId, @1000];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:data
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                          if (!error && httpResponse.statusCode != 200) {
                                                              error = [NSError errorWithDomain:StripeDomain
                                                                                          code:STPInvalidRequestError
                                                                                      userInfo:@{NSLocalizedDescriptionKey: @"There was an error connecting to your payment backend."}];
                                                          }
                                                          if (error) {
                                                              completion(STPBackendChargeResultFailure, error);
                                                          } else {
                                                              completion(STPBackendChargeResultSuccess, nil);
                                                          }
                                                      }];
    
    [uploadTask resume];
}

@end
