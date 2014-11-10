//
//  ViewController.m
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/9/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "ViewController.h"
#import "OrgDetailViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

NSArray *orgs;
NSString *selectedOrg;


- (void)viewDidLoad {
    [super viewDidLoad];
    orgs = [NSArray arrayWithObjects:@"Humans Right Watch", @"Doctors Without Borders", @"Girls Who Code", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Number of rows in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [orgs count];
}

// Load each cell of table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [orgs objectAtIndex:indexPath.row];
    return cell;
}

// Pass cell details to org detail view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showOrgDetail"]) {
        OrgDetailViewController* detailVC = segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSString* orgName = orgs[indexPath.row];
        NSLog(orgName);
        detailVC.orgName = orgName;
    }
}

// Send to detail view controller when tableview cell tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"showOrgDetail" sender:self];
    
}


@end
