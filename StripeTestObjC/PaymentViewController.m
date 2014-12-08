//
//  PaymentViewController.m
//  Together
//
//  Created by Kenneth Transier on 11/13/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "PaymentViewController.h"
#import "Stripe.h"
#import "PTKView.h"
#import "TSMessage.h"

@interface PaymentViewController ()<PTKViewDelegate>

    @property (weak, nonatomic) IBOutlet UIButton *confirmDonationButton;
    @property (weak, nonatomic) IBOutlet PTKView *paymentView;

@end

@implementation PaymentViewController

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        // Set payment view delegate
        self.paymentView.delegate = self;
        [self.view addSubview:self.paymentView];
        
        // Set confirm donation button title color
        [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1] forState:UIControlStateNormal];
    }

    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
    }
    - (IBAction)closeButton:(id)sender {
        
      // Dismiss payment controller
      [self dismissViewControllerAnimated:YES completion:nil];
    }

    // If card is valid format, enable confirm button
    - (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
    {
        if (valid) {
          self.confirmDonationButton.enabled = true;
          [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.306 green:0.478 blue:0.682 alpha:1] forState:UIControlStateNormal];
        } else {
          self.confirmDonationButton.enabled = false;
          [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1] forState:UIControlStateNormal];
        }
    }


    - (IBAction)confirmDonationButton:(id)sender {
        
        // Prevent multiple donations
        self.confirmDonationButton.enabled = false;
        [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1] forState:UIControlStateNormal];
        
        // Create Stripe card object
        STPCard *card = [[STPCard alloc] init];
        card.number = self.paymentView.card.number;
        card.expMonth = self.paymentView.card.expMonth;
        card.expYear = self.paymentView.card.expYear;
        card.cvc = self.paymentView.card.cvc;
        
        // Create Stripe token
        [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
            if (error) {
              // Handle error from Stripe
            } else {
                [self createBackendChargeWithToken:token];
            }
        }];
    }

    - (void)createBackendChargeWithToken:(STPToken *)token {
        
        // Set user email default
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* email = [defaults objectForKey:@"email"];
        
        // Set URL
        NSURL *url = [NSURL URLWithString:@"https://donateapp.co/donations/token"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"POST";
        NSString *body     = [NSString stringWithFormat:@"stripe_token=%@&organization_name=%@&email=%@&amount=%@&organization_id=%@", token.tokenId, self.org[@"name"], email, self.donationAmount, self.org[@"id"]];
        request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        // Send request
        [NSURLConnection sendAsynchronousRequest:request
                       queue:[NSOperationQueue mainQueue]
           completionHandler:^(NSURLResponse *response,
                               NSData *data,
                               NSError *error) {
               if (error) {
                   
               } else {
                   NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                   NSString* message = parsedData[@"message"];
                   if ([message isEqual:@"Your card was charged successfully."]) {
                       [TSMessage showNotificationWithTitle:@"Success!"
                                                   subtitle:@"Thank you for your donation!"
                                                   type:TSMessageNotificationTypeSuccess];
                       [self.view endEditing:YES];
                       [self dismissViewControllerAnimated:YES completion:nil];
                   } else {
                      // Show error notification and enable donation button
                      [TSMessage showNotificationInViewController:self
                                                  title:@"Card Error!"
                                                  subtitle:message
                                                  type:TSMessageNotificationTypeError];

                       [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.306 green:0.478 blue:0.682 alpha:1] forState:UIControlStateNormal];

                   };
                };
           }];
    }
@end
