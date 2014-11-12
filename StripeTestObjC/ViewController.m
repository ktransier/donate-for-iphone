//
//  ViewController.m
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/9/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "ViewController.h"
#import "OrgDetailViewController.h"
#import "OrgCell.h"
#import "Organization.h"
#import "AFNetworking.h"

@interface ViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

    NSString *selectedOrg;
    NSArray *orgArray;

    - (void)viewDidLoad {
        [super viewDidLoad];
        self.navigationItem.title = @"Non-Profits";
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self makeOrganizationsRequest];
    }

    -(void)awakeFromNib {
        [super awakeFromNib];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.22 green:0.259 blue:0.318 alpha:1]];
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
        NSURL *url = [NSURL URLWithString:@"http://donate-rails.herokuapp.com/organizations.json"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //AFNetworking asynchronous url request
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            orgArray = [responseObject objectForKey:@"organizations"];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Request Failed: %@, %@", error, error.userInfo);
        }];
        [operation start];
    }


    // Load each cell of table view
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *orgCellIdentifier = @"orgCell";
        OrgCell *cell = [tableView dequeueReusableCellWithIdentifier:orgCellIdentifier];
        NSDictionary* org = [orgArray objectAtIndex:indexPath.row];
        cell.orgNameLabel.text = org[@"name"];
        NSString* fullImageUrl = @"http://donate-rails.herokuapp.com/org-images/";
        NSString* imageURL = org[@"image_url"];
        fullImageUrl = [fullImageUrl stringByAppendingString:imageURL];
         cell.image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fullImageUrl]]];
        cell.image.layer.cornerRadius = 30.0;
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
    }
@end
