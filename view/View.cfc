<cfcomponent output="false" extends="util.Base">

	<cfscript>
		_views    = StructNew();
		_viewDirs = ArrayNew(1);
		_devMode  = false;
	</cfscript>

	<cffunction name="init" access="public" returntype="any" output="false" hint="Constructor. This method should be called with to instantiate the View framework. Ideally, the result of this call should be cached in some permanent scope such as the Application scope. Instantiating per request will be costly.">
		<cfargument name="viewDirs" type="string"  required="true"                  hint="Comma separated list of directories that contain views. When their local paths are the same, views in directories that come later in the list will override those from directories earlier in the list." />
		<cfargument name="udfDirs"  type="string"  required="false" default=""      hint="Comma separated list of directories that contain cfm files with user defined functions. These functions will be available to all views." />
		<cfargument name="devMode"  type="boolean" required="false" default="false" hint="Whether or not to run in Dev mode (default false). In dev mode, the View framework will automatically reload changes you make to your source files." />

		<cfscript>
			_setViewDirs( viewDirs );
			_setDevMode( devMode );

			_initViewRenderer( udfDirs );
			_loadViews();

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="render" access="public" returntype="string" output="false" hint="The render method returns a rendered view (string).">
		<cfargument name="view" type="string" required="true"                          hint="Dot separated path to a view, without the .cfm extension. e.g. if you have the file /views/layouts/etc/someView.cfm, it would be referenced as 'layouts.etc.someView'." />
		<cfargument name="data" type="struct" required="false" default="#StructNew()#" hint="Structure of data that should be made available to the view. Only variables that have been 'cfparamd' in the view will be passed on to the view." />

		<cfscript>
			var v = _getView( view );

			return _getViewRenderer().renderView(
				  __viewPath = v.pathForCfInclude
				, __data     = _prepareViewArguments( v, data )
			);
		</cfscript>
	</cffunction>

<!--- private --->
	<cffunction name="_loadViews" access="private" returntype="void" output="false">
		<cfscript>
			var viewDirs   = _getViewDirs();
			var files       = "";
			var filePath    = "";
			var fileContent = "";
			var views       = StructNew();
			var view        = "";
			var i           = "";
			var n           = "";

			for( i=1; i LTE ArrayLen( viewDirs ); i++ ){
				files = $directoryList( viewDirs[i], "*.cfm" )

				for( n=1; n LTE files.recordCount; n++ ){
					filePath    = $normalizeUnixAndWindowsPaths( $listAppend( files.directory[n], files.name[n], '/' ) );
					fileContent = $fileRead( filePath );

					view                           = _convertFullViewPathToViewName( filePath, viewDirs[i] );
					views[ view ]                  = StructNew();
					views[ view ].path             = filePath;
					views[ view ].args             = _parseArgsFromCfParam( fileContent );
					views[ view ].pathForCfInclude = _convertFullPathToRelativePathForCfInclude( filePath );
				}
			}

			_setViews( views );
		</cfscript>
	</cffunction>

	<cffunction name="_getView" access="private" returntype="struct" output="false">
		<cfargument name="view" type="string" required="true" />

		<cfscript>
			var views = _getViews();

			if ( StructKeyExists( views, view ) ) {
				return views[ view ];
			}

			$throw( "view.notfound", "View not found. The view, '#view#', could not be found." );
		</cfscript>
	</cffunction>

	<cffunction name="_convertFullViewPathToViewName" access="private" returntype="string" output="false">
		<cfargument name="fullPath" type="string" required="true" />
		<cfargument name="viewPath" type="string" required="true" />

		<cfscript>
			var viewName = fullPath;

			viewName = Replace( viewName, viewPath, "" );
			viewName = ListChangeDelims( viewName, ".", "/" );
			viewName = Left( viewName, Len(viewName) - 4 );

			return viewName;
		</cfscript>
	</cffunction>

	<cffunction name="_convertFullPathToRelativePathForCfInclude" access="private" returntype="any" output="false">
		<cfargument name="fullPath" type="string" required="true" />

		<cfscript>
			var basePath = $listAppend( GetDirectoryFromPath( GetCurrentTemplatePath() ), 'util/ViewRenderer.cfc', '/' );

			return $calculateRelativePath( basePath, fullPath );
		</cfscript>
	</cffunction>

	<cffunction name="_parseArgsFromCfParam" access="private" returntype="array" output="false">
		<cfargument name="fileContent" type="string" required="true" />

		<cfscript>
			var regex       = '<cfparam\s+name="args\.(.*?)"(.*?)>';
			var regexResult = $research( regex, fileContent );
			var i           = 0;
			var args        = ArrayNew();
			var arg         = "";

			if ( StructKeyExists( regexResult, "$1" ) ) {
				for ( i=1; i LTE ArrayLen( regexResult.$1 ); i++ ){
					arg = StructNew();
					arg.name = regexResult.$1[i];
					arg.required = not ReFindNoCase( 'default=".*?"', regexResult.$2[i] );
					ArrayAppend( args, arg );
				}
			}

			return args;
		</cfscript>
	</cffunction>

	<cffunction name="_prepareViewArguments" access="private" returntype="struct" output="false">
		<cfargument name="view" type="struct" required="true" />
		<cfargument name="data" type="struct" required="true" />

		<cfscript>
			var args = StructNew();
			var i    = 0;

			for( i=1; i LTE ArrayLen( view.args ); i++ ) {
				if ( StructKeyExists( data, view.args[i].name ) ) {
					args[ view.args[i].name ] = data[ view.args[i].name ];

				} else if ( view.args[i].required ) {
					$throw(
						  type    = "view.missing.argument"
						, message = "The argument '#view.args[i].name#' is required by #ListLast(view.path, '/')# but was not passed to the render() method."
						, detail  = view.path
					);
				}
			}

			return args;
		</cfscript>
	</cffunction>

	<cffunction name="_initViewRenderer" access="private" returntype="void" output="false">
		<cfargument name="udfDirs"  type="string"  required="true" />

		<cfscript>
			var udfs = CreateObject( "component", "util.UdfWrapper" ).init( udfDirs = udfDirs )
			var vr   = CreateObject( "component", "util.ViewRenderer" ).init( framework = this, udfs = udfs );

			_setViewRenderer( vr );
		</cfscript>
	</cffunction>

<!--- accessors --->
	<cffunction name="_getViews" access="private" returntype="struct" output="false">
		<cfscript>
			if ( _getDevMode() and not StructKeyExists( request, "_viewFWCheckedForChanges" ) ) {
				request._viewFWCheckedForChanges = true;
				_loadViews();
			}

			return _views;
		</cfscript>
		<cfreturn _views>
	</cffunction>
	<cffunction name="_setViews" access="private" returntype="void" output="false">
		<cfargument name="views" type="struct" required="true" />
		<cfset _views = views />
	</cffunction>

	<cffunction name="_getViewDirs" access="private" returntype="array" output="false">
		<cfreturn _viewDirs />
	</cffunction>
	<cffunction name="_setViewDirs" access="private" returntype="void" output="false">
		<cfargument name="viewDirs" type="string" required="true" />

		<cfscript>
			var i = 0;

			_viewDirs = ListToArray( viewDirs );

			for( i=1; i LTE ArrayLen( _viewDirs ); i++ ){
				_viewDirs[i] = $normalizeUnixAndWindowsPaths( $ensureFullDirectoryPath( _viewDirs[i] ) );
			}
		</cfscript>
	</cffunction>

	<cffunction name="_getViewRenderer" access="private" returntype="any" output="false">
		<cfreturn _viewRenderer>
	</cffunction>
	<cffunction name="_setViewRenderer" access="private" returntype="void" output="false">
		<cfargument name="viewRenderer" type="any" required="true" />
		<cfset _viewRenderer = arguments.viewRenderer />
	</cffunction>

	<cffunction name="_getDevMode" access="private" returntype="boolean" output="false">
		<cfreturn _devMode>
	</cffunction>
	<cffunction name="_setDevMode" access="private" returntype="void" output="false">
		<cfargument name="devMode" type="boolean" required="true" />
		<cfset _devMode = arguments.devMode />
	</cffunction>
</cfcomponent>