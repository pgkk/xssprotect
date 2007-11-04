package com.blogspot.radialmind.xss;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;

import antlr.ASTFactory;
import antlr.CommonAST;
import antlr.RecognitionException;
import antlr.TokenBuffer;
import antlr.TokenStreamException;
import antlr.collections.AST;

public class XSSProtect {
	public static String xssProtect( String text ) 
		throws XSSException
	{
		if ( text == null ) {
			return null;
		}
		ByteArrayInputStream bis = new ByteArrayInputStream( text.getBytes() );
		HTMLLexer lexer = new HTMLLexer(new DataInputStream(bis));
		TokenBuffer buffer = new TokenBuffer(lexer);
		HTMLParser parser = new HTMLParser(buffer);
	    ASTFactory factory = new ASTFactory();
	    factory.setASTNodeClass(CommonAST.class);
	    parser.setASTFactory(factory);
		try {
			parser.document();
		} catch (RecognitionException e) {
			e.printStackTrace();
		} catch (TokenStreamException e) {
			e.printStackTrace();
		}
		AST ast = parser.getAST();
		StringBuilder builder = new StringBuilder();
		recreateDocument( ast, builder );
		return builder.toString();
	}
	
	private static void recreateDocument( AST ast, StringBuilder builder ) {
		if ( ast == null ) {
			return;
		}
		builder.append( ast.getText() );
		recreateDocument( ast.getFirstChild(), builder ); 
		recreateDocument( ast.getNextSibling(), builder );
	}
}
