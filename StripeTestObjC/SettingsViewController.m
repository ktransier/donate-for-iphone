//
//  SettingsViewController.m
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/13/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.emailField.text = [defaults objectForKey:@"email"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveSettings:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.emailField resignFirstResponder];
    
    NSString* email = [self.emailField text];
    
    [defaults setObject:email forKey:@"email"];
    
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)closeSettings:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
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
