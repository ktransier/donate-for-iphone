//
//  OrgDetailViewController.h
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/10/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organization.h"

@interface OrgDetailViewController : UIViewController
    @property(nonatomic, strong) NSDictionary* org;
@end