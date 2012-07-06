<cfcomponent output="false">
	<cfsetting requesttimeout="600" />

	<cfscript>
		this.name = "viewtests_" & hash(GetCurrenttemplatepath());

		root = GetDirectoryFromPath(GetCurrentTemplatePath());

		this.mappings['/mxunit']        = '#root#mxunit';
		this.mappings['/view']          = '#root#../view';
		this.mappings['/tests']         = Left(root, Len(root)-1); // remove trailing slash - breaks openBDs ExpandPath() method...
	</cfscript>
</cfcomponent>