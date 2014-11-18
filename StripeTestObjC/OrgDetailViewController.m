//
//  OrgDetailViewController.m
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/10/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "OrgDetailViewController.h"
#import "WebViewController.h"
#import "Stripe.h"
#import "Stripe+ApplePay.h"
#import <QuartzCore/QuartzCore.h>

@interface OrgDetailViewController () <PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *donationAmount;
@property (weak, nonatomic) IBOutlet UIImageView *orgImage;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
@property (weak, nonatomic) IBOutlet UITextView *orgContentTextView;

@end

@implementation OrgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.donationAmount.delegate = self;
    // Do any additional setup after loading the view.
    
    self.orgNameLabel.text = self.org[@"name"];
    self.orgContentTextView.text = self.org[@"content"];
    [self.webButton setTitle:self.org[@"home_url"]forState:UIControlStateNormal];
    NSString* fullImageUrl = @"https://togetherapp.org/org-images/";
    
    NSString* imageURL = self.org[@"image_url"];
    fullImageUrl = [fullImageUrl stringByAppendingString:imageURL];
    self.orgImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fullImageUrl]]];
    self.orgImage.layer.cornerRadius = 100.0;
    self.orgImage.layer.borderWidth = 1.0;
    self.orgImage.layer.borderColor = [UIColor colorWithRed:0.855 green:0.875 blue:0.882 alpha:1].CGColor;
    self.orgImage.clipsToBounds = true;
//    
//    self.donateButton.backgroundColor = [UIColor colorWithRed:0.306 green:0.478 blue:0.682 alpha:1];
    self.donateButton.layer.borderColor = [[UIColor colorWithRed:0.306 green:0.478 blue:0.682 alpha:1] CGColor];
    self.donateButton.layer.borderWidth=2.0f;
    self.donateButton.layer.cornerRadius=8.0f;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string
{
    if (textField.text.length >= 4 && range.length == 0)
        return NO;
    return YES;
}


- (IBAction)donateButton:(id)sender {
    [self.donationAmount resignFirstResponder];
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:@"merchant.fm.kenneth.donate"];
    // Configure your request here.
    NSString *label = self.org[@"name"];
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.donationAmount.text];
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
    
//    if ([Stripe canSubmitPaymentRequest:request]) {
//        
//        PKPaymentAuthorizationViewController *paymentController;
//        paymentController = [[PKPaymentAuthorizationViewController alloc]
//                             initWithPaymentRequest:request];
//        [self presentViewController:paymentController animated:YES completion:nil];
//        paymentController.delegate = self;
//    } else {
        [self performSegueWithIdentifier: @"showStripeForm" sender: self];
//    }

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
    
    NSURL *url = [NSURL URLWithString:@"https://togetherapp.org/donations/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripe_token=%@&organization=%@&email=%@&amount=%@", token.tokenId, self.org[@"name"], email, self.donationAmount.text];
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

// Pass cell details to org detail view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showWebView"]) {
        WebViewController* destinationViewController = segue.destinationViewController;
        destinationViewController.url = self.org[@"url"];
    }
}

@end
