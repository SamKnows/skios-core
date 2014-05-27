//
//  UIView+SKExtensions.h
//

#import <UIKit/UIKit.h>

typedef void (^SKUIAlertViewClickedBlock)(UIAlertView *inView, NSInteger buttonIndex);
typedef void (^SKUIAlertViewCancelBlock)(UIAlertView *inView);


@interface UIAlertView (IMExtensionsAlertView)

@property (nonatomic,copy) SKUIAlertViewClickedBlock clickedBlock;
@property (nonatomic, copy) SKUIAlertViewCancelBlock cancelBlock;

-(void)showWithBlock:(SKUIAlertViewClickedBlock)clickedBlock;
-(void)showWithBlock:(SKUIAlertViewClickedBlock)clickedBlock cancelBlock:(SKUIAlertViewCancelBlock)cancelBlock;

@end
