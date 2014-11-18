//
//  OrgCell.h
//  StripeTestObjC
//
//  Created by Kenneth Transier on 11/10/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrgCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
