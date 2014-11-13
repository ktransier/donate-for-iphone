//
//  OrgDetailViewController.m
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/10/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "OrgDetailViewController.h"
#import "Stripe.h"
#import "Stripe+ApplePay.h"

@interface OrgDetailViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *donationAmount;
@property (weak, nonatomic) IBOutlet UIImageView *orgImage;
@property (weak, nonatomic) IBOutlet UILabel *orgContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;
@property CGPoint originalCenter;

@end

@implementation OrgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.orgNameLabel.text = self.org[@"name"];
    self.orgContentLabel.text = self.org[@"content"];
    NSString* fullImageUrl = @"http://donate-rails.herokuapp.com/org-images/";
    
    NSString* imageURL = self.org[@"image_url"];
    fullImageUrl = [fullImageUrl stringByAppendingString:imageURL];
    self.orgImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fullImageUrl]]];
    self.orgImage.layer.cornerRadius = 100.0;
    self.orgImage.clipsToBounds = true;
    
    self.donateButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.259 blue:0.318 alpha:1];
    
    self.originalCenter = self.view.center;
    
}

- (IBAction)donateButton:(id)sender {
    [self.donationAmount resignFirstResponder];
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:@"merchant.fm.kenneth.donate"];
    // Configure your request here.
    NSString *label = self.org[@"name"];
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.donationAmount.text];
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
        PKPaymentAuthorizationViewController *paymentController;
        paymentController = [[PKPaymentAuthorizationViewController alloc]
                             initWithPaymentRequest:request];
        [self presentViewController:paymentController animated:YES completion:nil];
        paymentController.delegate = self;
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.donationAmount resignFirstResponder];
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [Stripe createTokenWithPayment:payment
                        completion:^(STPToken *token, NSError *error) {
                            if (error) {
                                completion(PKPaymentAuthorizationStatusFailure);
                                return;
                            }
                            /*
                             We'll implement this below in "Sending the token to your server".
                             Notice that we're passing the completion block through.
                             See the above comment in didAuthorizePayment to learn why.
                             */
                            [self createBackendChargeWithToken:token completion:completion];
                        }];
}

// ViewController.m

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:@"email"];
    
    NSURL *url = [NSURL URLWithString:@"http://donate-rails.herokuapp.com/donations/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@&selectedOrg=%@&email=%@", token.tokenId, self.org[@"name"], email];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   completion(PKPaymentAuthorizationStatusFailure);
                               } else {
                                   completion(PKPaymentAuthorizationStatusSuccess);
                               }
                           }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
