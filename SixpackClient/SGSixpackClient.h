//
//  SGSixpackClient.h
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGSixpackClient : NSObject

- (void)connectToHost:(NSString *)url
               timout:(NSTimeInterval)seconds;
- (void)setupExperiment:(NSString *)experiment alternatives:(NSArray *)alternatives;
- (void)participateIn:(NSString *)experiment onChoose:(void(^)(NSString *chosenAlternative))block;
- (void)convert:(NSString *)experiment;

@end
