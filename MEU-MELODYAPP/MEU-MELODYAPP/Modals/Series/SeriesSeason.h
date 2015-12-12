//
//  SeriesSeason.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeriesSeason : NSObject

@property (strong, nonatomic) NSString*     seasonNum;

- (void)fillValues:(NSString*)seasonNum;

@end
