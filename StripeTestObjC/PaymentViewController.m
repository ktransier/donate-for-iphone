//
//  PaymentViewController.m
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/13/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "PaymentViewController.h"
#import "Stripe.h"
#import "PTKView.h"

@interface PaymentViewController ()<PTKViewDelegate>
@property(weak, nonatomic) PTKView *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *confirmDonationButton;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(42.5,70,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
    self.confirmDonationButton.layer.borderWidth=2.0f;
    self.confirmDonationButton.layer.cornerRadius=8.0f;
    self.confirmDonationButton.layer.borderColor = [[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1] CGColor];
    [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeButton:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    self.confirmDonationButton.enabled = valid;
    self.confirmDonationButton.layer.borderColor = [[UIColor colorWithRed:0.306 green:0.478 blue:0.682 alpha:1] CGColor];
    [self.confirmDonationButton setTitleColor:[UIColor colorWithRed:0.306 green:0.478 blue:0.682 alpha:1] forState:UIControlStateNormal];
}


- (IBAction)confirmDonationButton:(id)sender {
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
//            [self handleError:error];
        } else {
            [self createBackendChargeWithToken:token];
        }
    }];
}

- (void)createBackendChargeWithToken:(STPToken *)token {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:@"email"];
    
    NSURL *url = [NSURL URLWithString:@"https://togetherapp.org/donations/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripe_token=%@&organization=%@&email=%@&amount=%@", token.tokenId, @"HRW", email, @"25"];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {

                               } else {
                                  [self.view endEditing:YES];
                                  [self dismissViewControllerAnimated:YES completion:nil];
                               }
                           }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
