TCK Results Jetty Project
=====================
This project contains details of failures running TCK against Jetty Project

Servlet TCK
---------------------

9.4.x has 72 failures on 1690 tests (Jenkins job running every day in case of code change in branch 9.4.x (https://jenkins.webtide.net/job/nightlies/job/servlettck-run-jetty-9.4.x)

10.0.x has 38 failures on 1690 tests (Jenkins job running every day in case of code change in branch 10.0.x (https://jenkins.webtide.net/job/nightlies/job/servlettck-run-jetty-10.0.x)

| Failures | Cause | 9.4.x | 10.0.x | Github issue |
|----------|-------|-------|--------|--------------|
| com/sun/ts/tests/servlet/api/javax_servlet/genericfilter/*          | Caused by: java.lang.ClassNotFoundException: javax.servlet.GenericFilter | Servlet 4.0 specs 8 failure | 1 failure to investigate :question: |
| com/sun/ts/tests/servlet/api/javax_servlet/scattributelistener40/URLClient.java#defaultMethodsTest | java.lang.AbstractMethodError: com.sun.ts.tests.servlet.api.javax_servlet.scattributelistener40.SCAttributeListener40.attributeAdded(Ljavax/servlet/ServletContextAttributeEvent;)V | Servlet 4.0 Specs 1 failure | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet/scinitializer/getdefaultsessiontrackingmodes/URLClient.java#getDefaultSessionTrackingModes | Exception (UnsupportedOperationException) not throw (https://javaee.github.io/javaee-spec/javadocs/javax/servlet/ServletContext.html#getDefaultSessionTrackingModes--) | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/scinitializer/geteffectivesessiontrackingmodes/URLClient.java#getEffectiveSessionTrackingModes | Exception (UnsupportedOperationException) not throw | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/sclistener40/URLClient.java#defaultMethodsTest | java.lang.AbstractMethodError () | Servlet 4.0 ServletContextListener has default methods but not in 3.1 | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext/URLClient.java#GetMajorVersionTest | 4 expected but return 3 | Servlet 4.0 Specs |  :white_check_mark: Fixed | (https://github.com/eclipse/jetty.project/issues/4222) |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext/URLClient.java#GetMinorVersionTest | 0 expected but return 1 | Servlet 4.0 Specs |  :white_check_mark: Fixed | (https://github.com/eclipse/jetty.project/issues/4222) |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext304/URLClient.java#addListenerTest | No IAE, ServletContext #createListener must IllegalArgumentException - if the specified EventListener class does not implement any of the ServletContextListener,ServletContextAttributeListener, ServletRequestListener, ServletRequestAttributeListener, HttpSessionAttributeListener, HttpSessionIdListener, orHttpSessionListener interfaces. ServletContextHandler#createListener is used to create more type of listener... | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext40/Client.java | NoSuchMethodError | Servlet 4.0 specs 12 failure | 12 failure to investigate :question: |
| com/sun/ts/tests/servlet/api/javax_servlet/servletresponse/URLClient.java#getContentTypeNull2Test | Servlet verifies content-type is being re-set by programmer and character encoding setting does not change. Not clear Test code do ``` response.setContentType("text/html;charset=Shift_Jis"); response.setContentType("text/xml"); String actual_encoding = response.getCharacterEncoding(); String actual_type = response.getContentType(); Expected is: Actual_type == "text/html;charset=Shift_Jis" ``` | 1 failure | 1 failure |
| com/sun/ts/tests/servlet/api/javax_servlet/srlistener40/URLClient.java#defaultMethodsTest | Servlet 4.0 Interface with default method | Servlet 4.0 Specs | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#getDomainTest | Cookie: $Version="1"; name1="value1"; $Path="/servlet_jsh_cookie_web"; $Domain="localhost" cookie.getDomain null | Setup compliance mode | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#getPathTest | Cookie: $Version="1"; name1="value1"; $Path="/servlet_jsh_cookie_web"; $Domain="localhost" cookie.getPath null | Setup compliance mode | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#getVersionTest | Cookie: $Version="1"; name1="value1"; $Path="/servlet_jsh_cookie_web"; $Domain="localhost" : cookie.getVersion -> 0 (not 1) | Setup compliance mode | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#setMaxAgeNegativeTest | Version=1 missing | Setup compliance mode | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#setMaxAgePositiveTest | Version=1 missing | Setup compliance mode | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#setMaxAgeZeroTest | Version=1 missing | Setup compliance mode | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/cookie/URLClient.java#setPathTest | Version=1 Missing in response headers | 1 test | Setup compliance mode |
| com/sun/ts/tests/servlet/api/javax_servlet_http/httpfilter/URLClient.java#dofilterTest | Servlet 4.0 Interface | Servlet 4.0 Specs | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet_http/httpservletrequest40/Client.java#** | Servlet 4.0 Specs | Servlet 4.0 Specs 11 failure | 9 failures :question: |
| com/sun/ts/tests/servlet/api/javax_servlet_http/httpservletrequestwrapper/URLClient.java#changeSessionIDTest1 | NPE weird test. code request.getSession(false).getAttribute(attrName_OLD)) Trying accessing an attribute which is never set... | :question: | :question: |
| com/sun/ts/tests/servlet/api/javax_servlet_http/httpservletresponse40/Client.java#* |  Servlet 4.0 Specs | Servlet 4.0 Specs 3 failure | 3 failures :question: |
| com/sun/ts/tests/servlet/api/javax_servlet_http/httpsessionbindinglistener40/URLClient.java#defaultMethodsTest | Servlet 4.0 Interface with default method | Servlet 4.0 Specs | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet_http/httpupgradehandler/URLClient.java#upgradeTest | HttpServletRequest.upgrade not supported | Not supported | Not supported |
| com/sun/ts/tests/servlet/api/javax_servlet_http/readlistener1/URLClient.java#nioInputTest2 | ServletInputStream.setReadListener should throw ISE if request not upgraded nor async started | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet_http/servletcontext304/URLClient.java#addListenerTest | ContextHandler fix addProgrammaticListener do not add the Listener ServletContext.addListener | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/asynccontext/URLClient.java.forwardTest1 | Incorrect header order sequence when starting async | 1 test | 1 test | |
| com/sun/ts/tests/servlet/pluggability/fragment/URLClient.java.welcomefileTest | web-fragment defining a servlet in <welcome-file-list> servlet is not invoked when invoking / | 1 test | 1 test |
| com/sun/ts/tests/servlet/spec/defaultcontextpath/URLClient.java.getDefaultContextPathTest |  Servlet 4.0 Specs | Servlet 4.0 Specs 1 failure | :white_check_mark: |
| com/sun/ts/tests/servlet/spec/i18n/encoding/URLClient.java.spec2Test | response.setContentType("text/html"); response.getCharacterEncoding() != "iso-8859-1",  with  ``` <locale-encoding-mapping-list> <locale-encoding-mapping> <locale>ja</locale> <encoding>euc-jp</encoding> </locale-encoding-mapping> <locale-encoding-mapping> <locale>zh_CN</locale> <encoding>gb18030</encoding> </locale-encoding-mapping> </locale-encoding-mapping-list> ```, response.setLocale(Locale.CHINA); response.getCharacterEncoding() != gb18030; response.setContentType("text/html"); response.getCharacterEncoding() != gb18030 | 1 failure | 1 failure |
| com/sun/ts/tests/servlet/spec/i18n/encoding/URLClient.java.spec3Test | expected iso-8859-1 // setContentType should set character encoding response.setContentType("text/html"); actual[0] = response.getCharacterEncoding(); // committing should freeze the character encoding response.flushBuffer(); actual[1] = response.getCharacterEncoding(); // setCharacterEncoding should no longer be able to change the encoding response.setCharacterEncoding("utf-8"); actual[2] = response.getCharacterEncoding(); // setLocale should not override explicit character encoding request response.setLocale(Locale.JAPAN); actual[3] = response.getCharacterEncoding(); // getWriter should freeze the character encoding PrintWriter pw = response.getWriter(); actual[4] = response.getCharacterEncoding(); | 1 failure | 1 failure |
| com/sun/ts/tests/servlet/spec/security/clientcert/Client.java.clientCertTest | test in https | 1 failure | 1 failure |
| com/sun/ts/tests/servlet/spec/security/clientcertanno/Client.java.clientCertTest | test in https | 1 failure | 1 failure |    
| com/sun/ts/tests/servlet/spec/security/denyUncovered/Client.java.* | the TCK test is deployed with a war named `servlet_sec_denyUncovered_web.war` so the default path is `/servlet_sec_denyUncovered_web` but TCK tests are targeting context path `servlet_sec_denyUncovered` | 5 failure | 5 failure | TCK bug https://github.com/eclipse-ee4j/jakartaee-tck/issues/45 |
| com/sun/ts/tests/servlet/spec/security/metadatacomplete/Client.java.test5 | | | | 
  


 




  


