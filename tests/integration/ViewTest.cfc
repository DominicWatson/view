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
			var viewPaths      = _getResourcePath() & "/workingViewTest";
			var expectedOutput = "<h1>Hello world</h1>";
			var view           = _getView().init(
				viewPaths = viewPaths
			);

			super.assertEquals( expectedOutput, view.render( view="anotherFolder.someView" ) );
		</cfscript>
	</cffunction>

	<cffunction name="t02_renderView_shouldRenderPassedVariables" returntype="void">
		<cfscript>
			var viewPaths      = _getResourcePath() & "/workingViewTest";
			var expectedOutput = "<h1>Testing 123</h1>";
			var data           = StructNew();
			var view           = _getView().init(
				viewPaths = viewPaths
			);

			data.someVar = "Testing 123";

			super.assertEquals( expectedOutput, view.render( view="someFolder.aView", data=data ) );
		</cfscript>
	</cffunction>

	<cffunction name="t03_renderView_shouldThrowError_whenViewDoesNotExist" returntype="void">
		<cfscript>
			var viewPaths = _getResourcePath() & "/workingViewTest";
			var failed    = false;
			var view      = _getView().init(
				viewPaths = viewPaths
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

	<cffunction name="t04_renderView_shouldChooseTheMoreSpecificView_givenAlternatives" returntype="void">
		<cfscript>
			var viewPaths      = _getResourcePath() & "/workingViewTest" & "," & _getResourcePath() & "/workingViewTest2";
			var expectedOutput = "<h1>Hello universe</h1>";
			var view           = _getView().init(
				viewPaths = viewPaths
			);


			super.assertEquals( expectedOutput, view.render( view="anotherFolder.someView" ) );

			viewPaths = _getResourcePath() & "/workingViewTest2" & "," & _getResourcePath() & "/workingViewTest";
			expectedOutput = "<h1>Hello world</h1>";
			view = _getView().init(
				viewPaths = viewPaths
			);

			super.assertEquals( expectedOutput, view.render( view="anotherFolder.someView" ) );
		</cfscript>
	</cffunction>

	<cffunction name="t05_views_shouldBePreventedFromAlteringVariablesScope" returntype="void">
		<cfscript>
			var viewPaths = _getResourcePath() & "/workingViewTest";
			var viewPath  = Replace( ExpandPath( viewPaths & '/badViews/alteringVariablesScope.cfm' ), '\', '/', 'all' );
			var failed    = false;
			var view      = _getView().init(
				viewPaths = viewPaths
			);

			try {
				view.render( "badViews.alteringVariablesScope" );

			} catch ( "view.scope.altered" e ) {
				failed = true;
				super.assertEquals( "Scope altered in view, '#viewPath#'. To use variables local to your view, use the 'loc' scope.", e.message );
			}

			super.assert( failed, "View did not throw an appropriate error when the passed view altered variables scope." );
		</cfscript>
	</cffunction>

	<cffunction name="t06_view_shouldOnlyBePassedDataThatHasBeenCfParamd" returntype="void">
		<cfscript>
			var viewPaths      = _getResourcePath() & "/workingViewTest";
			var data           = StructNew();
			var failed         = false;
			var view           = _getView().init(
				viewPaths = viewPaths
			);

			data.someVar                      = "Testing 123";
			data.iHaveBeenPassedButNotParamed = "whatever";

			try {
				view.render(
					  view = "someFolder.aViewAccessingUnParametrizedVar"
					, data = data
				);

			} catch ( expression e ) {
				failed = e.message contains "iHaveBeenPassedButNotParamed";
			}

			super.assert( failed, "The View framework passed a variable to the view, even though it was not cfparamed" );
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