//
//  Genre.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Genre : NSObject
{
}

@property (strong, nonatomic) NSString*       genreId;
@property (strong, nonatomic) NSString*       genreName_en;
@property (strong, nonatomic) NSString*       genreName_ar;

-(void)fillGenreInfo:(id)info;

@end
