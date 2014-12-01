//
//  SettingsViewController.m
//  Together
//
//  Created by Kenneth Transier on 11/14/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation SettingsViewController

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        // Fill in existing email value
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.emailField.text = [defaults objectForKey:@"email"];
    }

    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
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

@end
