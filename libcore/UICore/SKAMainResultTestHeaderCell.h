//
//  SKAMainResultTestHeaderCell.h
//  SKCore
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKAMainResultTestHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

-(void) setLabelText:(NSString*)inLabelText DetailText:(NSString*)inDetailText;

@end
