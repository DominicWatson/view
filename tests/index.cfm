<cfset variables.testResults = CreateObject( "component", "mxunit.runner.DirectoryTestSuite" ).run(
	  directory     = GetDirectoryFromPath( GetCurrentTemplatePath() )
	, componentPath = "tests."
	, excludes      = "mxunit"
	, recurse	    = true
) />

<cfcontent reset="true" /><cfoutput>#testResults.getHtmlResults()#</cfoutput>