//
//  Serie.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Serie : NSObject

@property (strong, nonatomic) NSString*         serieThumb;
@property (strong, nonatomic) NSString*         serieName_en;
@property (strong, nonatomic) NSString*         serieName_ar;
@property (strong, nonatomic) NSString*         serieId;

- (void)fillDict:(id)info;

@end
