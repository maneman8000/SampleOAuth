//
//  JsonParser.m
//  TinyJSON
//
//  Created by 西谷 明洋 on 11/03/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JsonParser.h"
#import "TokenStream.h"

@interface JsonParser (Local)
- (NSMutableDictionary*)object;
- (NSMutableArray*)array;
@end

@implementation JsonParser

- (id)init {
    if ((self = [super init]) != nil) {        
    }
    return self;
}

- (void)dealloc {
    [tokenStream release];
    [super dealloc];
}

/* [Grammar]
 *
 * OBJECT -> "{" OBJECT-CONTENTS "}"
 *
 * OBJECT-CONTENTS -> STRING ":" VALUE "," OBJECT-CONTENTS
 * OBJECT-CONTENTS -> STRING ":" VALUE
 * OBJECT-CONTENTS -> ""
 *
 * ARRAY -> "[" ARRAY-CONTENTS "]"
 * ARRAY-CONTENTS -> VALUE "," ARRAY-CONTENTS
 * ARRAY-CONTENTS -> VALUE
 *
 * VALUE -> STRING
 * VALUE -> NUMBER
 * VALUE -> OBJECT
 * VALUE -> ARRAY
 * VALUE -> "true" | "false" | "null"
 * VALUE -> ""
 */

- (id)value {
    Token *t = [tokenStream getToken];
    switch (t.kind) {
        case 's': case 'n':
            return t.value;
        case 't':
            return [NSNumber numberWithBool:YES];
        case 'f':
            return [NSNumber numberWithBool:NO];
        case '0':
            return nil;
        case '{':
            [tokenStream setPushBack:t];
            return [self object];
        case '[':
            [tokenStream setPushBack:t];
            return [self array];
    }
    [tokenStream setPushBack:t];
    return nil;
}

- (void)arrayContents:(NSMutableArray*)result {
    id value = [self value];
    if (!value) return;
    [result addObject:value];

    Token *t = [tokenStream getToken];
    if (!t || t.kind != ',') {
        [tokenStream setPushBack:t];
        return;
    }
    
    return [self arrayContents:result];
}

- (NSMutableArray*)array {
    Token *t = [tokenStream getToken];
    if (!t || t.kind != '[') return nil;
    
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    [self arrayContents:result];
    
    t = [tokenStream getToken];
    if (!t || t.kind != ']') return nil;
    return result;
}

- (void)objectContents:(NSMutableDictionary*)result {

    Token *key = [tokenStream getToken];
    if (!key || key.kind != 's') {
        [tokenStream setPushBack:key];
        return;
    }

    Token *t = [tokenStream getToken];
    if (!t || t.kind != ':') return;

    id val = [self value];
    if (!val) return;
    [result setObject:val forKey:key.value];

    t = [tokenStream getToken];
    if (!t || t.kind != ',') {
        [tokenStream setPushBack:t];
        return;
    }

    return [self objectContents:result];
}

- (NSMutableDictionary*)object {
    Token *t = [tokenStream getToken];
    if (!t || t.kind != '{') return nil;

    NSMutableDictionary *result = [[[NSMutableDictionary alloc] init] autorelease];
    [self objectContents:result];

    t = [tokenStream getToken];
    if (!t || t.kind != '}') return nil;
    return result;
}

- (NSDictionary*)parseFromString:(NSString*)input {
    [tokenStream release];
    tokenStream = [[TokenStream alloc] initWithString:input];
    return [self object];
}

@end
