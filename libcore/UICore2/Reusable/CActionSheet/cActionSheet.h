//
//  CActionSheet.h
//  UICore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../UIViewWithGradient/UIViewWithGradient.h"
#import "../SKAppColourScheme/SKAppColourScheme.h"

@class CActionSheet;

@protocol pActionSheetDelegate <NSObject>

-(void)selectedOption:(int)optionTag from:(CActionSheet*)sender WithState:(int)state;

@end

// <0 - not relevant, 0 - off, 1 - on
typedef enum CAOptionState_t {
  //CAOptionState_NOTSELECTED = -1,
  CAOptionState_NOTSELECTED = 0,
  CAOptionState_SELECTED
  //CAOptionState_SELECTED_MULTIPOSSIBLE = 2
} CAOptionState;

@interface CActionSheet : NSObject

@property (nonatomic, strong) NSMutableArray* arrOptions;

@property (nonatomic, strong) UIView* masterView;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIViewWithGradient* backgroundGradientView;
@property (nonatomic, strong) UIButton* btCancel;
@property (nonatomic, strong) UIView* parentView;
@property (nonatomic, weak) id<pActionSheetDelegate> delegate;

+(void)formatView:(UIView*)view_;

-(id)initOnView:(UIView*)parView withDelegate:(id<pActionSheetDelegate>)dlgt mainTitle:(NSString*)mainButtonTitle_ WithMultiSelection:(BOOL)withMultiSelection;
-(void)expand;
//-(void)addOption:(NSString*)optionTitle withImage:(UIImage*)optionImage andTag:(int)optionTag;
//-(void)addOption:(NSString *)optionTitle withImage:(UIImage *)optionImage andTag:(int)optionTag andState:(CAOptionState)state_;
-(void)addOption:(NSString *)optionTitle withImage:(UIImage *)optionImage andTag:(int)optionTag AndSelected:(BOOL)selected;

@end

@interface COptionDefinition : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic) int tag;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) UIImageView* imageView;
//@property (nonatomic)   int state; //<0 - not relevant, 0 - off, 1 - on

@end