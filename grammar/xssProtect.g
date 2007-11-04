header {
    package com.blogspot.radialmind.xss;
}

class HTMLParser extends Parser;

options {
	exportVocab=HTML;
	k = 1;
	buildAST = true;
}

document
	: 	(body)?
	;

body: 	( body_content )+ 
	;

body_content_no_PCDATA
	:	body_tag | text_tag
	;

body_tag
	: 	heading | block | ADDRESS
	;

body_content
	: 	body_tag | text
	;


/*revised*/
heading
	:	h1 | h2 | h3 | h4 | h5 | h6
	;

block
	:	paragraph | list | preformatted | div |
		center | blockquote | HR | table | span
	;	//bug - ?FORM v %form, ISINDEX here too?

font:	teletype | italic | bold | underline | strike | 
		big | small | subscript | superscript
	;

phrase
	:	emphasize | strong | definition | code | sample_output|
		keyboard_text | variable | citation
	;
	
special
	:	anchor | IMG | font_dfn | BR 
	;

text_tag
	:	font | phrase | special
	;

text:	PCDATA | text_tag
	;

/*end*/


/*BLOCK ELEMENTS*/

h1	:	OH1 (block | text)* CH1
	;
h2	:	OH2 (block | text)* CH2
	;
h3	:	OH3 (block | text)* CH3
	;
h4	:	OH4 (block | text)* CH4
	;
h5	:	OH5 (block | text)* CH5
	;
h6	:	OH6 (block | text)* CH6
	;

address
	:	OADDRESS (PCDATA)* CADDRESS
	;

//NOTE:  according to the standard, paragraphs can't contain block elements
//like HR.  Netscape may insert these elements into paragraphs.
//We adhere strictly here.

paragraph
	:	OPARA
		(
			/*	Rule body_content may also be just plain text because HTML is
				so loose.  When body puts body_content in a loop, ANTLR
				doesn't know whether you want it to match all the text as part
				of this paragraph (in the case where the </p> is missing) or
				if the body rule should scarf it.  This is analogous to the
				dangling-else clause.  I shut off the warning.
			*/
			options {
				generateAmbigWarnings=false;
			}
		:	text
		)*
		(CPARA)?	
	;

list:	unordered_list
	|	ordered_list
	|	def_list
	;

unordered_list
	:	OULIST (PCDATA)* (list_item)+ CULIST
	;

ordered_list
	:	OOLIST (PCDATA)* (list_item)+ COLIST
	;

def_list
	:	ODLIST (PCDATA)* (def_list_item)+ CDLIST 
	;

list_item
	:	OLITEM ( text | list )+ (CLITEM (PCDATA)*)?
	;
	
def_list_item
	:	dt | dd
	;

dt	:	ODTERM (text)+ CDTERM (PCDATA)*
	;

// was dd : ODDEF (text | block)+ CDTERM (PCDATA)*;
dd	:	ODDEF (text | block)+ CDDEF (PCDATA)*
	;

dir	:	ODIR (list_item)+ CDIR
	;

menu:	OMENU (list_item)+ CMENU
	;

preformatted
	:	OPRE (text)+ CPRE
	;

div	:	ODIV (body_content)* CDIV		//semi-revised
	;

span
	:	OSPAN (body_content)* CSPAN		//semi-revised
	;
	
center
	:	OCENTER (body_content)* CCENTER //semi-revised
	;

blockquote
	:	OBQUOTE PCDATA CBQUOTE
	;

table
	:	OTABLE (caption)? (PCDATA)* (tr)+ CTABLE
	;

caption
	:	OCAP (text)* CCAP	
	;

tr	:	O_TR (PCDATA)* (th_or_td)* (C_TR (PCDATA)*)? 
	;

th_or_td
	:	O_TH_OR_TD (body_content)* (C_TH_OR_TD (PCDATA)*)?
	;

/*TEXT ELEMENTS*/

/*font style*/

teletype
	:	OTTYPE ( text )+ CTTYPE
	;

italic
	:	OITALIC ( text )+ CITALIC
	;

bold:	OBOLD ( text )+ CBOLD
	;

underline
	:	OUNDER ( text )+ CUNDER
	;

strike
	:	OSTRIKE ( text )+ CSTRIKE
	;

big	:	OBIG ( text )+ CBIG
	;

small
	:	OSMALL ( text )+ CSMALL
	;

subscript
	:	OSUB ( text )+ CSUB
	;

superscript
	:	OSUP ( text )+ CSUP
	;

	/*phrase elements*/

emphasize
	:	OEM ( text )+ CEM
	;

strong
	:	OSTRONG ( text )+ CSTRONG
	;

definition
	:	ODEF ( text )+ CDEF
	;

code
	:	OCODE ( text )+ CCODE
	;

sample_output
	:	OSAMP ( text )+ CSAMP
	;

keyboard_text
	:	OKBD ( text )+ CKBD
	;

variable
	:	OVAR ( text )+ CVAR
	;

citation
	:	OCITE ( text )+ CCITE
	;

/*	special text level elements*/
anchor
	:	OANCHOR (text)* CANCHOR
	;

//not w3-no blocks allowed; www.microsoft.com uses
font_dfn
	:	OFONT (text)* CFONT	
	;

class HTMLLexer extends Lexer;

options {	
	k = 4;
	exportVocab=HTML;
	charVocabulary = '\3'..'\377';
	caseSensitive=false;
	filter=UNDEFINED_TOKEN;
}


/*	STRUCTURAL tags
*/


/* headings */

OH1	:	"<h1" (WS ATTR)? '>' 
	;

CH1	:	"</h1>" 
	;

OH2	:	"<h2" (WS ATTR)?'>' 
	;

CH2	:	"</h2>" 
	;

OH3	:	"<h3" (WS ATTR)? '>' 
	;

CH3	:	"</h3>" 
	;

OH4	:	"<h4" (WS ATTR)? '>' 
	;

CH4	:	"</h4>" 
	;

OH5	:	"<h5" (WS ATTR)? '>' 
	;

CH5	:	"</h5>" 
	;

OH6	:	"<h6" (WS ATTR)? '>' 
	;

CH6	:	"</h6>" 
	;

OADDRESS
	:	"<address>" 
	;

CADDRESS
	:	"</address>"
	;

OPARA
	:	"<p" (WS ATTR)? '>' 
	;

CPARA
	: 	"</p>"		//it's optional
	;

		/*UNORDERED LIST*/
OULIST
	:	"<ul" (WS ATTR)? '>' 
	;

CULIST
	:	"</ul>"
	;

		/*ORDERED LIST*/
OOLIST
	:	"<ol" (WS ATTR)? '>'
	;

COLIST
	:	"</ol>"
	;

		/*LIST ITEM*/

OLITEM
	:	"<li" (WS ATTR)? '>'
	;

CLITEM
	:	"</li>"
	;

		/*DEFINITION LIST*/ 

ODLIST 
	:	"<dl" (WS ATTR)? '>' 
	;

CDLIST
	:	"</dl>"
	;

ODTERM
	: 	"<dt>"
	;

CDTERM
	: 	"</dt>"
	;

ODDEF
	: 	"<dd>"
	;

CDDEF
	: 	"</dd>"
	;

ODIR:	"<dir>"
	;

CDIR_OR_CDIV
	:	"</di"
		(	'r' {$setType(CDIR);}
		|	'v' {$setType(CDIV);}
		)
		'>'
	;

ODIV:	"<div" (WS ATTR)? '>'
	;

OSPAN:	"<span" (WS ATTR)? '>'
	;

CSPAN:	"</span>"
	;
	
OPRE:	("<pre>" | "<xmp>") ('\n')? 
	;

CPRE:	 "</pre>" | "</xmp>" 
	;

OCENTER
	:	"<center>"
	;

CCENTER
	:	"</center>"
	;

OBQUOTE
	:	"<blockquote>"
	;

CBQUOTE
	:	"</blockquote>"
	;

//this is block element and thus can't be nested inside of
//other block elements, ex: paragraphs.
//Netscape appears to generate bad HTML vis-a-vis the standard.

HR	:	"<hr" (WS (ATTR)*)? '>'
	;


OTABLE	
	:	"<table" (WS (ATTR)*)? '>'
	;

CTABLE
	: 	"</table>"
	;

OCAP:	"<caption" (WS (ATTR)*)? '>'
	;

CCAP:	"</caption>"
	;

O_TR
	:	"<tr" (WS (ATTR)*)? '>'
	;

C_TR:	"</tr>"
	;

O_TH_OR_TD
	:	("<th" | "<td") (WS (ATTR)*)? '>'
	;

C_TH_OR_TD
	:	"</th>" | "</td>"
	;

/*	PCDATA-LEVEL ELEMENTS
*/

/*		font style elemens*/
	
OTTYPE
	:	"<tt>"
	;

CTTYPE
	:	"</tt>"
	;

OITALIC
	:	"<i>"
	;

CITALIC
	:	"</i>"
	;

OBOLD
 	:	"<b>" 
	;

CBOLD
	:	"</b>" 
	;

OUNDER
	:	"<u>"
	;

CUNDER
	:	"</u>" 
	;

/** Left-factor <strike> and <strong> to reduce lookahead */
OSTRIKE_OR_OSTRONG
	:	"<str"
		(	"ike" {$setType(OSTRIKE);}
		|	"ong" {$setType(OSTRONG);}
		)
		'>'
	;

CST_LEFT_FACTORED
	:	"</st"
		(	"rike" {$setType(CSTRIKE);}
		|	"rong" {$setType(CSTRONG);}
		)
		'>'
	;

OSTYLE
 // was	: 	"<style>" 
  : "<style" (WS (ATTR)*)? '>'
	;

OBIG:	"<big>"
	;

CBIG:	"</big>"
	;

OSMALL
	:	"<small>"
	;

CSMALL
	:	"</small>"
	;

OSUB:	"<sub>"
	;

OSUP:	"<sup>"
	;

CSUB_OR_CSUP
	:	"</su"
		(	'b' {$setType(CSUB);}
		|	'p' {$setType(CSUP);}
		)
		'>'
	;

/*		phrase elements*/
OEM	:	"<em>"
	;

CEM	:	"</em>"
	;

ODFN:	"<dfn>"
	;

CDFN:	"</dfn>"
	;

OCODE
 	:	"<code>" 
	;

CCODE
	:	"</code>"
	;

OSAMP
	:	"<samp>"
	;

CSAMP
	:	"</samp>"
	;

OKBD:	"<kbd>"
	;

CKBD:	"</kbd>"
	;

OVAR:	"<var>"
	;

CVAR:	"</var>"
	;

OCITE
	:	"<cite>"
	;

CCITE
	:	"</cite>"
	;

/* special text level elements*/

OANCHOR
	:	"<a" WS (ATTR)+ '>'
	;

CANCHOR
	:	"</a>"
	;	

IMG	:	"<img" WS (ATTR)+ '>'
	;

OFONT	
	:	"<font" WS (ATTR)+ '>'
	;

CFONT
	:	"</font>"
	;

BR
	:	"<br" (WS ATTR)? '>'
	;
	
/*MISC STUFF*/

PCDATA
	:	(
			/* See comment in WS.  Language for combining any flavor
			 * newline is ambiguous.  Shutting off the warning.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:	'\r' '\n'		{newline();}
		|	'\r'			{newline();}
		|	'\n'			{newline();}
		|	~('<'|'\n'|'\r'|'"'|'>')
		)+ 
	;

// multiple-line comments
protected
COMMENT_DATA
	:	(	/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:
			{LA(2)!='-' && LA(3)!='>'}? '-' // allow '-' if not "-->"
		|	'\r' '\n'		{newline();}
		|	'\r'			{newline();}
		|	'\n'			{newline();}
		|	~('-'|'\n'|'\r')
		)*
	;


COMMENT
	:	"<!--" COMMENT_DATA "-->"	{ $setType(Token.SKIP); }
	;

/*
	PROTECTED LEXER RULES
*/

protected
WS	:	(
			/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:	' '
		|	'\t'
		|	'\n'	{ newline(); }
		|	"\r\n"	{ newline(); }
		|	'\r'	{ newline(); }
		)+
	;

protected
ATTR
/*options {
    ignore=WS;
}*/
	:	(WS)* VALIDATTR (WS)* ( '=' (WS)* (WORD ('%')? | ('-')? INT | STRING | HEXNUM))?
	;

//don't need uppercase for case-insen.
//the '.' is for words like "image.gif"
protected
WORD:	(	LCLETTER
   | '.' | '/'
  // was |	'.'
		)

		(
			/*	In reality, a WORD must be followed by whitespace, '=', or
				what can follow an ATTR such as '>'.  In writing this grammar,
				however, we just list all the possibilities as optional
				elements.  This is loose, allowing the case where nothing is
				matched after a WORD and then the (ATTR)* loop means the
				grammar would allow "widthheight" as WORD WORD or WORD, hence,
				an ambiguity.  Naturally, ANTLR will consume the input as soon
				as possible, combing "widthheight" into one WORD.

				I am shutting off the ambiguity here because ANTLR does the
				right thing.  The exit path is ambiguous with ever
				alternative.  The only solution would be to write an unnatural
				grammar (lots of extra productions) that laid out the
				possibilities explicitly, preventing the bogus WORD followed
				immediately by WORD without whitespace etc...
			 */
			options {
				generateAmbigWarnings=false;
			}
		:	LCLETTER
		|	DIGIT
		|	'.'
		)+
	;

protected
VALIDATTR
options {
    ignore=WS;
}
	:	("src"|"href"|"style")
	;

protected
STRING
options { 
	ignore=INVALIDLINK;
}
	:	'"' (~'"')* '"'
	|	'\'' (~'\'')* '\''
	;

protected
INVALIDLINK
options { 
	ignore=WS;
}
	:	"javascript:" 
	|	"eval"
	|	"vbscript:"
	|	"mocha:"
	|	"livescript:"
	;

protected
WSCHARS
	:	' ' | '\t' | '\n' | '\r'
	;

protected 
SPECIAL
	:	'<' | '~'
	;
	
protected
HEXNUM
	:	'#' HEXINT
	;

protected
INT	:	(DIGIT)+
	;

protected
HEXINT
	:	(
			/*	Technically, HEXINT cannot be followed by a..f, but due to our
				loose grammar, the whitespace that normally would follow this
				rule is optional.  ANTLR reports that #4FACE could parse as
				HEXINT "#4" followed by WORD "FACE", which is clearly bogus.
				ANTLR does the right thing by consuming a much input as
				possible here.  I shut the warning off.
			 */
			 options {
				generateAmbigWarnings=false;
			}
		:	HEXDIGIT
		)+
	;

protected
DIGIT
	:	'0'..'9'
	;

protected
HEXDIGIT
	:	'0'..'9'
	|	'a'..'f'
	;

protected
LCLETTER
	:	'a'..'z'
	;	

protected
UNDEFINED_TOKEN
	:	(('<' )
		(~'>' )*
		('>' ))
		{ _ttype = Token.SKIP; }
	| 	( "\r\n" | '\r' | '\n' {newline();} ) 
	;

/*
	:	'<' (~'>')* '>'
		(
			(	 options {
					generateAmbigWarnings=false;
				}
			:	"\r\n" | '\r' | '\n'
			)
			{ newline();}
		)*
		{System.err.println("invalid tag: "+$getText);}
	|	( "\r\n" | '\r' | '\n' ) {newline();}
	|	.
	;
*/