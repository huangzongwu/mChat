//
//  XMLRepresentation.h
//  mChat
//
//  Created by Martin Jahn on 27/07/2011.
//  Copyright 2011 Mums Soft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLRepresentation : NSObject{
@protected
	
	SEL perform;
}

+ (id) sharedThread:(id)thread;

- (id) initForAuth:(BOOL) isAuth;

- (id) copy;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

- (void) setPerform:(SEL) sel;
- (SEL) perform;
@end

//--------------------------------------------------------------------------------------------
@interface XMLRepresentationAuth : XMLRepresentation {
@private
    
}

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

@end
//
//
//
//
//
//--------------------------------------------------------------------------------------------
@interface XMLRepFeatures : XMLRepresentation{
@private
}

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;

@end

@interface XMLRepAuthFeatures : XMLRepresentationAuth {
@private
}
- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepTLS : XMLRepFeatures {
@private
	BOOL required;
}

- (id) copy;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepCompress : XMLRepFeatures {
@private
}

- (id) copy;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepSASL : XMLRepAuthFeatures {
@private
    NSInteger mask;
}

- (id) copy;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

- (NSInteger) mask;
@end

enum saslMethods {
	CRAM_MD5 = 1,
	ANONYMOUS = 2,
	PLAIN = 4,
	DIGEST_MD5 = 8,
	KERBEROS_V4 = 0x10,
	X_FACEBOOK = 0x20,
	SCRAM_SHA_1 = 0x40,
	SCRAM_SHA_1_PLUS = 0x80
};


//--------------------------------------------------------------------------------------------
@interface XMLRepRegister : XMLRepAuthFeatures {
@private
}

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepChall : XMLRepFeatures {
@private
	NSString *base;
}

- (NSString *) base;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepSuccess : XMLRepFeatures {
@private
}

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepBind : XMLRepresentation {
@private
}

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
@end
//
//
//
//
//
//--------------------------------------------------------------------------------------------
@interface XMLRepIQ : XMLRepresentation{
@private
}

- (id) initwithAttributes:(NSDictionary *)attrs;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

@end

//--------------------------------------------------------------------------------------------
@interface XMLRepRoster : XMLRepIQ {
@private

	NSMutableArray * roster;
}

- (id) copy;

- (id) initwithAttributes:(NSDictionary *)attrs;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;

@end
//
//
//
//
//
//--------------------------------------------------------------------------------------------
@interface XMLRepChat : XMLRepresentation{
@private
}

- (id) initwithAttributes:(NSDictionary *)attrs;

- (void) processBeginItemName:(NSString *)name URI:(NSString *)uri namespaces:(NSArray *)NS 
				   attributes:(NSDictionary *)attrs stateMachine:(NSMutableArray *)statM;
- (void) processEndItemName:(NSString *)name URI:(NSString *)uri stateMachine:(NSMutableArray *)statM;
- (void) processText:(NSString *)text stateMachine:(NSMutableArray *)statM;

@end
//
//
//
//
//
//--------------------------------------------------------------------------------------------
