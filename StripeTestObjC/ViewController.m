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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

NSArray *orgs;
NSString *selectedOrg;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    Organization* org1 = [[Organization alloc] init];
    org1.name = @"Humans Right Watch";
    org1.content = @"HRW provides timely information about human rights crises in 90+ countries.";
    org1.image = [UIImage imageNamed:@"hrw.png"];
    
    Organization* org2 = [[Organization alloc] init];
    org2.name = @"Malala Fund";
    org2.content = @"Malala fund is focused on helping girls go to school and raise their voices for the right to education.";
    org2.image = [UIImage imageNamed:@"malala.jpg"];
    
    Organization* org3 = [[Organization alloc] init];
    org3.name = @"Wounded Warrior Project";
    org3.content = @"Wounded Warrior Project is a military/veterans charity organization empowering injured veterans and their families.";
    org3.image = [UIImage imageNamed:@"wwp.jpg"];
    
    Organization* org4 = [[Organization alloc] init];
    org4.name = @"Girls Who Code";
    org4.content = @"Closing the gender gap in the technology and engineering sectors";
    org4.image = [UIImage imageNamed:@"girlswhocode.png"];

    Organization* org5 = [[Organization alloc] init];
    org5.name = @"Doctors Without Borders";
    org5.content = @"Delivering emergency medical aid to people affected by conflict, epidemics, disasters or exclusion from health care";
    org5.image = [UIImage imageNamed:@"msf.jpg"];
    
    Organization* org6 = [[Organization alloc] init];
    org6.name = @"Ushahidi";
    org6.content = @"Empowering people to make a serious impact with open source technologies, cross-sector partnerships, and ground-breaking ventures";
    org6.image = [UIImage imageNamed:@"ushahidi.jpg"];
    
    Organization* org7 = [[Organization alloc] init];
    org7.name = @"Charity: Water";
    org7.content = @"Bringing clean, safe drinking water to people in developing countries";
    org7.image = [UIImage imageNamed:@"charitywater.jpg"];
    
    Organization* org8 = [[Organization alloc] init];
    org8.name = @"Make a Wish Foundation";
    org8.content = @"Granting the wishes of children with life-threatening illnesses";
    org8.image = [UIImage imageNamed:@"maw.jpg"];
    
    Organization* org9 = [[Organization alloc] init];
    org9.name = @"Habitat For Humanity";
    org9.content = @"Bringing people together to build homes, community, and hope";
    org9.image = [UIImage imageNamed:@"habitat.jpg"];
    
    Organization* org10 = [[Organization alloc] init];
    org10.name = @"American Red Cross";
    org10.content = @"Disaster relief at home and abroad, CPR certification and first aid courses, blood donation, and emergency preparedness";
    org10.image = [UIImage imageNamed:@"americanredcross.jpg"];

    Organization* org11 = [[Organization alloc] init];
    org11.name = @"Amnesty International";
    org11.content = @"Conduct research and generate action to prevent and end grave abuses of human rights, and to demand justice for those whose rights have been violated";
    org11.image = [UIImage imageNamed:@"amnesty.jpg"];

    orgs = [NSArray arrayWithObjects:org1, org2, org3, org4, org5, org6, org7, org8, org9, org10, org11, nil];
    self.navigationItem.title = @"Non-Profits";
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
    static NSString *orgCellIdentifier = @"orgCell";
    OrgCell *cell = [tableView dequeueReusableCellWithIdentifier:orgCellIdentifier];
    Organization* org = [orgs objectAtIndex:indexPath.row];
    cell.orgNameLabel.text = org.name;
    cell.image.image = org.image;
    cell.image.layer.cornerRadius = 30.0;
    cell.image.clipsToBounds = true;
    return cell;
}

// Pass cell details to org detail view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showOrgDetail"]) {
        OrgDetailViewController* detailVC = segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Organization* org = orgs[indexPath.row];
        detailVC.org = org;
    }
}

// Send to detail view controller when tableview cell tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showOrgDetail" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
