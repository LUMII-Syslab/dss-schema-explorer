module(..., package.seeall)

require("core")
require("utilities")
require("lQuery")
c = require("configurator.configurator")

function get_compartment_by_id(element, id)
	return element:find("/compartment:has(/compartType[id = '" .. id .. "'])")
end

function add_default_compart_style(id, caption)
	return lQuery.create("CompartStyle", {
				id = id,
				caption = caption,
				nr = 0,
				alignment = 0,
				adjustment = 0,
				picture = "",
				picWidth = 0,
				picHeight = 0,
				picPos = 1,
				picStyle = 0,
				adornment = 0,
				lineWidth = 1,
				lineColor = 0,
				fontTypeFace = "Arial",
				fontCharSet = 1,
				fontColor = 0,
				fontSize = 9,
				fontPitch = 0,
				fontStyle = 0,
				isVisible = 1})
end

function add_default_edge_style(id, caption)
	return lQuery.create("EdgeStyle", {	
		id = id,
		caption = caption,
		shapeCode = 1,
		shapeStyle = 0,
		lineWidth = 1,
		dashLength = 0,
		breakLength = 0,
		bkgColor = 15790320,
		lineColor = 0,
		lineType = 1,
		startShapeCode = 1,
		startLineWidth = 1,
		startDashLength = 0,
		startBreakLength = 0,
		startBkgColor = 15790320,
		startLineColor = 0,
		endShapeCode = 3,
		endLineWidth = 1,
		endDashLength = 0,
		endBreakLength = 0,
		endBkgColor = 15790320,
		endLineColor = 0,
		middleShapeCode = 1,
		middleLineWidth = 1,
		middleDashLength = 0,
		middleBreakLength = 0,
		middleBkgColor = 15790320,
		middleLineColor = 0
	})
end

function add_default_node_style(id, caption)
	return lQuery.create("NodeStyle", {	
		id = id,
		caption = caption,
		shapeCode = 2,
		shapeStyle = 0,
		lineWidth = 2,
		dashLength = 0,
		breakLength = 0,
		alignment = 0,
		bkgColor = 12419151,
		lineColor = 9067831,
		picture = "",
		picWidth = 0,
		picHeight = 0,
		picPos = 1,
		picStyle = 0,
		width = 110,
		height = 45
	})
end

function add_default_port_style(id, caption)
	return lQuery.create("PortStyle", {	
		id = id,
		caption = caption,
		shapeCode = 1,
		shapeStyle = 0,
		lineWidth = 2,
		dashLength = 0,
		breakLength = 0,
		alignment = 0,
		bkgColor = 12419151,
		lineColor = 9067831,
		picture = "",
		picWidth = 0,
		picHeight = 0,
		picPos = 1,
		picStyle = 0,
		width = 20,
		height = 20
	})
end

function add_default_configurator_edge_style(id, caption, list)
	return add_default_edge_style(id, caption):attr(list)
end

function add_default_configurator_node(id, caption, color, lineColor)
	local node_style = add_default_node_style(id, caption)
	if color ~= nil then
		node_style:attr({bkgColor = color})
	end
	if lineColor ~= nil then
		node_style:attr({lineColor = lineColor})
	end
	return node_style
end

function add_default_configurator_port(id, caption, color)
	return add_default_port_style(id, caption):attr({
		bkgColor = color
	})
end

function get_elem_type_from_compartment(compart_type)
	local elem_type = compart_type:find("/elemType")
	if elem_type:size() > 0 then 
		return elem_type
	else
		return get_elem_type_from_compartment(compart_type:find("/parentCompartType"))
	end
end

function add_compartment(elem, compart_type, compart_style, attr_list)
	return lQuery.create("Compartment", attr_list)
					:link("element", elem)
					:link("compartType", compart_type)
					:link("compartStyle", compart_style)
end

function add_default_graph_diagram_style(diagram_type)
	return lQuery.create("GraphDiagramStyle", {
					id = name,
					caption = name,
					layoutMode = 0,
					layoutAlgorithm = 3,
					bkgColor = 16777215,
					screenZoom = 1000,
					printZoom = 1000,
					graphDiagramType = diagram_type
	})
end
