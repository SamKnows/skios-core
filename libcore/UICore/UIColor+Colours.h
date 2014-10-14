//
//  UIColor+Colours.h
//

#import <UIKit/UIKit.h>

// Color Scheme Creation Enum
typedef enum
{
    ColorSchemeAnalagous = 0,
    ColorSchemeMonochromatic,
    ColorSchemeTriad,
    ColorSchemeComplementary
	
} ColorScheme;

@interface UIColor (Colours)

// Color Methods
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorWithRGBAArray:(NSArray *)rgbaArray;
- (NSString *)hexString;
- (NSArray *)rgbaArray;
- (NSArray *)hsbaArray;
- (NSDictionary *)rgbaDict;
- (NSDictionary *)hsbaDict;

// Generate Color Scheme
- (NSArray *)colorSchemeOfType:(ColorScheme)type;

// System Colors
+ (UIColor *)sSKCGetColor_infoBlueColor;
+ (UIColor *)sSKCGetColor_successColor;
+ (UIColor *)sSKCGetColor_warningColor;
+ (UIColor *)sSKCGetColor_dangerColor;

// Whites
+ (UIColor *)sSKCGetColor_antiqueWhiteColor;
+ (UIColor *)sSKCGetColor_oldLaceColor;
+ (UIColor *)sSKCGetColor_ivoryColor;
+ (UIColor *)sSKCGetColor_seashellColor;
+ (UIColor *)sSKCGetColor_ghostWhiteColor;
+ (UIColor *)sSKCGetColor_snowColor;
+ (UIColor *)sSKCGetColor_linenColor;

// Grays
+ (UIColor *)sSKCGetColor_black25PercentColor;
+ (UIColor *)sSKCGetColor_black50PercentColor;
+ (UIColor *)sSKCGetColor_black75PercentColor;
+ (UIColor *)sSKCGetColor_warmGrayColor;
+ (UIColor *)sSKCGetColor_coolGrayColor;
+ (UIColor *)sSKCGetColor_charcoalColor;
+ (UIColor *)sSKCGetColor_samKnowsGrayColor;
+ (UIColor *)sSKCGetColor_samKnowsLightGrayColor;
+ (UIColor *)sSKCGetColor_samKnowsVeryLightGrayColor;
+ (UIColor *)sSKCGetColor_samKnowsExtremelyLightGrayColor;

// Blues
+ (UIColor *)sSKCGetColor_tealColor;
+ (UIColor *)sSKCGetColor_steelBlueColor;
+ (UIColor *)sSKCGetColor_robinEggColor;
+ (UIColor *)sSKCGetColor_pastelBlueColor;
+ (UIColor *)sSKCGetColor_turquoiseColor;
+ (UIColor *)sSKCGetColor_skyeBlueColor;
+ (UIColor *)sSKCGetColor_indigoColor;
+ (UIColor *)sSKCGetColor_denimColor;
+ (UIColor *)sSKCGetColor_blueberryColor;
+ (UIColor *)sSKCGetColor_cornflowerColor;
+ (UIColor *)sSKCGetColor_babyBlueColor;
+ (UIColor *)sSKCGetColor_midnightBlueColor;
+ (UIColor *)sSKCGetColor_fadedBlueColor;
+ (UIColor *)sSKCGetColor_icebergColor;
+ (UIColor *)sSKCGetColor_waveColor;
+ (UIColor *)sSKCGetColor_samKnowsBlueColor;

// Greens
+ (UIColor *)sSKCGetColor_emeraldColor;
+ (UIColor *)sSKCGetColor_grassColor;
+ (UIColor *)sSKCGetColor_pastelGreenColor;
+ (UIColor *)sSKCGetColor_seafoamColor;
+ (UIColor *)sSKCGetColor_paleGreenColor;
+ (UIColor *)sSKCGetColor_cactusGreenColor;
+ (UIColor *)sSKCGetColor_chartreuseColor;
+ (UIColor *)sSKCGetColor_hollyGreenColor;
+ (UIColor *)sSKCGetColor_oliveColor;
+ (UIColor *)sSKCGetColor_oliveDrabColor;
+ (UIColor *)sSKCGetColor_moneyGreenColor;
+ (UIColor *)sSKCGetColor_honeydewColor;
+ (UIColor *)sSKCGetColor_limeColor;
+ (UIColor *)sSKCGetColor_cardTableColor;

// Reds
+ (UIColor *)sSKCGetColor_salmonColor;
+ (UIColor *)sSKCGetColor_brickRedColor;
+ (UIColor *)sSKCGetColor_easterPinkColor;
+ (UIColor *)sSKCGetColor_grapefruitColor;
+ (UIColor *)sSKCGetColor_pinkColor;
+ (UIColor *)sSKCGetColor_indianRedColor;
+ (UIColor *)sSKCGetColor_strawberryColor;
+ (UIColor *)sSKCGetColor_coralColor;
+ (UIColor *)sSKCGetColor_maroonColor;
+ (UIColor *)sSKCGetColor_watermelonColor;
+ (UIColor *)sSKCGetColor_tomatoColor;
+ (UIColor *)sSKCGetColor_pinkLipstickColor;
+ (UIColor *)sSKCGetColor_paleRoseColor;
+ (UIColor *)sSKCGetColor_crimsonColor;

// Purples
+ (UIColor *)sSKCGetColor_eggplantColor;
+ (UIColor *)sSKCGetColor_pastelPurpleColor;
+ (UIColor *)sSKCGetColor_palePurpleColor;
+ (UIColor *)sSKCGetColor_coolPurpleColor;
+ (UIColor *)sSKCGetColor_violetColor;
+ (UIColor *)sSKCGetColor_plumColor;
+ (UIColor *)sSKCGetColor_lavenderColor;
+ (UIColor *)sSKCGetColor_raspberryColor;
+ (UIColor *)sSKCGetColor_fuschiaColor;
+ (UIColor *)sSKCGetColor_grapeColor;
+ (UIColor *)sSKCGetColor_periwinkleColor;
+ (UIColor *)sSKCGetColor_orchidColor;

// Yellows
+ (UIColor *)sSKCGetColor_goldenrodColor;
+ (UIColor *)sSKCGetColor_yellowGreenColor;
+ (UIColor *)sSKCGetColor_bananaColor;
+ (UIColor *)sSKCGetColor_mustardColor;
+ (UIColor *)sSKCGetColor_buttermilkColor;
+ (UIColor *)sSKCGetColor_goldColor;
+ (UIColor *)sSKCGetColor_creamColor;
+ (UIColor *)sSKCGetColor_lightCreamColor;
+ (UIColor *)sSKCGetColor_wheatColor;
+ (UIColor *)sSKCGetColor_beigeColor;

// Oranges
+ (UIColor *)sSKCGetColor_peachColor;
+ (UIColor *)sSKCGetColor_burntOrangeColor;
+ (UIColor *)sSKCGetColor_pastelOrangeColor;
+ (UIColor *)sSKCGetColor_cantaloupeColor;
+ (UIColor *)sSKCGetColor_carrotColor;
+ (UIColor *)sSKCGetColor_mandarinColor;

// Browns
+ (UIColor *)sSKCGetColor_chiliPowderColor;
+ (UIColor *)sSKCGetColor_burntSiennaColor;
+ (UIColor *)sSKCGetColor_chocolateColor;
+ (UIColor *)sSKCGetColor_coffeeColor;
+ (UIColor *)sSKCGetColor_cinnamonColor;
+ (UIColor *)sSKCGetColor_almonColor;
+ (UIColor *)sSKCGetColor_eggshellColor;
+ (UIColor *)sSKCGetColor_sandColor;
+ (UIColor *)sSKCGetColor_mudColor;
+ (UIColor *)sSKCGetColor_siennaColor;
+ (UIColor *)sSKCGetColor_dustColor;

@end
