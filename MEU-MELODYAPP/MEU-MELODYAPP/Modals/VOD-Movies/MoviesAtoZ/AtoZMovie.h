//
//  AtoZMovie.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AtoZMovie : NSObject

@property (strong, nonatomic) NSString*     movieName_eniPhone;

@property (strong, nonatomic) NSString*     movieName_en;
@property (strong, nonatomic) NSString*     movieName_ar;
@property (strong, nonatomic) NSString*     movieUrl;
@property (strong, nonatomic) NSString*     movieThumbNail;
@property (strong, nonatomic) NSString*     movieId;
@property (strong, nonatomic) NSString*     movieGenre_en;
@property (strong, nonatomic) NSString*     movieGenre_ar;
@property (strong, nonatomic) NSString*     movieDuration;

- (void)fillAtoZMovieInfo:(id)info;

@end
