//
//  SKBSummaryTableViewCell.h
//  SKCore
//
//  Created by Pete Cole on 30/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKBSummaryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *topLeftImage;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftAverageValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftAverageUnitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightBestValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightBestUnitsLabel;

-(void)prepareWithTopLeftImage:(UIImage*)inTopLeftImage TopLeftTitle:(NSString*)inTopLeftTitle LeftAverageValue:(NSString*)inLeftAverageValue LeftAverageUnits:(NSString*)inLeftAverageUnits RightBestValue:(NSString*)inRightBestValue RightBestUnits:(NSString*)inRightBestUnits;

@end
