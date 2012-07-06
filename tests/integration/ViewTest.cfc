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

			super.assertEquals( expectedOutput, view.render( view="anotherFolder.someView" ) );
		</cfscript>
	</cffunction>

	<cffunction name="t02_renderView_shouldRenderPassedVariables" returntype="void">
		<cfscript>
			var viewPath       = _getResourcePath() & "/workingViewTest";
			var expectedOutput = "<h1>Testing 123</h1>";
			var data           = StructNew();
			var view           = _getView().init(
				viewPath = viewPath
			);

			data.someVar = "Testing 123";

			super.assertEquals( expectedOutput, view.render( view="someFolder.aView", data=data ) );
		</cfscript>
	</cffunction>

	<cffunction name="t03_renderView_shouldThrowError_whenViewDoesNotExist" returntype="void">
		<cfscript>
			var viewPath = _getResourcePath() & "/workingViewTest";
			var failed   = false;
			var view     = _getView().init(
				viewPath = viewPath
			);

			try {
				view.render( "non.existant.view" );

			} catch ( "view.notfound" e ) {
				failed = true;
				super.assertEquals( "View not found. The view, 'non.existant.view', could not be found.", e.message );
			}

			super.assert( failed, "View did not throw an appropriate error when the passed view did not exist." );
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