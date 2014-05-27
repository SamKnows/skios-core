//
//  SKAGraphResultCell.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKAGraphResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;
@property (weak, nonatomic) IBOutlet UIImageView *lblIcon;

@end
