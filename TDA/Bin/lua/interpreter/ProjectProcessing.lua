module(..., package.seeall)
require("utilities")
t = require("interpreter.tree")
report = require("reporter.report")
require("project_open_trace")

function project_opened()
	-- project open trace - init metamodel
	project_open_trace.init_project_open_trace_metamodel()

	logging("ProjectOpen")
	local ev = lQuery("Event")
	local str = ev:attr_e("info")
	local tool_type = lQuery("ToolType")
	local project = lQuery("Project")
	local diagram = project:find("/graphDiagram")
	local diagram_type = diagram:find("/graphDiagramType")
	if diagram_type:is_not_empty() then
		utilities.set_diagram_caption(diagram, str, true)
	end
	utilities.open_diagram(diagram)
	if lQuery("FirstCmdPtr"):size() == 0 then
		lQuery.create("FirstCmdPtr")
	end
	tool_type:find("/translet[extensionPoint = 'procOnOpen']"):each(function(translet)
		utilities.execute_translet(translet:attr("procedureName"))
	end)
	project_open_trace.add_project_open_trace_instance()
end

function project_close()
	logging("ProjectClose")
	local ev = lQuery("Event")
	local project = lQuery("Project")
	local proc_on_close = project:attr("procOnClose")
	if proc_on_close ~= "" then
		utilities.execute_translet(proc_on_close)
	end
end

function logging(event_type)
	report.event(event_type, {
		project_name = function() return lQuery("Project/graphDiagram"):attr("caption") end,
		tool_name = function() return lQuery("ToolType"):attr("caption") end,
		build_date = function() return lQuery("Project"):attr("build_date")	end,
		build_number = function() return lQuery("Project"):attr("build_number")	end,
		release_version = function() return lQuery("Project"):attr("release_version")	end,
	})
end
