//
//  SKAGraphResultFooterCell.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKARangeDelegate;

@interface SKAGraphResultFooterCell : UITableViewCell
{
    id <SKARangeDelegate> delegate;
}

@property (atomic, strong) id <SKARangeDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

- (IBAction)back:(id)sender;
- (IBAction)next:(id)sender;

@end

@protocol SKARangeDelegate

- (void)back;
- (void)next;

@end
