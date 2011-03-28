//
//  TokenStream.h
//  TinyJSON
//
//  Created by 西谷 明洋 on 11/03/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token : NSObject {
@private
    // kind of value
    // 's' : string
    // 'n' : number
    // 't' : boolean true
    // 'f' : boolean false
    // '0' : null
    // ':' ',' '{' '}' '[' ']' : symbols
    char kind;
    id value;
}
@property (nonatomic, readonly) char kind;
@property (nonatomic, readonly, retain) id value;
- (id)initWithKind:(char)k value:(id)v;
+ (id)tokenWithKind:(char)k value:(id)v;
@end

@interface TokenStream : NSObject {
@private
    NSString *inputString;
    NSRange searchRange;
    NSCharacterSet *notSpaceSet;
    NSCharacterSet *notNumberSet;
    NSCharacterSet *notStringSet;
    Token *pushBack;
}
@property (nonatomic, retain) Token *pushBack;
- (id)initWithString:(NSString*)input;
- (Token*)getToken;
@end
