//
//  PaymentViewController.h
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/13/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UIViewController
   @property(nonatomic, strong) NSDictionary* org;
   @property(nonatomic, strong) NSString* donationAmount;
@end
