#view

*View* is a slim framework for your view layer in CFML applications. It sits in front of regular `.cfm` files to add a little strictness and simple API for rendering your views.

##An example setup:

###Directory containing views
    views/
        common/
        	header.cfm
        	footer.cfm
        	sidebar.cfm
        general/
            listFooter.cfm
        layouts/
            default.cfm
            mobile.cfm
        pages/
        	about.cfm
        	etc.cfm
    udfs/
        string/
            stringlib.cfm
            formatters.cfm
        ... etc.

###Instantiating the *View* framework
    viewFw = CreateObject( "component", "view.View" ).init(
          viewPaths = "/views"
        , udfPaths  = "/udfs"
    );

###Rendering views
	requestData.body    = viewFw.render( "pages.etc"     , requestData );
	requestData.header  = viewFw.render( "common.header" , requestData );
	requestData.footer  = viewFw.render( "common.footer" , requestData );
	requestData.sidebar = viewFw.render( "common.sidebar", requestData );
	...
	<cfoutput>#viewFw.render( "layouts.default", requestData )#</cfoutput>

###An example view, etc.cfm

    <cfparam name="args.listOfEtcThings" type="query"  default="#QueryNew('title')#" />
    <cfparam name="args.aRequiredTitle"  type="string"                               />

    <cfset loc.someLocalVarToTheView = "hello world" />

    <cfoutput>
        <h3>#args.aRequiredTitle#</h3>
        <p>#loc.someLocalVarToTheView#</p>
        <cfif not args.listOfEtcThings.recordCount>
            <p>There are no etc. things.</p>
        <cfelse>
            <ul class="etc-things">
                <cfloop query="args.listOfEtcThings">
                    <li>#udf.formatEtcTitle( args.listOfEtcThings.title )#</li>
                </cfloop>
            </ul>
        </cfif>

        #render( view = "general.listFooter", data = { list = args.listOfEtcThings } )#
    </cfoutput>

##A little strictness

The *View* framework limits your views exposure to variables. It provides the view with three structures:

1. *args*. This is data that the view requires to work. The framework will *only* pass an arg if it has been parametized using cfparam. If the cfparam tag provides no default and the variable is not passed to the `render` method, the framework will throw a suitable error
2. *loc*. This is an empty struct that the view can use for any variables that it needs within itself (local).
3. *udf*. This struct will be populated with functions found in `.cfm` files within your udf directories. The udf directories are set when you instantiate the framework

That's pretty much it!