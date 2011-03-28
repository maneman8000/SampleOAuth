//
//  TokenStream.m
//  TinyJSON
//
//  Created by 西谷 明洋 on 11/03/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TokenStream.h"


@implementation Token
@synthesize kind, value;

- (id)initWithKind:(char)k value:(id)v {
    if ((self = [super init]) != nil) {
        kind = k;
        value = [v retain];
    }
    return self;
}

- (void)dealloc {
    [value release];
    [super dealloc];
}

+ (id)tokenWithKind:(char)k value:(id)v {
    return [[[Token alloc] initWithKind:k value:v] autorelease];
}

@end

@implementation TokenStream
@synthesize pushBack;

- (id)initWithString:(NSString*)input {
    if ((self = [super init]) != nil) {
        inputString = [input retain];
        searchRange.length = [input length];
        notSpaceSet = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] retain];
        notNumberSet = [[[NSCharacterSet characterSetWithCharactersInString:@".-0123456789"] invertedSet] retain];
        notStringSet = [[NSCharacterSet characterSetWithCharactersInString:@"\t\r\n\" .,-0123456789:{}[]"] retain];
    }
    return self;
}

- (void)dealloc {
    [inputString release];
    [notSpaceSet release];
    [notNumberSet release];
    [notStringSet release];
    [pushBack release];
    [super dealloc];
}

#define UPDATE_SEARCH_RANGE(SR, R) \
SR.length -= R.location + R.length - SR.location; \
SR.location = R.location + R.length;

- (Token*)getToken {
    if (pushBack) {
        Token *temp = [self.pushBack retain];
        [self setPushBack:nil];
        return [temp autorelease];
    }
    // skip whitespace
    NSRange r = [inputString rangeOfCharacterFromSet:notSpaceSet options:0 range:searchRange];
    if (r.location >= [inputString length]) return nil;
    UPDATE_SEARCH_RANGE(searchRange, r);
    //    NSLog(@"{%lu, %lu}", searchRange.location, searchRange.length);
    switch ([inputString characterAtIndex:r.location]) {
        // symbols
        case 0x002C:
            return [Token tokenWithKind:',' value:nil];
        case 0x003A:
            return [Token tokenWithKind:':' value:nil];
        case 0x005B:
            return [Token tokenWithKind:'[' value:nil];
        case 0x005D:
            return [Token tokenWithKind:']' value:nil];
        case 0x007B:
            return [Token tokenWithKind:'{' value:nil];
        case 0x007D:
            return [Token tokenWithKind:'}' value:nil];
        // number
        case 0x002D:
        case 0x0030: case 0x0031: case 0x0032: case 0x0033: case 0x0034:
        case 0x0035: case 0x0036: case 0x0037: case 0x0038: case 0x0039:
        {
            r = [inputString rangeOfCharacterFromSet:notNumberSet options:0 range:searchRange];
            if (r.location >= [inputString length]) r.location = [inputString length];
            NSRange rr = { searchRange.location - 1, r.location - searchRange.location + 1 };
            UPDATE_SEARCH_RANGE(searchRange, rr);
            return [Token tokenWithKind:'n'
                                  value:[NSNumber numberWithDouble:[[inputString substringWithRange:rr] doubleValue]]];
        }
        // string
        case 0x0022:
        {
            NSRange tempsr = { searchRange.location, searchRange.length };
            do {
                r = [inputString rangeOfString:@"\"" options:0 range:tempsr];
                UPDATE_SEARCH_RANGE(tempsr, r);
            } while (r.location < [inputString length] && [inputString characterAtIndex:r.location - 1] == 0x005C);
            if (r.location >= [inputString length]) {
                searchRange.location = [inputString length];
                searchRange.length = 0;
                return nil;
            }
            NSRange rr = { searchRange.location, r.location - searchRange.location };
            searchRange.location = r.location + 1;
            searchRange.length = [inputString length] - r.location - 1;
            return [Token tokenWithKind:'s' value:[[inputString substringWithRange:rr]
                                                   stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
        }
        // true, false, null
        case 0x0066: case 0x0074: case 0x006E:
        {
            r = [inputString rangeOfCharacterFromSet:notStringSet options:0 range:searchRange];
            if (r.location >= [inputString length]) r.location = [inputString length];
            NSRange rr = { searchRange.location - 1, r.location - searchRange.location + 1 };
            UPDATE_SEARCH_RANGE(searchRange, rr);
            NSString *result = [inputString substringWithRange:rr];
            if ([result isEqualToString:@"true"]) {
                return [Token tokenWithKind:'t' value:nil];
            }
            else if ([result isEqualToString:@"false"]) {
                return [Token tokenWithKind:'f' value:nil];
            }
            else if ([result isEqualToString:@"null"]) {
                return [Token tokenWithKind:'0' value:nil];
            }
            return nil;
        }
    }
    return nil;
}

@end
