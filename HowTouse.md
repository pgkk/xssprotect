# XSS Protect Usage #

First:
  * Copy the xssProtect.jar to your lib directory where your app can find it.
  * Download and include the latest version of ANTLR runtime v3 (antlr-runtime-3.0.1.jar) from http://www.antlr.org/download.html.
  * Make sure to include the antlr runtime on the classpath when you run your application.

The following code shows an example usage of the library within your application:

```
public String protectAgainstXSS( String html ) {
    StringReader reader = new StringReader( html );
    StringWriter writer = new StringWriter();

    try {
        // Parse incoming string from the "html" variable
        HTMLParser.process( reader, writer, new XSSFilter(), true );

        // Return the parsed and cleaned up string
        return writer.toString();
    } catch (HandlingException e) {
        // Handle the error here in accordance with your coding policies...
    }
}
```