TCK Results Jetty Project
=====================
This project contains details of failures running TCK against Jetty Project

Servlet TCK
---------------------

9.4.x has 91 failures on 1690 tests

10.0.x has 74 failures on 1690 tests

| Failures | Cause | 9.4.x | 10.0.x |
|----------|-------|-------|--------|
| com/sun/ts/tests/servlet/api/javax_servlet/genericfilter/*          | Caused by: java.lang.ClassNotFoundException: javax.servlet.GenericFilter | Servlet 4.0 specs 8 failure | 1 failure to investigate :question: |
| com/sun/ts/tests/servlet/api/javax_servlet/scattributelistener40/URLClient.java#defaultMethodsTest | java.lang.AbstractMethodError: com.sun.ts.tests.servlet.api.javax_servlet.scattributelistener40.SCAttributeListener40.attributeAdded(Ljavax/servlet/ServletContextAttributeEvent;)V | Servlet 4.0 Specs 1 failure | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet/scinitializer/getdefaultsessiontrackingmodes/URLClient.java#getDefaultSessionTrackingModes | Exception (UnsupportedOperationException) not throw https://javaee.github.io/javaee-spec/javadocs/javax/servlet/ServletContext.html#getDefaultSessionTrackingModes-- | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/scinitializer/geteffectivesessiontrackingmodes/URLClient.java#getEffectiveSessionTrackingModes | Exception (UnsupportedOperationException) not throw | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/sclistener40/URLClient.java#defaultMethodsTest | java.lang.AbstractMethodError () | Servlet 4.0 ServletContextListener has default methods but not in 3.1 | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext/URLClient.java#GetMajorVersionTest | 4 expected but return 3 | Servlet 4.0 Specs | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext/URLClient.java#GetMinorVersionTest | 0 expected but return 1 | Servlet 4.0 Specs | :white_check_mark: |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext304/URLClient.java#addListenerTest | No IAE, ServletContext #createListener must IllegalArgumentException - if the specified EventListener class does not implement any of the ServletContextListener,ServletContextAttributeListener, ServletRequestListener, ServletRequestAttributeListener, HttpSessionAttributeListener, HttpSessionIdListener, orHttpSessionListener interfaces. ServletContextHandler#createListener is used to create more type of listener... | 1 test | 1 test |
| com/sun/ts/tests/servlet/api/javax_servlet/servletcontext40/Client.java | NoSuchMethodError | Servlet 4.0 specs 12 failure | 12 failure to investigate :question: |
| com/sun/ts/tests/servlet/api/javax_servlet/servletresponse/URLClient.java#getContentTypeNull2Test | Servlet verifies content-type is being re-set by programmer and character encoding setting does not change. Not clear Test code do ``` response.setContentType("text/html;charset=Shift_Jis"); response.setContentType("text/xml"); String actual_encoding = response.getCharacterEncoding(); String actual_type = response.getContentType(); Expected is: Actual_type == "text/html;charset=Shift_Jis" ``` | 1 failure | 1 failure |



  


