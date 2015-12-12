//
//  SeriesSeason.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesSeason.h"

@implementation SeriesSeason

@synthesize seasonNum;

- (void)fillValues:(NSString*)seasonNumber
{
    self.seasonNum = [NSString stringWithFormat:@"%@", seasonNumber];
}

@end
