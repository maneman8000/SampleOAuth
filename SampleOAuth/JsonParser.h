//
//  JsonParser.h
//  TinyJSON
//
//  Created by 西谷 明洋 on 11/03/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TokenStream;

@interface JsonParser : NSObject {
    TokenStream *tokenStream;
}

- (id)init;
- (NSMutableDictionary*)parseFromString:(NSString*)input;

@end
