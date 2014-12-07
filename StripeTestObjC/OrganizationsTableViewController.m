//
//  OrganizationsTableViewController.m
//  Together
//
//  Created by Kenneth Transier on 11/14/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "OrganizationsTableViewController.h"
#import "OrgDetailViewController.h"
#import "OrgCell.h"
#import "Organization.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "TSMessage.h"

@interface OrganizationsTableViewController ()

    @property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrganizationsTableViewController

    NSString *selectedOrg;
    NSArray *orgArray;

    - (void)viewDidLoad {
        
        [super viewDidLoad];
        [TSMessage addCustomDesignFromFileWithName:@"TSMessageAlternativeDesign.json"];
        
        // Set navigation bar text and table view attributes
        self.navigationItem.title = @"Together";
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        self.tableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
        
        // Get organizations
        [self makeOrganizationsRequest];
        
        // Load and set refresh control attributes
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        self.refreshControl.tintColor = [UIColor blackColor];
        [self.refreshControl addTarget:self
                                action:@selector(makeOrganizationsRequest)
                      forControlEvents:UIControlEventValueChanged];

    }


    - (void)reloadData {
        // Reload table data
        [self.tableView reloadData];
        
        // End the refreshing
        if (self.refreshControl) {
            [self.refreshControl endRefreshing];
        }
    }

    -(void)awakeFromNib {
        [super awakeFromNib];
        
        // Set navigation bar background attributes
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.173 green:0.243 blue:0.314 alpha:1]];
        
        UIImage *image = [UIImage imageNamed: @"AppTitleBarLogo"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
        
        self.navigationItem.titleView = imageView;
    }

    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
    }

    // Number of rows in table view
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        return [orgArray count];
    }

    -(void)makeOrganizationsRequest
    {
        // Set url
        NSURL *url = [NSURL URLWithString:@"https://togetherapp.org/organizations.json"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // AFNetworking asynchronous url request
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            orgArray = [responseObject objectForKey:@"organizations"];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Request Failed: %@, %@", error, error.userInfo);
            [TSMessage showNotificationWithTitle:@"Network error"
                                        subtitle:@"Please check your internet connection."
                                            type:TSMessageNotificationTypeError];
        }];
        [operation start];
        [self reloadData];
    }


    // Load each cell of table view
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        
        // Prepare cell
        static NSString *orgCellIdentifier = @"orgCell";
        OrgCell *cell = [tableView dequeueReusableCellWithIdentifier:orgCellIdentifier];
        NSDictionary* org = [orgArray objectAtIndex:indexPath.row];
        
        // Set cell name label
        cell.orgNameLabel.text = org[@"name"];
        
        // Set cell image
        NSString* fullImageURL = @"https://togetherapp.org/org-images/";
        NSString* imageURL = org[@"image_url"];
        fullImageURL = [fullImageURL stringByAppendingString:imageURL];
        [cell.image sd_setImageWithURL:[NSURL URLWithString:fullImageURL]
                      placeholderImage:[UIImage imageNamed:@"app-icon.png"]];
        cell.image.layer.cornerRadius = 17.5;
        cell.image.layer.borderWidth = 1.0;
        cell.image.layer.borderColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1].CGColor;
        cell.image.clipsToBounds = true;
        
        return cell;
        
    }

    // Pass cell details to org detail view controller
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
        if ([segue.identifier isEqual:@"showOrgDetail"]) {
            OrgDetailViewController* detailVC = segue.destinationViewController;
            NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
            detailVC.org = orgArray[indexPath.row];
        }
    
    }

    // Send to detail view controller when tableview cell tapped
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
        [self performSegueWithIdentifier:@"showOrgDetail" sender:self];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Remove text from back button
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    }

@end
