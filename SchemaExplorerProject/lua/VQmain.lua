module(..., package.seeall)
require "utilities"
require "core"
local dkjson = require("reporter.dkjson")
local Delete = require("interpreter.Delete")

function MakeDiagram_json() 
	local info = get_file('diagr_data.json')
    local data = dkjson.decode(info);
	local table_representation =  { SH = {}, Line3 = {}, Gen = {}}  
	print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	if ( data.type == 'makeSuperDiagr2') then --  tas bija vecais variants, visus zīmē vienādi
		--for k,el in pairs(data.supClasses) do
		--	--if ( el.count > 1 ) then
		--	local tt = el.type
		--	if ( el.count > 1 and tt == 'Class') then
		--		tt = 'Sub'
		--	end
		--	if ( el.count > 1 and tt == 'Classif') then
		--		tt = 'SubCat'
		--	end
		--	table_representation.SH[k] = { compartments = { name = el.id, A1 = el.id2, A4 = el.prop_string, A5 = el.cl_names, Type = tt, A2 = tostring(el.count)}}
		--	for _,p in pairs(el.parent) do	
		--		table_representation.Gen[el.id2..'_'.. p] = { source = p , target = el.id2, compartments = { Val = " "}}
		--	end
		--	--end
		--end
		for k,el in pairs(data.classes) do
			if ( el.used == true ) then
				table_representation.SH[k] = { compartments = { name = el.fullName, Type = el.type}}
				--for _,p in pairs(el.parent) do	
				--	table_representation.Gen[k..'_'.. p] = { source = p , target = k, compartments = { Val = " "}}
				--end
			end
		end
	else
		table_representation.SH['c0'] = { compartments = {  A6 = data.namespaces, Type = 'Data' }}
		for k,el in pairs(data.classes) do
			if ( el.used ) then -- and el.gId ~= ""
				if ( string.len(el.atr_string) > 3000 ) then
					el.atr_string = string.sub(el.atr_string,1,3000) .. "..."
				end
				if ( el.type == 'Data') then
					el.type = 'Class'
				end
				if ( el.type == 'Abstract') then
					table_representation.SH[k] = { compartments = { name = el.fullNameD, A4 = el.atr_string, Type = el.type, A6 = el.atr_string2 }}
				else
					if ( el.sub_classes_clasif_string ~= "" and el.sub_classes_clasif_string ~= nil) then
						table_representation.SH[k] = { compartments = { name = el.fullNameD, A4 = el.atr_string, Type = el.type,  A6 = el.atr_string2 }}
						table_representation.SH[k..'_sub'] = { compartments = { A5 = el.sub_classes_clasif_string, Type = 'SubCat'}}
						table_representation.Gen[k..'_sub_gen'] = { source = k, target = k..'_sub', compartments = { Val = " "}}
					end	
					if ( el.sub_classes_string ~= "" and el.sub_classes_string ~= nil) then
						table_representation.SH[k] = { compartments = { name = el.fullNameD,  A1 = k.."_1", A4 = el.atr_string, Type = el.type,  A6 = el.atr_string2 }}
						table_representation.SH[k..'_sub'] = { compartments = { A5 = el.sub_classes_string, A1 = k.."_3",  Type = 'Sub'}}
						table_representation.Gen[k..'_sub_gen'] = { source = k, target = k..'_sub', compartments = { Val = " "}}	
					end	
					if ( el.sub_classes_group_string ~= "" and el.sub_classes_group_string ~= nil) then
						if ( el.type == 'Class') then
							el.type = 'Sub'
						else
							el.type = 'SubCat'
						end
						table_representation.SH[k] = { compartments = { name = el.fullNameD, A4 = el.atr_string, A6 = el.atr_string2, A5 = el.sub_classes_group_string, Type = el.type }}
					end	
					if ( table_representation.SH[k] == nil) then --if ( el.sub_classes_clasif_string == "" and el.sub_classes_string == "" and el.sub_classes_group_string == "") then
						table_representation.SH[k] = { compartments = { name = el.fullNameD, A4 = el.atr_string, A6 = el.atr_string2, Type = el.type}}
						--table_representation.SH[k] = { compartments = { name = el.fullName, A1 = "data_prop ".. el.data_prop .. "; object prop ".. el.object_prop, A4 = el.atr_string, A5 = el.sub_classes_string }}
					end
				end
				
				for _,s in pairs(el.super_classes) do
					local gen_id = k.."_".. s
					--local gen_box_id = "g_"..s
					--table_representation.SH[gen_box_id] = {}
					table_representation.Gen[gen_id] = { source = s, target = k, compartments = { Val = " "}} -- *
					--table_representation.Gen[gen_id.."2"] = { source = gen_box_id, target = k}
				end
			end
		end
			
		for k,el in pairs(data.assoc) do
			if ( el.removed == false ) then
				if ( string.len(el.string) > 2000 ) then
					el.string = string.sub(el.string,1,2000) .. "..."
				end
				table_representation.Line3[k] = { source = el.from, target = el.to, compartments = { name = k, A = el.string}}
			end
		end
		if ( data.lines ~= nil) then
			for k,el in pairs(data.lines) do
				if ( el.red ~= '5' ) then
					table_representation.Line3[k] = { source = el.from, target = el.to, compartments = { A = el.val, B = el.val2, Red = el.red}}
				end
			end
		end
	
	end	
	--print(dumptable(table_representation))
	--print(dumptable(table_representation.Gen_box))
		
		
	local dd = utilities.active_elements()
	print('*******************')

	
	local target_dgr = dd:find("/target") 
	target_dgr:find("/collection"):link("element", target_dgr:find("/element"))  
	Delete.delete_elements(target_dgr:find("/element"))
	local mappings = core.add_elements_by_table(target_dgr, {}, table_representation, function()end, true)
	print('***********##########################********')
	print(data.schema)
	if ( data.type == 'makeSuperDiagr') then
		core.set_compartment_value(get_compartment(dd, "ID"), "SUM_"..data.schema )
	elseif ( data.type == 'printGroups') then   
		core.set_compartment_value(get_compartment(dd, "ID"), "Groups_"..data.schema )
	elseif ( data.type == 'printDiffs') then   
		core.set_compartment_value(get_compartment(dd, "ID"), "Diffs_"..data.schema )
	else
		if ( get_compartment_value(dd, "ID") == "") then
			core.set_compartment_value(get_compartment(dd, "ID"), data.schema )
		end
	end
	print ("%%%%%%%%%%%%%%%%%%%")

	--core.set_compartment_value(get_compartment(dd, "Schema"), data.schema )
	core.set_compartment_value(get_compartment(dd, "Info"), data.info )
	utilities.update_target_diagram_caption(get_compartment(dd, "ID"))
	utilities.refresh_active_diagram(dd)
end

function GetSVG()
	local dd = utilities.active_elements()
	local diagram = dd:find("/target") 
	local path = tda.GetProjectPath() .. "\\Diagrams\\"..diagram:attr('caption')..".svg"
	local diagram_id = diagram:id()
	local svg_file_folder_path = path
	local svg_picture_folder_path = path
	lua_graphDiagram.ExportDiagramToSVG(diagram_id, svg_file_folder_path, svg_picture_folder_path)
	correct_width_and_height_in_svg(svg_file_folder_path)
end

function correct_width_and_height_in_svg(svg_file_path)
	-- because lua doesn't have a function for replacing a line in a file
	-- we read the file and store lines until we reach the line we want to change.
	-- than we make the change, read the entire rest of the file as one string,
	-- and then write all the previously read lines in order.

	local replace_witdth_height = function(str)
		require("re")
		local width, height = re.match(str, [[' width="100%" height="100%" viewBox="0 0 '{(%d*)}%s{(%d*)}]])
		local replaced_line = string.format(' width="%d" height="%d" viewBox="0 0 %d %d">', width, height, width, height)
		return replaced_line
	end

	local hFile = io.open(svg_file_path, "r") --Reading.
	local lines = {}
	local restOfFile
	local lineCt = 1
	for line in hFile:lines() do
		-- the 6th line should contain the width and height
		if(lineCt == 6) then --Is this the line to modify?
			lines[#lines + 1] = replace_witdth_height(line) --Change old line into new line.
			restOfFile = hFile:read("*a")
			break
		else
			lineCt = lineCt + 1
			lines[#lines + 1] = line
		end
	end
	hFile:close()

	hFile = io.open(svg_file_path, "w") --write the file.
	for i, line in ipairs(lines) do
		hFile:write(line, "\n")
	end
	hFile:write(restOfFile)
	hFile:close()
end

function MakeDiagram() 
	local info = get_file('data.txt')
	print(info)
	local tt = parseCSV(info)
	print(dumptable(tt))
	local table_representation =  { SH = {}, Line3 = {}, Gen = {}}  
	local class_list = {}
	for k,el in pairs(tt) do
		--table_representation.SH[el.id] = { compartments = { name = el.name, A1 = "instances " ..el.cnt, A2 = "data_prop ".. el.data_prop, A3 = "object prop ".. el.obj_prop, A4 = string.gsub(el.aa,"##","\n") , A5 = string.gsub(el.aa2,"##","\n") }}
		--table_representation.SH[el.id] = { compartments = { name = el.name, A1 = "instances " ..el.cnt, A2 = "data_prop ".. el.data_prop, A3 = "object prop ".. el.obj_prop, A4 = string.gsub(el.aa,"##","\n")  }}
		table_representation.SH[el.id] = { compartments = { name = el.name .. " (" .. el.cnt .. ")", A1 = "data_prop ".. el.data_prop .. "; object prop ".. el.obj_prop, A4 = string.gsub(el.aa,"##","\n")  }}
		class_list[el.id] = 0
	end
	info = get_file('data2.txt')
	--print(info)
	local tt = parseCSV(info)
	--print(dumptable(tt))
	
	for k,el in pairs(tt) do
		local nn = el.c1.."_"..el.c2;
		if ( el.type == 'Gen') then
			table_representation.Gen[nn] = { source = el.c1, target = el.c2, compartments = { Val = " "}}
			class_list[el.c1] = 1
			--table_representation.SH[el.c1].compartments.A4 = ""
		end
	end
	--print(dumptable(class_list))
	--print(dumptable(tt))
	for k,el in pairs(tt) do
		local nn = el.c1.."_"..el.c2;
		print(nn)
		if ( el.type == 'Assoc') then
			--if ( class_list[el.c1] + class_list[el.c2] == 0  ) then
				table_representation.Line3[nn] = { source = el.c1, target = el.c2, compartments = { name = nn, A = string.gsub(el.aa,"##","\n")}}
			--end
		end
	end
	--print(dumptable(class_list))
     --print(dumptable(table_representation))
	 print("***********************************")
	 print(string.gsub("aaa##bbb","##","\n"))
	 print("***********************************")

	local dd = utilities.active_elements()
	local target_dgr = dd:find("/target") 
	target_dgr:find("/collection"):link("element", target_dgr:find("/element"))  
	Delete.delete_elements(target_dgr:find("/element"))
	local mappings = core.add_elements_by_table(target_dgr, {}, table_representation, function()end, true)
	local elements = target_dgr:find("/element:has(/elemType[id='SH'])")
end
---------------------------------------------------------------------------------------------

function parseCSV(csvText)
	local result_table = {}
	
	local parse_in_colon_data = re.match(csvText, CSVgrammarColonsData()) or "NOT"
	local colon_table = re.match(parse_in_colon_data["colons"], CSVgrammarRow()) or "NOT"
	
	for i,row in pairs(parse_in_colon_data["data"]) do
		local data_row = re.match(row, CSVgrammarRow()) or "NOT"
		
		local result_row = {}
		result_row["N"] = i
		for j,value in pairs(data_row) do
			result_row[colon_table[j]] = value
		end
		result_table["R"..i] = result_row
	end
	-- print(dumptable(result_table))
	return result_table
end

function CSVgrammarRow()
	
  local grammar = re.compile( [[
	colons <- ({[^;]*} (";" {[^;]*})*) ->{}
	]])
	return grammar
end

function CSVgrammarColonsData()
	
  local grammar = re.compile( [[
    main <- (colons data) -> {}
	colons <- ({:colons:[^%nl]*:} %nl)
	data <- {:data: dataRow:}
	dataRow <-  ({[^%nl]*} %nl)* -> {}
	]])
	return grammar
end



---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
function get_compartment_value(element, comp_name)
  if element then
    return get_compartment(element, comp_name):attr("value") or ""
  end	
end

function get_compartment(element, comp_name)
  return element:find("/compartment:has(/compartType[id='"..comp_name.."'])")
end

function get_file(fn)
  local file = ""
  if fn ~= "" then
	file = tda.GetProjectPath() .. "\\" .. fn
  else
	file = tda.GetProjectPath() .. "\\data.txt"
  end

  local info = ""
  local f = io.open(file, "r")
  if f then 
   info = f:read("*all")
   f:close()
  end
 
  return info
end

function split_string_with_delimiter(compart_text, del)  --  lai atrastu vai tur ieksa substring string.find, ar get compartment tiek lidz atributam
  compart_text = compart_text or ""							---- 
  ii = 0
  local list_of_text = {}
  for text in compart_text:gmatch("([^"..del.."]+)") do 
  	ii = ii + 1  
	table.insert(list_of_text, text)
  end
  return list_of_text, ii
end

function split_string(compart_text)
  compart_text = compart_text or ""
  local list_of_text = {}
  for text in compart_text:gmatch("([^\n]+)") do 
    if text ~= "" and string.sub(text,1,1) ~= "#" and string.gsub(text," ","") ~= "" then
		table.insert(list_of_text, text)
	end
  end
  return list_of_text
end
----------------------------------------------------------------------------------------
function correct_width_and_height_in_svg(svg_file_path)
	-- because lua doesn't have a function for replacing a line in a file
	-- we read the file and store lines until we reach the line we want to change.
	-- than we make the change, read the entire rest of the file as one string,
	-- and then write all the previously read lines in order.

	local replace_witdth_height = function(str)
		require("re")
		local width, height = re.match(str, [[' width="100%" height="100%" viewBox="0 0 '{(%d*)}%s{(%d*)}]])
		local replaced_line = string.format(' width="%d" height="%d" viewBox="0 0 %d %d">', width, height, width, height)
		return replaced_line
	end

	local hFile = io.open(svg_file_path, "r") --Reading.
	local lines = {}
	local restOfFile
	local lineCt = 1
	for line in hFile:lines() do
		-- the 6th line should contain the width and height
		if(lineCt == 6) then --Is this the line to modify?
			lines[#lines + 1] = replace_witdth_height(line) --Change old line into new line.
			restOfFile = hFile:read("*a")
			break
		else
			lineCt = lineCt + 1
			lines[#lines + 1] = line
		end
	end
	hFile:close()

	hFile = io.open(svg_file_path, "w") --write the file.
	for i, line in ipairs(lines) do
		hFile:write(line, "\n")
	end
	hFile:write(restOfFile)
	hFile:close()
end

function save_diagram_as_SVG()
	local diagram = utilities.current_diagram()
	local path = tda.GetProjectPath() .. "\\Ontology\\OpenData.svg"
	local diagram_id = diagram:id()
	local svg_file_folder_path = path
	local svg_picture_folder_path = path
	lua_graphDiagram.ExportDiagramToSVG(diagram_id, svg_file_folder_path, svg_picture_folder_path)
	correct_width_and_height_in_svg(svg_file_folder_path)

end
