
print('-----***************-----------')

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
 

local diagram = utilities.current_diagram()
print(diagram:attr('caption'))
local path = tda.GetProjectPath() .. "\\Diagrams\\"..diagram:attr('caption')..".svg"
	local diagram_id = diagram:id()
	local svg_file_folder_path = path
	local svg_picture_folder_path = path
	lua_graphDiagram.ExportDiagramToSVG(diagram_id, svg_file_folder_path, svg_picture_folder_path)
	correct_width_and_height_in_svg(svg_file_folder_path)


  --utilities.activate_element(element)
  --prop.Properties()
  
  --lQuery("D#Form"):delete()  -- !!!!!
  --local s = require("spec2")
  --s.create_test()  -- to var tiaki tam dst saukt
  --lQuery("PropertyTab[id='']"):delete()
  
  
