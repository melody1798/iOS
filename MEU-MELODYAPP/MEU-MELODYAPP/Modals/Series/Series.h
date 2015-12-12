//
//  Series.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Series : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (retain, nonatomic) NSMutableArray*   arrSeries;

- (void)fetchAllSeries:(id)target selector:(SEL)selector isArb:(NSString*)isArb;

@end
