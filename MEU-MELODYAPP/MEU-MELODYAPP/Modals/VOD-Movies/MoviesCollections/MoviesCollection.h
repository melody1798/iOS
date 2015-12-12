//
//  MoviesCollection.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoviesCollection : NSObject

@property (strong, nonatomic) NSString*     collectionId;
@property (strong, nonatomic) NSString*     collectionName;
@property (strong, nonatomic) NSString*     collectionName_en;
@property (strong, nonatomic) NSString*     collectionName_ar;
@property (strong, nonatomic) NSString*     collectionThumb;

- (void)fillCollectionDetail:(id)info;

@end
