/*----------------------------------------------------------------------------------------------- */
/*                                                                                                */
/* This class contains test methods for SFDCEncoder class.                                        */
/*                                                                                                */
/* METHODS AND CLASSES:                                                                           */
/* EncodeTest:                          helps to work with different types of codes.              */
/* testEncoderHtmlEncode:               runs tests for SFDCEncoder.                               */
/* testEncoderJsEncode:                 runs tests for SFDCEncoder.                               */
/* testEncoderJsInHtmlEncode:           runs tests for SFDCEncoder.                               */
/* testEncoderUrlEncode:                runs tests for SFDCEncoder.                               */
/* testEncoderUrlEncodeWithEncoding:    runs tests for SFDCEncoder.                               */
/*                                                                                                */
/*------------------------------------------------------------------------------------------------*/

@isTest
private class testEncoder {

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* CLASS: EncodeTest                                                                          */
    /*                                                                                            */
    /* This class helps to work with different types of codes.                                    */
    /*                                                                                            */
    /* ELEMENTS:                                                                                  */
    /* encoding:                encoding                                                          */
    /* errText:                 error text                                                        */
    /* expectedOutput:          expected output                                                   */
    /* expectedResult:          expected result                                                   */
    /* inputStr:                information for coding                                            */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    private class EncodeTest {
        public String       encoding;
        public String       errText;
        public String       expectedOutput;
        public Boolean      expectedResult;
        public String       inputStr;

        public EncodeTest(String inputStr, String expectedOutput, String errText,
                          Boolean expectedResult) {
            this.errText = errText;
            this.expectedOutput = expectedOutput;
            this.expectedResult = expectedResult;
            this.inputStr = inputStr;
        }

        public EncodeTest(String inputStr, String encoding, String expectedOutput, String errText,
                          Boolean expectedResult) {
            this.encoding = encoding;
            this.errText = errText;
            this.expectedOutput = expectedOutput;
            this.expectedResult = expectedResult;
            this.inputStr = inputStr;
        }
    }

    private static final EncodeTest [] htmlEncodeTests = new EncodeTest[] {};
    private static final EncodeTest [] jsEncodeTests = new EncodeTest[] {};
    private static final EncodeTest [] jsInHtmlEncodeTests = new EncodeTest[] {};
    private static final EncodeTest [] urlEncodeTests = new EncodeTest[] {};
    private static final EncodeTest [] urlEncodeWithEncodingTests = new EncodeTest[] {};

    static {
        htmlEncodeTests.add(new EncodeTest('abc', 'abc', 'Valid #1', true));
        htmlEncodeTests.add(new EncodeTest(
                'abc<b>test</b>def', 
                'abc&lt;b&gt;test&lt;/b&gt;def', 
                'Valid #2',
                true
            )
        );
        htmlEncodeTests.add(new EncodeTest('abc&lt;def', 'abc&amp;lt;def', 'Valid #3', true));
        htmlEncodeTests.add(new EncodeTest(
                'abc<fghgfh&lt;<sfdg>&amp;def',
                'abc&lt;fghgfh&amp;lt;&lt;sfdg&gt;&amp;amp;def', 
                'Valid #4', 
                true
            )
        );
        htmlEncodeTests.add(new EncodeTest('abc\'def', 'abc&#39;def', 'Valid #5', true));
        htmlEncodeTests.add(new EncodeTest('abc"def', 'abc&quot;def', 'Valid #6', true));

        jsEncodeTests.add(new EncodeTest('abc', 'abc', 'Valid #1', true));
        jsEncodeTests.add(new EncodeTest(
                'abc<b>test</b>def', 
                'abc\\u003Cb\\u003Etest\\u003C\\/b\\u003Edef',
                'Valid #2', 
                true
            )
        );
        jsEncodeTests.add(new EncodeTest('abc&lt;def', 'abc&lt;def', 'Valid #3', true));
        jsEncodeTests.add(new EncodeTest(
                'abc<fghgfh&lt;<sfdg>&amp;def',
                'abc\\u003Cfghgfh&lt;\\u003Csfdg\\u003E&amp;def', 
                'Valid #4', 
                true
            )
        );
        jsEncodeTests.add(new EncodeTest('abc\\def', 'abc\\\\def', 'Valid #5', true));
        jsEncodeTests.add(new EncodeTest('abc\'def', 'abc\\\'def', 'Valid #6', true));
        jsEncodeTests.add(new EncodeTest('abc\rdef', 'abc\\rdef', 'Valid #7', true));
        jsEncodeTests.add(new EncodeTest('abc\ndef', 'abc\\ndef', 'Valid #8', true));
        jsEncodeTests.add(new EncodeTest('abc"def', 'abc\\"def', 'Valid #9', true));
        jsEncodeTests.add(new EncodeTest('abc!--def', 'abc\\!--def', 'Valid #10', true));
        jsEncodeTests.add(new EncodeTest('abc<!--def', 'abc\\u003C\\!--def', 'Valid #11', true));
        jsEncodeTests.add(new EncodeTest('abc/def', 'abc\\/def', 'Valid #12', true));

        jsInHtmlEncodeTests.add(new EncodeTest('abc', 'abc', 'Valid #1', true));
        jsInHtmlEncodeTests.add(new EncodeTest(
                'abc<b>test</b>def', 
                'abc&lt;b&gt;test&lt;/b&gt;def',
                'Valid #2', 
                true
            )
        );
        jsInHtmlEncodeTests.add(new EncodeTest('abc&lt;def', 'abc&amp;lt;def', 'Valid #3', true));
        jsInHtmlEncodeTests.add(new EncodeTest(
                'abc<fghgfh&lt;<sfdg>&amp;def',
                'abc&lt;fghgfh&amp;lt;&lt;sfdg&gt;&amp;amp;def', 
                'Valid #4', 
                true
            )
        );
        jsInHtmlEncodeTests.add(new EncodeTest('abc\'def', 'abc\\\'def', 'Valid #5', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc"def', 'abc\\&quot;def', 'Valid #6', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc&def', 'abc&amp;def', 'Valid #7', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc\\def', 'abc\\\\def', 'Valid #8', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc\rdef', 'abc\\rdef', 'Valid #9', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc\ndef', 'abc\\ndef', 'Valid #10', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc<def', 'abc&lt;def', 'Valid #11', true));
        jsInHtmlEncodeTests.add(new EncodeTest('abc>def', 'abc&gt;def', 'Valid #12', true));

        urlEncodeTests.add(new EncodeTest('abc', 'abc', 'Valid #1', true));
        urlEncodeTests.add(new EncodeTest(
                'abc<b>test</b>def', 
                'abc%3Cb%3Etest%3C%2Fb%3Edef', 
                'Valid #2',
                true
            )
        );
        urlEncodeTests.add(new EncodeTest('abc&lt;def', 'abc%26lt%3Bdef', 'Valid #3', true));
        urlEncodeTests.add(new EncodeTest(
                'abc<fghgfh&lt;<sfdg>&amp;def',
                'abc%3Cfghgfh%26lt%3B%3Csfdg%3E%26amp%3Bdef', 
                'Valid #4', 
                true
            )
        );
        urlEncodeTests.add(new EncodeTest('abc\'def', 'abc%27def', 'Valid #5', true));
        urlEncodeTests.add(new EncodeTest('abc"def', 'abc%22def', 'Valid #6', true));
        urlEncodeTests.add(new EncodeTest('abc\rdef', 'abc%0Ddef', 'Valid #7', true));
        urlEncodeTests.add(new EncodeTest('abc\ndef', 'abc%0Adef', 'Valid #8', true));
        urlEncodeTests.add(new EncodeTest(
                'abc' + EncodingUtil.urlDecode('%D7%A9', 'UTF-8') + 'def',
                'abc%D7%A9def', 
                'Valid #9', 
                true
            )
        );

        urlEncodeWithEncodingTests.add(new EncodeTest('abc', 'UTF-8', 'abc', 'Valid #1', true));
        urlEncodeWithEncodingTests.add(new EncodeTest('abc<b>test</b>def', 'UTF-8',
                                       'abc%3Cb%3Etest%3C%2Fb%3Edef', 'Valid #2', true));
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc&lt;def', 
                'UTF-8', 
                'abc%26lt%3Bdef', 
                'Valid #3',
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc<fghgfh&lt;<sfdg>&amp;def', 
                'UTF-8',
                'abc%3Cfghgfh%26lt%3B%3Csfdg%3E%26amp%3Bdef', 
                'Valid #4', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc\'def', 
                'UTF-8', 
                'abc%27def', 
                'Valid #5', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc"def', 
                'UTF-8', 
                'abc%22def', 
                'Valid #6', 
             true
             )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc\rdef', 
                'UTF-8', 
                'abc%0Ddef', 
                'Valid #7', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc\ndef', 
                'UTF-8', 
                'abc%0Adef', 
                'Valid #8', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc' + EncodingUtil.urlDecode('%D7%A9', 'UTF-8') + 'def',
                'UTF-8', 
                'abc%D7%A9def', 
                'Valid #9', 
                true
            )
        );

        urlEncodeWithEncodingTests.add(new EncodeTest('abc', 'UTF-16', 'abc', 'Valid #1', true));
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc<b>test</b>def', 
                'UTF-16',
                'abc%FE%FF%00%3Cb%FE%FF%00%3Etest%FE%FF%00%3C%00%2Fb%FE%FF%00%3Edef', 
                'Valid #2', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc&lt;def', 
                'UTF-16',
                'abc%FE%FF%00%26lt%FE%FF%00%3Bdef', 
                'Valid #3', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc<fghgfh&lt;<sfdg>&amp;def', 
                'UTF-16',
                'abc%FE%FF%00%3Cfghgfh%FE%FF%00%26lt%FE%FF%00%3B%00%3Csfdg%FE%FF%00%3E%00%26amp%FE%FF%00%3Bdef',
                'Valid #4', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc\'def', 
                'UTF-16', 
                'abc%FE%FF%00%27def',
                'Valid #5', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc"def', 
                'UTF-16', 
                'abc%FE%FF%00%22def', 
                'Valid #6',
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc\rdef', 
                'UTF-16', 
                'abc%FE%FF%00%0Ddef',
                'Valid #7', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc\ndef', 
                'UTF-16', 
                'abc%FE%FF%00%0Adef',
                'Valid #8', 
                true
            )
        );
        urlEncodeWithEncodingTests.add(new EncodeTest(
                'abc' + EncodingUtil.urlDecode('%D7%A9', 'UTF-8') + 'def', 
                'UTF-16', 
                'abc%FE%FF%05%E9def', 
                'Valid #9', 
                true
            )
        );
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: testEncoderHtmlEncode                                                              */
    /*                                                                                            */
    /* This method runs tests for SFDCEncoder.                                                    */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testMethod void testEncoderHtmlEncode() {
        for (EncodeTest t : htmlEncodeTests) {
            try {
                String ret = ESAPI.encoder().SFDC_HTMLENCODE(t.inputStr);
                // if no exception - check if we are expecting a valid test
                System.assert(t.expectedResult == true, t.errText);
                // also make sure return value is equal to input
                System.assert(ret.equals(t.expectedOutput), t.errText);
            } catch (Exception e) {
                // if exception - check if we are expecting an invalid test
                System.assert(t.expectedResult == false, t.errText);
            }
        }
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: testEncoderJsEncode                                                                */
    /*                                                                                            */
    /* This method runs tests for SFDCEncoder.                                                    */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testMethod void testEncoderJsEncode() {
        for (EncodeTest t : jsEncodeTests) {
            try {
                String ret = ESAPI.encoder().SFDC_JSENCODE(t.inputStr);
                // if no exception - check if we are expecting a valid test
                System.assert(t.expectedResult == true, t.errText);
                // also make sure return value is equal to input
                System.assert(ret.equals(t.expectedOutput), t.errText);
            } catch (Exception e) {
                // if exception - check if we are expecting an invalid test
                System.assert(t.expectedResult == false, t.errText);
            }
        }
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: testEncoderJsInHtmlEncode                                                          */
    /*                                                                                            */
    /* This method runs tests for SFDCEncoder.                                                    */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testMethod void testEncoderJsInHtmlEncode() {
        for (EncodeTest t : jsInHtmlEncodeTests) {
            try {
                String ret = ESAPI.encoder().SFDC_JSINHTMLENCODE(t.inputStr);
                // if no exception - check if we are expecting a valid test
                System.assert(t.expectedResult == true, t.errText);
                // also make sure return value is equal to input
                System.assert(ret.equals(t.expectedOutput), t.errText);
            } catch (Exception e) {
                // if exception - check if we are expecting an invalid test
                System.assert(t.expectedResult == false, t.errText);
            }
        }
        System.assert(ESAPI.encoder().SFDC_JSINHTMLENCODE(null) == null);
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: testEncoderUrlEncode                                                               */
    /*                                                                                            */
    /* This method runs tests for SFDCEncoder.                                                    */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testMethod void testEncoderUrlEncode() {
        for (EncodeTest t : urlEncodeTests) {
            try {
                String ret = ESAPI.encoder().SFDC_URLENCODE(t.inputStr);
                // if no exception - check if we are expecting a valid test
                System.assert(t.expectedResult == true, t.errText);
                // also make sure return value is equal to input
                System.assert(ret.equals(t.expectedOutput), t.errText);
            } catch (Exception e) {
                // if exception - check if we are expecting an invalid test
                System.assert(t.expectedResult == false, t.errText);
            }
        }
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: testEncoderUrlEncodeWithEncoding                                                   */
    /*                                                                                            */
    /* This method runs tests for SFDCEncoder.                                                    */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testMethod void testEncoderUrlEncodeWithEncoding() {
        for (EncodeTest t : urlEncodeWithEncodingTests) {
            try {
                String ret = ESAPI.encoder().SFDC_URLENCODE(t.inputStr, t.encoding);
                // if no exception - check if we are expecting a valid test
                System.assert(t.expectedResult == true, t.errText);
                // also make sure return value is equal to input
                System.assert(ret.equals(t.expectedOutput), t.errText);
            } catch (Exception e) {
                // if exception - check if we are expecting an invalid test
                System.assert(t.expectedResult == false, t.errText);
            }
        }
    }
}