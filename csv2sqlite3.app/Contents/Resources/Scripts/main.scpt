JsOsaDAS1.001.00bplist00?Vscript_?var app = Application.currentApplication();
var SystemEvents = Application("System Events");
app.includeStandardAdditions = true;

function openDocuments(droppedItems) {
	var newexist = app.displayDialog("New or existing sqlite3 database?", {
	    buttons: ["Cancel", "Existing", "New"],
	    defaultButton: "New",
	    cancelButton: "Cancel"
	});
	if (newexist.buttonReturned == "New") {
		var document = app.chooseFileName({
  			withPrompt: "Please create a sqlite3 database:"
		});
	} else if(newexist.buttonReturned == "Existing") {
		var document = app.chooseFile({
    		withPrompt: "Please select a sqlite3 database:"
		});
	}
	var dbString  = document.toString();
	if (!dbString.toLowerCase().endsWith(".db")) {
		dbString = dbString + ".db";
	}
    for (var item of droppedItems) {
		var fileString = item.toString();
	    var alias = SystemEvents.aliases.byName(fileString);
    	var extension = alias.nameExtension();
	    var fileType = alias.fileType();
    	var typeIdentifier = alias.typeIdentifier();
		if (extension.toLowerCase() == "csv") {
			//var reader = new FileReader();
			//var text = reader.readAsText(file.slice(0, 100));
			var text = app.doShellScript('head -1 \"' + fileString + "\"");
			var fileName = app.doShellScript('basename \"' + fileString + "\" | rev | cut -f 2- -d '.' | rev");
			var columns = parse(text);
			var colnum = 0;
			var createsql = "CREATE TABLE \"" + fileName + "\" (";
			for (var colname of columns) {
				colnum += 1;
				if (colnum == 1) {
					firstcol = colname;
				} else {
					createsql += ",";
				} 
				createsql = createsql + "\"" + colname + "\" TEXT";
			}
			createsql += ");CREATE INDEX \"" + firstcol + "\" ON \"" + fileName + "\" (\"" + firstcol + "\");"
			var createresult = app.doShellScript('sqlite3 \"' + dbString + "\" '" + createsql + "' '.mode csv' '.import --skip 1 \"" + fileString + "\" \"" + fileName + "\"'" );
			//var dialogText = "The create SQL is " + createresult;
			//app.displayDialog(dialogText);
		}
    }
}

// Very basic CSV parser
function parse(row) {
  var insideQuote = false,                                             
      entries = [],                                                    
      entry = [];
  row.split('').forEach(function (character) {                         
    if(character === '"') {
      insideQuote = !insideQuote;                                      
    } else {
      if(character == "," && !insideQuote) {                           
        entries.push(entry.join(''));                                  
        entry = [];                                                    
      } else {
        entry.push(character);                                         
      }                                                                
    }                                                                  
  });
  entries.push(entry.join(''));                                        
  return entries;                                                      
}                              ?jscr  ??ޭ