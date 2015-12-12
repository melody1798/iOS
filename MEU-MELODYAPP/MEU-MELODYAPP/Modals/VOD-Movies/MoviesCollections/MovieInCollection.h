//
//  MovieInCollection.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieInCollection : NSObject

@property (strong, nonatomic) NSString*     movieName_en;
@property (strong, nonatomic) NSString*     movieName_ar;
@property (strong, nonatomic) NSString*     thumbUrl;
@property (strong, nonatomic) NSString*     movieID;
@property (strong, nonatomic) NSString*     singerName_en;
@property (strong, nonatomic) NSString*     singerName_ar;
@property (strong, nonatomic) NSString*     movieUrl;
@property (assign, nonatomic) BOOL          isSeries;
@property (assign, nonatomic) NSInteger     movieType;

- (void)fillCollectionMovieInfo:(id)info;

@end
