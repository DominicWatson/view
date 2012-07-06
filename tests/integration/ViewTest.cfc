<cfcomponent extends="mxunit.framework.TestCase" output="false">

<!--- setup, teardown, etc --->
	<cffunction name="setup" access="public" returntype="void" output="false">
		<cfscript>
			super.setup();
		</cfscript>
	</cffunction>

	<cffunction name="teardown" access="public" returntype="void" output="false">
		<cfscript>
			super.teardown();
			StructClear(request);
		</cfscript>
	</cffunction>

<!--- tests --->
	<cffunction name="t01_renderView_shouldRenderTheCorrectView" returntype="void">
		<cfscript>
			var viewPath       = _getResourcePath() & "/workingViewTest";
			var expectedOutput = "<h1>Hello world</h1>";
			var view           = _getView().init(
				viewPath = viewPath
			);

			AssertEquals( expectedOutput, view.render( view="anotherFolder.someView", layout=false ) );
		</cfscript>
	</cffunction>

<!--- private utility --->
	<cffunction name="_getView" access="private" returntype="any" output="false">
		<cfreturn createObject('component', 'view.View') />
	</cffunction>

	<cffunction name="_getResourcePath" access="private" returntype="string" output="false">
		<cfreturn '/tests/integration/resources' />
	</cffunction>
</cfcomponent>