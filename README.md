Cocobase Godot SDK Plugin
=========================

**Cocobase Godot SDK** is a Godot plugin for interacting with [Cocobase](https://cocobase.buzz) APIs. It allows you to manage collections, documents, and user authentication directly from Godot without leaving your game or application.

> ⚠️ **Note:** This plugin is still in development. Some features may not be fully implemented yet.

Features
--------

### Collections

*   Create, update, and delete collections
    
*   Export collections
    
*   Count documents in a collection
    

### Documents

*   Create, update, and delete documents
    
*   Retrieve a single document or all documents in a collection
    

### User Management

*   Login and create users
    
*   Get current user info
    
*   Send, verify, and resend email verification
    
*   Retrieve all users in an authentication collection
    

### HTTP Request Handling

*   Handles JSON requests and responses automatically
    
*   Supports GET, POST, PUT, PATCH, and DELETE requests
    

Installation
------------

1.  Copy the Cocobase.gd file into your Godot project, e.g., res://addons/cocobase/.
    
2.  Make sure the file is included in your project tree.
    
3.  Add it as a child node in your scene to start making API calls.
    

Usage Example
-------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   extends Node2D  # Initialize the Cocobase SDK  var cocobase = Cocobase.new()  func _ready() -> void:      add_child(cocobase)      # Initialize with your API key      cocobase.init("YOUR_API_KEY_HERE")      # Example: Get all documents in a collection      cocobase.get_all_documents("989641d9-61b9-4bc5-a317-b0e347bb347b")   `

Working with Collections
------------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   # Create a collection  cocobase.create_collection("MyCollection")  # Update a collection  cocobase.updateCollection("OldCollectionName", "NewCollectionName")  # Delete a collection  cocobase.deleteCollection("CollectionName")  # Count documents in a collection  cocobase.countDocument("CollectionName")  # Export collection data  cocobase.exportCollection("CollectionName")   `

Working with Documents
----------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   # Create a document  var doc_data = {"name": "John", "score": 100}  cocobase.create_document("MyCollection", doc_data)  # Get a single document  cocobase.getDocument("CollectionName", "DocumentID")  # Update a document  var update_data = {"score": 120}  cocobase.updateDocument("CollectionName", "DocumentID", update_data)  # Delete a document  cocobase.deleteDocument("CollectionName", "DocumentID", {})   `

User Authentication
-------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   # Login user  var login_data = {"email": "user@example.com", "password": "mypassword"}  cocobase.loginUser(login_data)  # Create user  var user_data = {"email": "newuser@example.com", "password": "mypassword"}  cocobase.createUser(user_data)  # Get current user info  cocobase.getCurrentUser()  # Update current user info  cocobase.updateCurrentUser()  # Send verification email  cocobase.sendVerificationEmail()  # Verify email  cocobase.verifyEmail("verification_token_here")  # Resend verification email  cocobase.resendVerificationEmail()   `

Notes
-----

*   API requests are **asynchronous**. Use the \_on\_request\_completed callback in Cocobase.gd to handle responses.
    
*   Keep your API key **private** and **never hardcode it in public projects**.
    
*   The SDK currently supports **JSON payloads only**.
    
*   Compatible with **Godot 3.4+**.
    

Example Scene Setup
-------------------

1.  Create a Node2D scene.
    
2.  Add Cocobase.gd as a child node or instantiate it in \_ready().
    
3.  Call desired API functions from your script, e.g., creating collections or fetching documents.
    
4.  Monitor the Godot output console for printed responses.
    

License
-------

This SDK is **open source** and free to use in your Godot projects. Attribution is appreciated but not required.