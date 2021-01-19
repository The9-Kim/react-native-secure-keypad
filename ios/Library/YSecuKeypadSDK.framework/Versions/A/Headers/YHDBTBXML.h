// ================================================================================================
//  TBXML.h
//  Fast processing of XML files
//
// ================================================================================================
//  Created by Tom Bradley on 21/10/2009.
//  Version 1.5
//  
//  Copyright 2012 71Squared All rights reserved.b
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// ================================================================================================

@class YHDBTBXML;


// ================================================================================================
//  Error Codes
// ================================================================================================
enum YHDBTBXMLErrorCodes {
    D_YHDBTBXML_SUCCESS = 0,

    D_YHDBTBXML_DATA_NIL,
    D_YHDBTBXML_DECODE_FAILURE,
    D_YHDBTBXML_MEMORY_ALLOC_FAILURE,
    D_YHDBTBXML_FILE_NOT_FOUND_IN_BUNDLE,
    
    D_YHDBTBXML_ELEMENT_IS_NIL,
    D_YHDBTBXML_ELEMENT_NAME_IS_NIL,
    D_YHDBTBXML_ELEMENT_NOT_FOUND,
    D_YHDBTBXML_ELEMENT_TEXT_IS_NIL,
    D_YHDBTBXML_ATTRIBUTE_IS_NIL,
    D_YHDBTBXML_ATTRIBUTE_NAME_IS_NIL,
    D_YHDBTBXML_ATTRIBUTE_NOT_FOUND,
    D_YHDBTBXML_PARAM_NAME_IS_NIL
};


// ================================================================================================
//  Defines
// ================================================================================================
#define D_YHDBTBXML_DOMAIN @"com.71squared.tbxml"

#define MAX_ELEMENTS 100
#define MAX_ATTRIBUTES 100

#define YHDBTBXML_ATTRIBUTE_NAME_START 0
#define YHDBTBXML_ATTRIBUTE_NAME_END 1
#define YHDBTBXML_ATTRIBUTE_VALUE_START 2
#define YHDBTBXML_ATTRIBUTE_VALUE_END 3
#define YHDBTBXML_ATTRIBUTE_CDATA_END 4

// ================================================================================================
//  Structures
// ================================================================================================

/** The YHDBTBXMLAttribute structure holds information about a single XML attribute. The structure holds the attribute name, value and next sibling attribute. This structure allows us to create a linked list of attributes belonging to a specific element.
 */
typedef struct _YHDBTBXMLAttribute {
	char * name;
	char * value;
	struct _YHDBTBXMLAttribute * next;
} YHDBTBXMLAttribute;



/** The YHDBTBXMLElement structure holds information about a single XML element. The structure holds the element name & text along with pointers to the first attribute, parent element, first child element and first sibling element. Using this structure, we can create a linked list of YHDBTBXMLElements to map out an entire XML file.
 */
typedef struct _YHDBTBXMLElement {
	char * name;
	char * text;
	
	YHDBTBXMLAttribute * firstAttribute;
	
	struct _YHDBTBXMLElement * parentElement;
	
	struct _YHDBTBXMLElement * firstChild;
	struct _YHDBTBXMLElement * currentChild;
	
	struct _YHDBTBXMLElement * nextSibling;
	struct _YHDBTBXMLElement * previousSibling;
	
} YHDBTBXMLElement;

/** The YHDBTBXMLElementBuffer is a structure that holds a buffer of YHDBTBXMLElements. When the buffer of elements is used, an additional buffer is created and linked to the previous one. This allows for efficient memory allocation/deallocation elements.
 */
typedef struct _YHDBTBXMLElementBuffer {
	YHDBTBXMLElement * elements;
	struct _YHDBTBXMLElementBuffer * next;
	struct _YHDBTBXMLElementBuffer * previous;
} YHDBTBXMLElementBuffer;



/** The YHDBTBXMLAttributeBuffer is a structure that holds a buffer of YHDBTBXMLAttributes. When the buffer of attributes is used, an additional buffer is created and linked to the previous one. This allows for efficient memeory allocation/deallocation of attributes.
 */
typedef struct _YHDBTBXMLAttributeBuffer {
	YHDBTBXMLAttribute * attributes;
	struct _YHDBTBXMLAttributeBuffer * next;
	struct _YHDBTBXMLAttributeBuffer * previous;
} YHDBTBXMLAttributeBuffer;


// ================================================================================================
//  Block Callbacks
// ================================================================================================
typedef void (^YHDBTBXMLSuccessBlock)(YHDBTBXML *tbxml);
typedef void (^YHDBTBXMLFailureBlock)(YHDBTBXML *tbxml, NSError *error);
typedef void (^YHDBTBXMLIterateBlock)(YHDBTBXMLElement *element);
typedef void (^YHDBTBXMLIterateAttributeBlock)(YHDBTBXMLAttribute *attribute, NSString *attributeName, NSString *attributeValue);


// ================================================================================================
//  YHDBTBXML Public Interface
// ================================================================================================

@interface YHDBTBXML : NSObject {
	
@private
	YHDBTBXMLElement * rootXMLElement;
	
	YHDBTBXMLElementBuffer * currentElementBuffer;
	YHDBTBXMLAttributeBuffer * currentAttributeBuffer;
	
	long currentElement;
	long currentAttribute;
	
	char * bytes;
	long bytesLength;
}


@property (nonatomic, readonly) YHDBTBXMLElement * rootXMLElement;

+ (id)newYHDBTBXMLWithXMLString:(NSString*)aXMLString error:(NSError **)error;
+ (id)newYHDBTBXMLWithXMLData:(NSData*)aData error:(NSError **)error;
+ (id)newYHDBTBXMLWithXMLFile:(NSString*)aXMLFile error:(NSError **)error;
+ (id)newYHDBTBXMLWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension error:(NSError **)error;

+ (id)newYHDBTBXMLWithXMLString:(NSString*)aXMLString __attribute__((deprecated));
+ (id)newYHDBTBXMLWithXMLData:(NSData*)aData __attribute__((deprecated));
+ (id)newYHDBTBXMLWithXMLFile:(NSString*)aXMLFile __attribute__((deprecated));
+ (id)newYHDBTBXMLWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension __attribute__((deprecated));


- (id)initWithXMLString:(NSString*)aXMLString error:(NSError **)error;
- (id)initWithXMLData:(NSData*)aData error:(NSError **)error;
- (id)initWithXMLFile:(NSString*)aXMLFile error:(NSError **)error;
- (id)initWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension error:(NSError **)error;

- (id)initWithXMLString:(NSString*)aXMLString __attribute__((deprecated));
- (id)initWithXMLData:(NSData*)aData __attribute__((deprecated));
- (id)initWithXMLFile:(NSString*)aXMLFile __attribute__((deprecated));
- (id)initWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension __attribute__((deprecated));


- (int) decodeData:(NSData*)data;
- (int) decodeData:(NSData*)data withError:(NSError **)error;

@end

// ================================================================================================
//  YHDBTBXML Static Functions Interface
// ================================================================================================

@interface YHDBTBXML (StaticFunctions)

+ (NSString*) elementName:(YHDBTBXMLElement*)aXMLElement;
+ (NSString*) elementName:(YHDBTBXMLElement*)aXMLElement error:(NSError **)error;
+ (NSString*) textForElement:(YHDBTBXMLElement*)aXMLElement;
+ (NSString*) textForElement:(YHDBTBXMLElement*)aXMLElement error:(NSError **)error;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(YHDBTBXMLElement*)aXMLElement;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(YHDBTBXMLElement*)aXMLElement error:(NSError **)error;

+ (NSString*) attributeName:(YHDBTBXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeName:(YHDBTBXMLAttribute*)aXMLAttribute error:(NSError **)error;
+ (NSString*) attributeValue:(YHDBTBXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeValue:(YHDBTBXMLAttribute*)aXMLAttribute error:(NSError **)error;

+ (YHDBTBXMLElement*) nextSiblingNamed:(NSString*)aName searchFromElement:(YHDBTBXMLElement*)aXMLElement;
+ (YHDBTBXMLElement*) childElementNamed:(NSString*)aName parentElement:(YHDBTBXMLElement*)aParentXMLElement;

+ (YHDBTBXMLElement*) nextSiblingNamed:(NSString*)aName searchFromElement:(YHDBTBXMLElement*)aXMLElement error:(NSError **)error;
+ (YHDBTBXMLElement*) childElementNamed:(NSString*)aName parentElement:(YHDBTBXMLElement*)aParentXMLElement error:(NSError **)error;

/** Iterate through all elements found using query.
 
 Inspiration taken from John Blanco's RaptureXML https://github.com/ZaBlanc/RaptureXML
 */
+ (void)iterateElementsForQuery:(NSString *)query fromElement:(YHDBTBXMLElement *)anElement withBlock:(YHDBTBXMLIterateBlock)iterateBlock;
+ (void)iterateAttributesOfElement:(YHDBTBXMLElement *)anElement withBlock:(YHDBTBXMLIterateAttributeBlock)iterateBlock;


@end
