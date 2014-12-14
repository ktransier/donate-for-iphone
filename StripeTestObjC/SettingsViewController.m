//
//  SettingsViewController.m
//  Together
//
//  Created by Kenneth Transier on 11/14/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "SettingsViewController.h"
#import "WebViewController.h"

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

    - (IBAction)doneButton:(id)sender {
        
        // Save email
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self.emailField resignFirstResponder];
        NSString* email = [self.emailField text];
        [defaults setObject:email forKey:@"email"];
        [defaults synchronize];
        
        // Return
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }

    // Send to detail view controller when tableview cell tapped
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            
            [self performSegueWithIdentifier:@"showAbout" sender: self];
        }

        if (indexPath.section == 1 && indexPath.row == 1) {
            
            [self performSegueWithIdentifier:@"showFAQS" sender: self];
        }
        
        if (indexPath.section == 1 && indexPath.row == 2) {
            
            [self performSegueWithIdentifier:@"showPrivacyPolicy" sender: self];
        }

        if (indexPath.section == 1 && indexPath.row == 3) {
            
            [self performSegueWithIdentifier:@"showCredits" sender: self];
        }
        if (indexPath.section == 1 && indexPath.row == 4                                                                                                                                            ) {
            
            // Set mailview navbar to white
            [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
            
            // Set mailview
            NSArray *toRecipents = [NSArray arrayWithObject:@"team@donateapp.co"];
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setToRecipients:toRecipents];
            mailComposer.navigationBar.translucent = false;
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    }

    - (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
    {
        switch (result)
        {
            case MFMailComposeResultCancelled:
                NSLog(@"Mail cancelled");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"Mail saved");
                break;
            case MFMailComposeResultSent:
                NSLog(@"Mail sent");
                break;
            case MFMailComposeResultFailed:
                NSLog(@"Mail sent failure: %@", [error localizedDescription]);
                break;
            default:
                break;
        }
        
        // Set mailview navbar color back to original color
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.173 green:0.243 blue:0.314 alpha:1]];
        
        // Close the Mail Interface
        [self dismissViewControllerAnimated:YES completion:NULL];
    }

    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
        if ([segue.identifier isEqual:@"showAbout"]) {
            WebViewController* destinationViewController = segue.destinationViewController;
            destinationViewController.url = @"https://donateapp.co/about";
            destinationViewController.pageTitle = @"About";
        }
        
        if ([segue.identifier isEqual:@"showFAQS"]) {
            WebViewController* destinationViewController = segue.destinationViewController;
            destinationViewController.url = @"https://donateapp.co/about#faq";
            destinationViewController.pageTitle = @"FAQ";
        }

        if ([segue.identifier isEqual:@"showPrivacyPolicy"]) {
            WebViewController* destinationViewController = segue.destinationViewController;
            destinationViewController.url = @"https://donateapp.co/privacy-policy";
            destinationViewController.pageTitle = @"Privacy Policy";
        }

        if ([segue.identifier isEqual:@"showCredits"]) {
            WebViewController* destinationViewController = segue.destinationViewController;
            destinationViewController.url = @"https://donateapp.co/about#credits";
            destinationViewController.pageTitle = @"Credits";
        }
        

        
        // Remove back button text
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
    }


@end
