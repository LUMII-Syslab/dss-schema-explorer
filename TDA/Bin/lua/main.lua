
print('-----*********uuuuuuuuuuuuuuuuu******-----------')
--prop = require("interpreter.Properties")
  --local element =  lQuery("Element"):filter(":has(/elemType[id='Students'])")
  --utilities.show_element_compartment_tree()
  --	local Delete = require("interpreter.Delete")
  --  Delete.delete_current_diagram()
  
utilities.current_diagram():log("caption")
local cc = lQuery("Compartment[input = 'CCC']"):log()

local diagram = cc:find("/element/graphDiagram"):log()

	cc:each(function(c) 
		print('*************')
		local diagram = c:find("/element/graphDiagram")
		c:attr("input", "DDD")
		c:attr("value", "DDD")
		print('------------------')
		local cmd = lQuery.create("OkCmd")
		cmd:link("graphDiagram", diagram)
		utilities.execute_cmd_obj(cmd)
	end)
 
 function export_diagrams_to_json(js_file_path)
	-- gather diagram data
	local data = require("repo_browser.diagrams").all_diagrams_in_table_form()
	-- encode data
	local js_file_content = "data = " .. require("reporter.dkjson").encode(data)

	-- save js file
	local file = io.open(js_file_path, "w")
	file:write(js_file_content)
	file:close()
end

--export_diagrams_to_json(tda.GetRuntimePath().."\\data.js")

--require("tests_db")
--tests_db.test()  -- nez kas tas tâds man bija


-- utilities.active_elements():log()
 
  --utilities.activate_element(element)
  --prop.Properties()
  
  --lQuery("D#Form"):delete()  -- !!!!!
  --local s = require("spec2")
  --s.create_test()  -- to var tiaki tam dst saukt
  --lQuery("PropertyTab[id='']"):delete()
  
  
