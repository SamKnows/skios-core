//
//  SKATestOverviewCell2.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKATestResultSuperCell.h"

@class SKATestResults;

@class SKATestsListController2;

@interface SKATestOverviewCell2 : SKATestResultSuperCell
{
    bool initialised;
    SKATestResults* testResult;
    //SKATestsListController2* testListController;
    
    float y;
}

-(void)initCell;
-(void)setTest:(SKATestResults*)testResult;

-(UIView*)getView;
+(NSString*)get3digitsNumber:(float)number_;

@end
