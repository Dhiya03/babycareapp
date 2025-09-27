@ECHO OFF
@REM Gradle startup script for Windows

SET APP_BASE_NAME=%~n0
SET APP_HOME=%~dp0

SET DEFAULT_JVM_OPTS=

SET CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar

SET JAVA_EXE=java.exe
IF NOT "%JAVA_HOME%"=="" (
    SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
)

IF EXIST "%JAVA_EXE%" (
    "%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
) ELSE (
    ECHO ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
    EXIT /B 1
)
