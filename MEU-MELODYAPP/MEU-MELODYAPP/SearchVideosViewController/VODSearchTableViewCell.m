//
//  VODSearchTableViewCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/01/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "VODSearchTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CommonFunctions.h"

@implementation VODSearchTableViewCell

@synthesize delegate;
@synthesize btnTap;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.backgroundColor = [UIColor clearColor];
    lblMovieName.font = [UIFont fontWithName:kProximaNova_SemiBold size:15.0];
    lblDuration.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    lblDesc.font = [UIFont fontWithName:kProximaNova_Regular size:16.0];
}

- (void)setVODSearchValue:(SearchLiveNowVideo*)objSearchLiveNowVideo
{
    [imgVwVideo sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.videoThumb]];
    lblMovieName.text = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objSearchLiveNowVideo.videoName_en:objSearchLiveNowVideo.videoName_ar;
    
    if (objSearchLiveNowVideo.videoType == 0) {
        lblDuration.text = [NSString stringWithFormat:@"%@: %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"episodes" value:@"" table:nil], objSearchLiveNowVideo.videoDuration];
    }
    else if (objSearchLiveNowVideo.videoType == 1)
    {
        if ([objSearchLiveNowVideo.videoDuration length] > 0)
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
                
                NSString *strDuration = [NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objSearchLiveNowVideo.videoDuration];
                NSAttributedString *strAtt = [self changeMinTextFont:strDuration fontName:kProximaNova_Regular];
                lblDuration.attributedText = strAtt;
            }
            else
            {
                lblDuration.text = [NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objSearchLiveNowVideo.videoDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
            }
        }
    }
    else if (objSearchLiveNowVideo.videoType == 2)
        lblDuration.text = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objSearchLiveNowVideo.artistName_en:objSearchLiveNowVideo.artistName_ar;

    lblDesc.text = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objSearchLiveNowVideo.videoDescription_en:objSearchLiveNowVideo.videoDescription_ar;
}

- (IBAction)btnTap:(id)sender
{
    if ([delegate respondsToSelector:@selector(searchCellSelected:)]) {
        [delegate searchCellSelected:[sender tag]];
    }
}

- (NSMutableAttributedString*)changeMinTextFont:(NSString*)lblText fontName:(NSString*)textFontName
{
    //Format bullets
    NSMutableAttributedString *bulletStr = [[NSMutableAttributedString alloc] initWithString:@"د"];
    [bulletStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:textFontName size:28] range:NSMakeRange(0, [bulletStr length])];
    //NSString *patternBold1 = @"(Special Notes:)";
    NSString *patternBold1 = [NSString stringWithFormat:@"(د)"];
    
    NSRegularExpression *expressionBold1 = [NSRegularExpression regularExpressionWithPattern:patternBold1 options:0 error:nil];
    
    //  enumerate matches
    NSRange rangeBold1 = NSMakeRange(0,[lblText length]);
    NSMutableAttributedString *txtViewDesc = [[NSMutableAttributedString alloc] initWithString:lblText];
    
    NSString *str2 = lblText;
    
    [expressionBold1 enumerateMatchesInString:str2 options:0 range:rangeBold1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange bulletTextRange = [result rangeAtIndex:1];
        [txtViewDesc replaceCharactersInRange:bulletTextRange withAttributedString:bulletStr];
    }];
    
    return txtViewDesc;
}

@end