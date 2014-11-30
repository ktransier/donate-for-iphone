//
//  OrgDetailViewController.m
//  Together
//
//  Created by Kenneth Transier on 11/10/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "OrgDetailViewController.h"
#import "PaymentViewController.h"
#import "WebViewController.h"
#import "Stripe.h"
#import "Stripe+ApplePay.h"
#import "QuartzCore/QuartzCore.h"
#import "TSMessage.h"

@interface OrgDetailViewController () <PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate>

    @property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
    @property (weak, nonatomic) IBOutlet UITextField *donationAmount;
    @property (weak, nonatomic) IBOutlet UIImageView *orgImage;
    @property (weak, nonatomic) IBOutlet UIButton *donateButton;
    @property (weak, nonatomic) IBOutlet UIButton *webButton;
    @property (weak, nonatomic) IBOutlet UITextView *orgContentTextView;
    @property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation OrgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set delegates
    self.donationAmount.delegate = self;
    self.emailField.delegate = self;
    
    // Load name, content, and web link
    self.orgNameLabel.text = self.org[@"name"];
    self.orgContentTextView.text = self.org[@"content"];
    [self.webButton setTitle:self.org[@"home_url"]forState:UIControlStateNormal];
    
    // Load image
    NSString* fullImageUrl = @"https://togetherapp.org/org-images/";
    NSString* imageURL = self.org[@"image_url"];
    fullImageUrl = [fullImageUrl stringByAppendingString:imageURL];
    self.orgImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fullImageUrl]]];
    self.orgImage.layer.cornerRadius = 72.5;
    self.orgImage.layer.borderWidth = 1.0;
    self.orgImage.layer.borderColor = [UIColor colorWithRed:0.855 green:0.875 blue:0.882 alpha:1].CGColor;
    self.orgImage.clipsToBounds = true;
    
    // Prefill email from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:@"email"];
    self.emailField.text = email;
    
}

// Resign keyboards if anywhere else touched on screen
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.donationAmount resignFirstResponder];
        [self.emailField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string
{
    // Prevent donation amount from exceeding $9,999 USD
    if (textField.text.length >= 4 && range.length == 0 && textField == self.donationAmount)
        return NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // Disable donate button when value below $1 USD
    NSInteger amount = [textField.text integerValue];
    if (amount < 1 && textField == self.donationAmount) {
        self.donateButton.enabled = false;
    } else {
        self.donateButton.enabled = true;
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    // Basic email validation
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction)donateButton:(id)sender {
    
    // Error message unless donation amount between $1 and $9,999 USD
    if (![self.donationAmount.text integerValue] > 0 && [self.donationAmount.text integerValue] < 10000) {
        
        [TSMessage showNotificationWithTitle:@"Warning!"
                                    subtitle:@"Please enter a value greater than 0!"
                                        type:TSMessageNotificationTypeWarning];

    // Error message unless valid email address
    } else if (![self NSStringIsValidEmail:self.emailField.text]) {
        
        [TSMessage showNotificationWithTitle:@"Warning!"
                                    subtitle:@"Please enter a valid email!"
                                        type:TSMessageNotificationTypeWarning];
    
    // Process donation
    } else {
        
        // Set user defaults email to current email value
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.emailField.text forKey:@"email"];
        [defaults synchronize];
        
        // Resign keyboards
        [self.donationAmount resignFirstResponder];
        [self.emailField resignFirstResponder];
        
        // Setup ApplePay request
        PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.fm.kenneth.donate"];
        
        // Configure ApplePay request
        NSString *label = self.org[@"name"];
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.donationAmount.text];
        request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
        
        // Determine if device ApplePay capable
        if ([Stripe canSubmitPaymentRequest:request]) {
            
            // Toggle ApplePay view controller
            PKPaymentAuthorizationViewController *paymentController;
            paymentController = [[PKPaymentAuthorizationViewController alloc]
                                 initWithPaymentRequest:request];
            [self presentViewController:paymentController animated:YES completion:nil];
            paymentController.delegate = self;
        
        // Else trigger segue to manual credit card entry
        } else {
            [self performSegueWithIdentifier: @"showStripeForm" sender: self];
        }

        
    }

}

// Send to payment handler
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
       didAuthorizePayment:(PKPayment *)payment
       completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

// Dismiss ApplePay viewcontroller
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Handle ApplePay successful authorization or error
- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [Stripe createTokenWithPayment:payment
        completion:^(STPToken *token, NSError *error) {
                if (error) {
                    completion(PKPaymentAuthorizationStatusFailure);
                    return;
                }
                [self createBackendChargeWithToken:token completion:completion];
            }];
}

// Send charge token to Together API and handle returned
- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    // Get email
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:@"email"];
    
    // Setup request
    NSURL *url = [NSURL URLWithString:@"https://togetherapp.org/donations/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripe_token=%@&organization_name=%@&email=%@&amount=%@&organization_id=%@", token.tokenId, self.org[@"name"], email, self.donationAmount.text, self.org[@"id"]];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    // Send charge token
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   completion(PKPaymentAuthorizationStatusFailure);
                               } else {
                                   NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   NSString* message = parsedData[@"message"];
                                   if ([message isEqual:@"Your card was charged successfully."]) {
                                       [TSMessage showNotificationWithTitle:@"Success!"
                                                                   subtitle:@"Thank you for your donation!"
                                                                       type:TSMessageNotificationTypeSuccess];
                                       completion(PKPaymentAuthorizationStatusSuccess);
                                   } else {
                                       [TSMessage showNotificationInViewController:self
                                                                             title:@"Card Error!"
                                                                          subtitle:message
                                                                              type:TSMessageNotificationTypeError];
                                        completion(PKPaymentAuthorizationStatusFailure);
                                       
                                   };
                               }
                           }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Pass cell details to web view or manual credit card entry
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"showWebView"]) {
        WebViewController* destinationViewController = segue.destinationViewController;
        destinationViewController.url = self.org[@"url"];
    }

    if ([segue.identifier isEqual:@"showStripeForm"]) {
        PaymentViewController* destinationViewController = segue.destinationViewController;
        destinationViewController.org = self.org;
        destinationViewController.donationAmount = self.donationAmount.text;
    }
    
    // Remove back button text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

@end
