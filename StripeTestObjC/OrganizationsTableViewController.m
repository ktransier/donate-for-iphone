//
//  OrganizationsTableViewController.m
//  StripeTestObjC
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
    self.navigationItem.title = @"Together";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self makeOrganizationsRequest];
    
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.937 green:0.282 blue:0.282 alpha:1];
//    self.refreshControl.tintColor = [UIColor whiteColor];
//    [self.refreshControl addTarget:self
//                            action:@selector(makeOrganizationsRequest)
//                  forControlEvents:UIControlEventValueChanged];
//    
//    self.tableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
    

}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.173 green:0.243 blue:0.314 alpha:1]];
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
    NSURL *url = [NSURL URLWithString:@"https://togetherapp.org/organizations.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        orgArray = [responseObject objectForKey:@"organizations"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request Failed: %@, %@", error, error.userInfo);
        [TSMessage showNotificationWithTitle:@"Warning!"
                                    subtitle:@"Network down!"
                                        type:TSMessageNotificationTypeWarning];
    }];
    [operation start];
    [self reloadData];
}


// Load each cell of table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *orgCellIdentifier = @"orgCell";
    OrgCell *cell = [tableView dequeueReusableCellWithIdentifier:orgCellIdentifier];
    NSDictionary* org = [orgArray objectAtIndex:indexPath.row];
    cell.orgNameLabel.text = org[@"name"];
    cell.orgContentLabel.text = org[@"content"];
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
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
    // Configure the cell...
 
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
