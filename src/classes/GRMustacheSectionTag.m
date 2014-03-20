// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheSectionTag_private.h"
#import "GRMustacheRenderingASTVisitor_private.h"


@interface GRMustacheSectionTag()

/**
 * @see +[GRMustacheSectionTag sectionTagWithExpression:templateString:innerRange:inverted:inheritable:ASTNodes:]
 */
- (id)initWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange ASTNodes:(NSArray *)ASTNodes;
@end


@implementation GRMustacheSectionTag

+ (instancetype)sectionTagWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange ASTNodes:(NSArray *)ASTNodes
{
    return [[[self alloc] initWithType:type expression:expression contentType:contentType templateString:templateString innerRange:innerRange ASTNodes:ASTNodes] autorelease];
}

- (void)dealloc
{
    [_templateString release];
    [_ASTNodes release];
    [super dealloc];
}


#pragma mark - GRMustacheTag

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    GRMustacheRenderingASTVisitor *visitor = [[[GRMustacheRenderingASTVisitor alloc] initWithContentType:_contentType context:context] autorelease];

    for (id<GRMustacheASTNode> ASTNode in _ASTNodes) {
        // ASTNode may be overriden by a GRMustacheInheritablePartial: resolve it.
        ASTNode = [context resolveASTNode:ASTNode];
        
        // render
        if (![ASTNode accept:visitor error:error]) {
            return nil;
        }
    }
    
    return [visitor renderingWithHTMLSafe:HTMLSafe error:error];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}


#pragma mark - Private

- (id)initWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange ASTNodes:(NSArray *)ASTNodes
{
    self = [super initWithType:type expression:expression contentType:contentType];
    if (self) {
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _ASTNodes = [ASTNodes retain];
    }
    return self;
}

@end
