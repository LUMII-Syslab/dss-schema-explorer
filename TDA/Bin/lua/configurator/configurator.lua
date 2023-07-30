module(..., package.seeall)

rep = require("lua_mii_rep")
repo = require("mii_rep_obj")

require("core")
require("utilities")
u = require("configurator.configurator_utilities")
--require("owl_protege_export")
require("lQuery")
cu = require("configurator.const.const_utilities")
d = require("dialog_utilities")
require("re")
copy_paste = require("interpreter.CutCopyPaste")
delta = require("configurator.delta")
report = require("reporter.report")
delete = require("interpreter.Delete")



--Namespace(pizza=<http://www.co-ode.org/ontologies/pizza/pizza.owl#>)
--izsaukums = lua_engine#lua.tda_to_protege.export_ontology

function test()
	local form = d.add_form({id = "configurator_form", caption = "Configurator", minimumWidth = 600, minimumHeight = 500, maximumHeight = 700})
	local row = d.add_row_labeled_field(form, {caption = "Test"}, {id = "test1", text = "cau"}, {id = "row_" .. "babab"}, "D#InputField", {FocusLost = "lua.kaut kas"})
	d.show_form(form)
end

--configurator
function configurator_dialog(elem)
	if elem == nil then
		elem = utilities.active_elements()
	end
	local form, configurator_horizontal_box = configurator_form()
	local tree = add_configurator_tree(configurator_horizontal_box, elem)
	local tab_container = add_configurator_tabs(configurator_horizontal_box, elem)
	d.show_form(form)
end

function configurator_form()
	local form = d.add_form({id = "configurator_form", caption = "Configurator", buttonClickOnClose = "false", minimumWidth = 600, minimumHeight = 500, maximumHeight = 700})
		d.add_event_handlers(form, {Close = "lua.configurator.configurator.close_configurator_form()"})
	local configurator_horizontal_box = d.add_component(form, {id = "configurator_horizontal_box", horizontalAlignment = 1}, "D#HorizontalBox")
return form, configurator_horizontal_box
end

function add_configurator_tree(container, elem)
	local tree_vertical_box = d.add_component(container, {id = "tree_vertical_box", horizontalAlignment = 1}, "D#VerticalBox")
	local tree = d.add_component(tree_vertical_box, {id = "Tree", draggableNodes = "true", minimumWidth = 250, minimumHeight = 200}, "D#Tree")
	d.add_event_handlers(tree, {TreeNodeSelect = "lua.configurator.configurator.tree_node_change", TreeNodeMove = "lua.configurator.configurator.tree_node_move"})
	fill_tree(tree, elem)
	local tree_button_box = d.add_component(tree_vertical_box, {id = "tree_button_box", horizontalAlignment = 0}, "D#HorizontalBox")
	local add_button = d.add_button(tree_button_box, {id = "add_button", caption = "Add"}, {Click = "lua.configurator.configurator.add_tree_node_from_button()"})
	local delete_button = d.add_button(tree_button_box, {id = "delete_button", caption = "Delete", enabled = "false"}, {Click = "lua.configurator.configurator.delete_tree_node_from_button)"})
return tree
end

function add_configurator_tabs(container, elem)
	local tab_vertical_box = d.add_component(container, {id = "tab_vertical_box", horizontalAlignment = 1}, "D#VerticalBox")
	local tab_container = d.add_component(tab_vertical_box, {id = "tab_container"}, "D#TabContainer")
	d.add_event_handlers(tab_container, {TabChange = "lua.configurator.configurator.tab_changed"})	
	local main_tab = d.add_component(tab_container, {id = "main_tab", caption = "Main"}, "D#Tab")
	local transformation_tab = d.add_component(tab_container, {id = "transformation_tab", caption = "Translets"}, "D#Tab")
	local extras_tab = d.add_component(tab_container, {id = "extras_tab", caption = "Extras"}, "D#Tab")
	local object_type = elem:find("/target_type")
	make_main_tab(main_tab, object_type)
	add_configurator_buttons(tab_vertical_box, is_dialog_button_enabled(object_type))
return row
end

function add_configurator_buttons(container, buls)
	local button_box = d.add_component(container, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")
	local dialog_button = d.add_button(button_box, {id = "new_style_button", caption = "Styles"}, {Click = "lua.configurator.configurator.add_new_style()"})
	local dialog_button = d.add_button(button_box, {id = "dialog_button", caption = "Dialog", enabled = buls}, {Click = "lua.configurator.configurator.make_dialog_form()"})
	local style_button = d.add_button(button_box, {id = "style_button", caption = "Symbol"}, {Click = "lua.configurator.configurator.open_style_form()"})
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_configurator_form"})--:link("defaultButtonForm", lQuery("D#Form[id = 'configurator_form']"))
end

function is_dialog_button_enabled(object_type)
	if object_type:find("/propertyDiagram"):size() > 0 then
		return "true"
	else
		return "false"
	end
end

function fill_tree(tree, elem)
	local target_type = elem:find("/target_type")
	local elem_caption = target_type:attr("caption")
	local treeNode = d.add_tree_node(tree, "tree", {id = elem_caption, text = elem_caption, expanded = "true"}):link("type", target_type)
	make_compartType_tree_nodes(treeNode, target_type, "/compartType", "parentNode")
return tree
end

function make_compartType_tree_nodes(treeNode, source_type, path, tree_link)
	if source_type ~= nil then
		source_type:find(path):each(function(obj_type)
			--local start, finish = string.find(obj_type:attr("id"), "ASFictitious")
			--if start == 1 and finish == 12 then
			--	replace_multi_row_links(obj_type, obj_type:find("/subCompartType"))
			--	make_compartType_tree_nodes(treeNode, obj_type, "/subCompartType", "parentNode")
			--else
				local caption = obj_type:attr("id")
				local added_node = d.add_tree_node(treeNode, tree_link, {id = caption, text = caption, expanded = "true"}):link("type", obj_type)
				make_compartType_tree_nodes(added_node, obj_type, "/subCompartType", "parentNode")
			--end
		end)
	end
end

function replace_multi_row_links(source_type, target_type)
	local prop_row = source_type:find("/propertyRow")
	local prop_tab = source_type:find("/propertyTab")
	local prop_dgr = source_type:find("/propertyDiagram")
	source_type:remove_link("propertyRow", prop_row)
			:remove_link("propertyTab", prop_tab)
			:remove_link("propertyDiagram", prop_dgr)
	target_type:link("propertyRow", prop_row)
			:link("propertyTab", prop_tab)
			:link("propertyDiagram", prop_dgr)
end

function add_tree_node_from_button()
	log_button_press({Button = "Add", Context = "CompartType"})
	local tree = d.get_component_by_id("Tree")
	local selected_node = d.get_selected_tree_node()
	local node_name = "NewAttribute"
	local added_node = d.add_tree_node(selected_node, "parentNode", {id = node_name, text = node_name, expanded = "true"})
	add_compartType(added_node, node_name)
	d.execute_command("D#AddTreeNodeCmd", tree, nil, {treeNode = added_node, parent = selected_node})
	d.execute_command("D#SelectTreeNodeCmd", tree, nil, {treeNode = added_node})
end

function delete_tree_node_from_button()	
	log_button_press({Button = "Delete", Context = "CompartType"})
	local tree = d.get_component_by_id("Tree")
	local selected_node = d.get_selected_tree_node()
	delete_treeNode_compartType(selected_node)
	d.execute_command("D#DeleteTreeNodeCmd", tree, "DeleteTreeNode", {treeNode = selected_node})
end

function tree_node_change()
	local delete_button = d.get_component_by_id("delete_button")
	if d.get_selected_tree_node():find("/parentNode"):size() == 0 then
		delete_button:attr({enabled = "false"})
		d.execute_d_command(delete_button, "Refresh")
	else
		delete_button:attr({enabled = "true"})
		d.execute_d_command(delete_button, "Refresh")
	end
	local tab_container = lQuery("D#TabContainer:has([id = 'tab_container'])")
	tab_container:find("/component"):each(function(tab)
		d.delete_container_components(tab)
	end)
	refresh_tab(tab_container:find("/activeTab"))
end

function tree_node_move()
	local ev = lQuery("D#Event")
	local selected_node = ev:find("/treeNode")
	local old_parent = ev:find("/previousParent")
	local old_parent_type = old_parent:find("/type")
	local new_parent = selected_node:find("/parentNode")
	local new_parent_type = new_parent:find("/type")
	if old_parent:id() ~= new_parent:id() or new_parent:is_empty() then
		if new_parent:is_empty() then
			selected_node:remove_link("tree")
		else
			selected_node:remove_link("parentNode", new_parent)
		end
		selected_node:link("parentNode", old_parent)
		utilities.refresh_form_component(d.get_tree_from_tree_node(selected_node))
	end
	d.delete_event(ev)
	relink_compart_types()
	recalculate_compartment_order(old_parent_type)
end

function recalculate_compartment_order(old_parent_type)
	local elem_type = utilities.get_elemType_from_compartType(old_parent_type)
	local compart_types = elem_type:find("/compartType")
	local diagram_list = {}
	elem_type:find("/element"):each(function(elem)
		local diagram = elem:find("/graphDiagram")
		diagram_list[diagram:id()] = diagram
		local list = {}
		elem:find("/compartment"):each(function(compart)
			list[compart:find("/compartType"):id()] = compart
		end)
		elem:remove_link("compartment")
		compart_types:each(function(compart_type)
			elem:link("compartment", list[compart_type:id()])
		end)
		elem:find("/compartment"):each(recalculate_sub_compartment_order)
	end)
	for _, diagram in pairs(diagram_list) do
		utilities.refresh_only_diagram(diagram)
	end
end

function recalculate_sub_compartment_order(compart)
	local compart_type = compart:find("/compartType")
	local sub_compart_types = compart_type:find("/subCompartType")
	if sub_compart_types:is_not_empty() then
		local list = {}
		compart:find("/subCompartment"):each(function(sub_compart)
			list[sub_compart:find("/compartType"):id()] = sub_compart
		end)
		compart:remove_link("subCompartment")
		sub_compart_types:each(function(sub_compart_type)
			compart:link("subCompartment", list[sub_compart_type:id()])
		end)
		compart:find("/subCompartment"):each(recalculate_sub_compartment_order(compart))
	end
end

function get_type_from_tree_node()
	local obj_type = d.get_selected_tree_node():find("/type")
	if obj_type:size() > 0 then 
		return obj_type
	else
		return d.get_component_by_id("Tree"):find("/treeNode/type ElemType")
	end
end

function tab_changed()
	refresh_tab(active_tab())
end

function active_tab()
	return lQuery("D#TabContainer:has([id = 'tab_container'])/activeTab")
end

function refresh_tab(tab)
	print('refresh tab')
	tab:log('id')
	if tab:find("/component"):is_empty() then
		local object_type = get_selected_obj_type()
		--d.delete_container_components(tab)
		local tab_id = tab:attr("id")
		if tab_id == "main_tab" then
			print('main tab')
			make_main_tab(tab, object_type)
		elseif tab_id == "transformation_tab" then
			print('transformation tab')
			make_tranformation_tab(tab, object_type)
		elseif tab_id == "extras_tab" then
			print('extras tab')
			make_extras_tab(tab, object_type)
		end
		--utilities.refresh_form_component(tab)
		--utilities.execute_cmd("D#Command", {info = "Refresh"}):link("receiver", tab)
		utilities.execute_cmd("D#Command", {info = "Refresh", receiver = tab})
		report.event("Tab Changed", {
			ChangedTo = tab_id
		})
	end
end

function get_selected_obj_type()
	return get_selected_type()
end

function make_main_tab(tab, object_type)
	local tmp = object_type:attr("concatStyle")
	if tmp == nil then
		make_elemType_main_tab(tab, object_type)
	else
		make_compartType_main_tab(tab, object_type)
	end
end

--some functions are needed to improve the coding style
function make_elemType_main_tab(tab, object_type)
	local palette_element_type = object_type:find("/paletteElementType")
	local isAbstract_value = "false"
	if object_type:filter(".NodeType"):size() > 0 then
		if palette_element_type:size() == 0 then
			isAbstract_value = "true"
		end
		d.add_row_labeled_field(tab, {caption = "Is Abstract"}, {id = "isAbstract", checked = isAbstract_value}, {id = "row_isAbstract"}, "D#CheckBox", {Change = "lua.configurator.configurator.process_is_abstract"})
	end
	add_input_field_change(tab, "ID", "id", object_type, "lua.configurator.configurator.check_id_field_syntax", "lua.configurator.configurator.update_seed_id")
	local _, field = add_input_field_change(tab, "Caption", "caption", object_type, "lua.configurator.configurator.update_tree_node_from_caption_field", "lua.configurator.configurator.update_seed_caption")
	--d.get_component_by_id("configurator_form"):link("focused", field)
	d.set_component_focused(d.get_form_from_component(tab), field)
	add_input_field_change(tab, "Multiplicity", "multiplicityConstraint", object_type, "lua.configurator.configurator.check_multiplicity_field", "lua.configurator.configurator.update_type_input_field")
	add_checkBox_field(tab, "Properties On Create", "openPropertiesOnElementCreate", object_type)
	if object_type:filter(".NodeType"):size() > 0 then
		add_checkBox_field(tab, "Is Container Mandatory", "isContainerMandatory", object_type)
		local _, combo = add_comboBox_field_function_start_value(tab, "Navigate To Diagram", "id", "false", "lua.configurator.configurator.update_navigate_to_diagram", "lua.configurator.configurator.navigate_to_diagram", navigate_start_value())
		navigate_to_diagram(combo)
		--local palette_group = d.add_component(tab, {id = "palette_group", caption = "Palette Element"}, "D#GroupBox")
		add_input_field_function(tab, "Palette Element Name", "caption", palette_element_type, "lua.configurator.configurator.set_palette_name")
		add_input_field_change(tab, "Palette Element Nr", "nr", palette_element_type, "lua.configurator.configurator.check_field_value", "lua.configurator.configurator.set_palette_nr_box")
		d.add_row_labeled_field(tab, {caption = "Palette Element Image"}, {id = "picture", fileName = get_fileName(), editable = "true", minimumWidth = 50, minimumHeight = 50, maximumWidth = 50, maximumHeight = 50}, {id = "row_picture"}, "D#Image", {Change = "lua.configurator.configurator.set_palette_image_box"})
	elseif object_type:filter(".EdgeType"):size() > 0 then
		add_comboBox_field_change_dropdown(tab, "Direction", "direction", object_type:attr("direction"), "lua.configurator.configurator.update_type_input_field", "lua.configurator.configurator.get_direction_values", object_type)	
		add_input_field_change(tab, "Start Cardinality", "startMultiplicityConstraint", object_type, "lua.configurator.configurator.check_multiplicity_field", "lua.configurator.configurator.update_type_input_field")
		add_input_field_change(tab, "End Cardinality", "endMultiplicityConstraint", object_type, "lua.configurator.configurator.check_multiplicity_field", "lua.configurator.configurator.update_type_input_field")
		add_comboBox_field_change_dropdown(tab, "Palette Element Name", "caption", "true", "lua.configurator.configurator.set_palette_name_line", "lua.configurator.configurator.get_palette_line_elems", palette_element_type)
		add_input_field_change(tab, "Palette Element Nr", "nr", palette_element_type, "lua.configurator.configurator.check_field_value", "lua.configurator.configurator.set_palette_nr_line")
		d.add_row_labeled_field(tab, {caption = "Palette Image"}, {id = "picture", fileName = get_fileName(), editable = "true", minimumWidth = 50, minimumHeight = 50, maximumWidth = 50, maximumHeight = 50}, {id = "row_picture"}, "D#Image", {Change = "lua.configurator.configurator.set_palette_image_line"})
	elseif object_type:filter(".PortType"):size() > 0 then
		add_input_field_function(tab, "Palette Element Name", "caption", palette_element_type, "lua.configurator.configurator.set_palette_name")
		add_input_field_change(tab, "Palette Element Nr", "nr", palette_element_type, "lua.configurator.configurator.check_field_value", "lua.configurator.configurator.set_palette_nr_pin")
		d.add_row_labeled_field(tab, {caption = "Palette Image"}, {id = "picture", fileName = get_fileName(), editable = "true", minimumWidth = 50, minimumHeight = 50, maximumWidth = 50, maximumHeight = 50}, {id = "row_picture"}, "D#Image", {Change = "lua.configurator.configurator.set_palette_image_pin"})
	elseif object_type:filter(".FreeBoxType"):size() > 0 then
		add_comboBox_field_function_start_value(tab, "Navigate To Diagram", "id", "false", "lua.configurator.configurator.update_navigate_to_diagram", "lua.configurator.configurator.navigate_to_diagram", navigate_start_value())
		add_input_field_function(tab, "Palette Element Name", "caption", palette_element_type, "lua.configurator.configurator.set_palette_name")
		add_input_field_change(tab, "Palette Element Nr", "nr", palette_element_type, "lua.configurator.configurator.check_field_value", "lua.configurator.configurator.set_palette_nr_free_box")
		d.add_row_labeled_field(tab, {caption = "Palette Image"}, {id = "picture", fileName = get_fileName(), editable = "true", minimumWidth = 50, minimumHeight = 50, maximumWidth = 50, maximumHeight = 50}, {id = "row_picture"}, "D#Image", {Change = "lua.configurator.configurator.set_palette_image_free_box"})
	elseif object_type:filter(".FreeLineType"):size() > 0 then
		add_input_field_function(tab, "Palette Element Name", "caption", palette_element_type, "lua.configurator.configurator.set_palette_name")
		add_input_field_change(tab, "Palette Element Nr", "nr", palette_element_type, "lua.configurator.configurator.check_field_value", "lua.configurator.configurator.set_palette_nr_free_line")
		d.add_row_labeled_field(tab, {caption = "Palette Image"}, {id = "picture", fileName = get_fileName(), editable = "true", minimumWidth = 50, minimumHeight = 50, maximumWidth = 50, maximumHeight = 50}, {id = "row_picture"}, "D#Image", {Change = "lua.configurator.configurator.set_palette_image_free_line"})
	else
		print("Error in make main tab")
	end
	add_main_popUp_table(tab)	
end

function get_direction_values()
	add_configurator_comboBox({"UniDirectional", "BiDirectional", "ReverseBiDirectional"})
end

function process_both_directional()
	local _, value = get_event_source_attrs("checked")
	local edge = utilities.active_elements()
	local target_type = edge:find("/target_type")
	local start_type = edge:find("/start/target_type")
	local end_type = edge:find("/end/target_type")
	if value == "true" then
		lQuery.create("Pair", {id = "reverse", start = end_type, edgeType = target_type}):link("end", start_type)
	else
		target_type:find("/pair[id = 'reverse']"):delete()
	end
end

function process_back_directional()	
	local _, value = get_event_source_attrs("checked")
	local pair = utilities.active_elements():find("/target_type/pair:not([id = 'reverse'])")
	if value == "false" then
		value = ""
	end
	pair:attr({reverse = value})
end

function get_palette_line_elems()
	local combo_box = get_event_source()
	empty_comboBox(combo_box)
	local palette_type = utilities.active_elements():find("/target_type/paletteElementType/paletteType")
	if palette_type:is_not_empty() then
		add_lQuery_comboBox_items(make_combo_box_item_table(palette_type:find("/paletteElementType:has(/elemType.EdgeType)"), "caption"), combo_box)
	end
end

function make_combo_box_item_table(items, attr_name, item_table)
	if item_table == nil then
		item_table = {}
	end
	items:each(function(item)
		table.insert(item_table, item:attr(attr_name))
	end)
	return item_table
end

function process_is_abstract()
	local attr, value = get_event_source_attrs("checked")
	local obj_type = get_selected_obj_type()
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(obj_type), IsAbstract = value})
	if value == "false" then
		local attr_table = {}
		local palette_element_type = get_palette_element_type()
		local palette_name_field = d.get_component_by_id("caption")
		attr_table["caption"] = palette_name_field:attr_e("text")
		local palette_nr_field = d.get_component_by_id("nr")
		attr_table["nr"] = palette_nr_field:attr_e("text")
		local palette_elem_image = d.get_component_by_id("picture"):attr_e("fileName")
		if palette_elem_name == "" then
			attr_table["caption"] = obj_type:attr_e("caption")
		end
		if attr_table["nr"] == "" then
			attr_table["nr"] = utilities.current_diagram():find("/target_type/paletteType/paletteElementType"):size() + 1
		end
		set_palette_element_type_attribute(palette_element_type, attr_table)
		refresh_palette_nr_and_image(palette_name_field:attr({text = attr_table["caption"]}), palette_nr_field:attr({text = attr_table["nr"]}))
		utilities.set_palette_element_attribute()
	else
		delete_palette_element_type(obj_type:find("/paletteElementType"))
	end	
	utilities.execute_cmd("AfterConfigCmd", {graphDiagram = diagram})
end

function refresh_palette_nr_and_image(nr, image)
	utilities.refresh_form_component(nr)
	utilities.refresh_form_component(image)
end

function get_fileName()
	return utilities.active_elements():find("/target_type/paletteElementType"):attr_e("picture")
end

function make_compartType_main_tab(tab, object_type)
	local property_row = object_type:find("/propertyRow")
	--add_ID_input_field(tab, "ID", "id", object_type)
	add_input_field_change(tab, "ID", "id", object_type, "lua.configurator.configurator.check_id_field_syntax", "lua.configurator.configurator.update_prop_row_id")
	add_input_field_change(tab, "Caption", "caption", object_type, "lua.configurator.configurator.update_tree_node_from_caption_field_compart", "lua.configurator.configurator.update_compart_caption")
	add_checkBox_field_function(tab, "Is Group", "isGroup", object_type, {Change = "lua.configurator.configurator.set_isGroup"})
	local _, combo = add_checkBox_comboBox_field(tab, "Row Type", "rowType", "true", "lua.configurator.configurator.make_property_field", "lua.configurator.configurator.row_type_generator", property_row)
	local _, combo = add_comboBox_field_function(tab, "Tab", "id", "true", "lua.configurator.configurator.set_row_tab", "lua.configurator.configurator.row_tab_generator", property_row:find("/propertyTab"))
	add_input_field(tab, "Default Value", "startValue", object_type)
	add_multi_field(tab, "Prefix", "adornmentPrefix", object_type)
	add_multi_field(tab, "Suffix", "adornmentSuffix", object_type)
	--local concat_type = object_type:find("/parentCompartType[id ^= 'ASFictitious']")
	--if concat_type:is_empty() then
	--	concat_type = object_type
	--end
	add_multi_field(tab, "Delimiter", "concatStyle", object_type, {FocusLost = "lua.configurator.configurator.update_concat_style"})
	add_multi_field(tab, "Pattern", "pattern", object_type)
	--add_checkBox_field(tab, "Is Essential", "isEssential", object_type)
end

function update_prop_row_id()
	local compart_type = get_selected_obj_type()
	compart_type:find("/propertyRow"):attr({id = compart_type:attr("id")})
end

function set_elem_style_id()
	local attr, value = get_event_source_attrs("text")
	local target_type = get_selected_obj_type()
	local target_type_id = target_type:attr("id")
	local style
	if target_type:filter(".CompartType"):is_not_empty() then
		style = target_type:find("/compartStyle[id = " .. target_type_id .. "]:first()")
	else
		style = target_type:find("/elemStyle[id = " .. target_type_id .. "]:first()")
	end
	if style:is_not_empty() then
		style:attr({id = value})
	end
end

function set_isGroup()
	local attr, value = get_event_source_attrs("checked")
	local compart_type = get_selected_obj_type()
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(compart_type), [attr] = value})
	set_isGroup_for_compart_types(compart_type, value)
end

function set_isGroup_for_compart_types(compart_type, value)
	if compart_type:is_not_empty() then
		compart_type:attr({isGroup = value})
		local compart_styles = compart_type:find("/compartStyle")
		local compartments = compart_type:find("/compartment")
		if value ~= "true" then
			if compart_styles:is_not_empty() then
				compart_styles:find(":first()"):link("compartment", compartments)
			else
				local compart_type_id = compart_type:attr("id")
				cu.add_default_compart_style(compart_type_id, compart_type_id)():link("compartType", compart_type)
												:link("compartment", compartments)
			end
			set_isGroup_for_compart_types(compart_type:find("/subCompartType"), value)
		else
			compart_styles:remove_link("compartment", compartments)
			set_isGroup_for_compart_types(compart_type:find("/parentCompartType"), value)

		end
	end
end

function set_should_be_included()
	local attr, value = get_event_source_attrs("text")
	local prop_row = get_selected_obj_type():find("/propertyRow"):attr({[attr] = value})
end

function set_should_be_included_for_tab()
	local attr, value = get_event_source_attrs("text")
	local prop_row = get_selected_obj_type():find("/propertyRow/propertyTab"):attr({[attr] = value})
end

function update_concat_style()
	local attr, value = get_event_source_attrs("text")
	local obj_type = get_selected_obj_type()
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(obj_type), [attr] = value})
	--local parent_type = obj_type:find("/parentCompartType[id ^= 'ASFictitious']")
	--if parent_type:is_not_empty() then
	--	parent_type:attr(attr, value)
	--else
	obj_type:attr({[attr] = value})
	--end
end

function make_tranformation_tab(tab, object_type)
	if object_type:filter(".CompartType"):size() > 0 then
		make_compartType_transformation_tab(tab, object_type)
	else
		make_elemTye_transformation_tab(tab, object_type)
	end
end

function make_extras_tab(tab, object_type)
	d.delete_container_components(tab)
	if object_type:find(".CompartType"):size() > 0 then
		compartment_style(tab, object_type)
	else	
		add_element_key_shortcuts(tab)
		if object_type:find(".NodeType"):size() > 0 then
			add_contain_table(tab)
		end
	end
end

function update_property_element_name()
	local ev = lQuery("D#Event")
	local prop_tree = d.get_component_by_id("property_tree")
	local selected_node = prop_tree:find("/selected")
	local prop_elem = selected_node:find("/propertyElement")
	local attr, val = get_event_source_attrs("text")
	prop_elem:attr({id = val})
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(prop_elem), id = val})
	d.delete_event(ev)
end

function refresh_property_element_tree_node()
	local ev = lQuery("D#Event")
	local prop_tree = d.get_component_by_id("property_tree")
	local selected_node = prop_tree:find("/selected")
	local attr, val = get_event_source_attrs("text")
	selected_node:attr({text = val})
	utilities.refresh_form_component(prop_tree)
	d.delete_event(ev)
end

function update_property_element_size()
	local ev = lQuery("D#Event")
	local prop_tree = d.get_component_by_id("property_tree")
	local selected_node = prop_tree:find("/selected")
	local prop_elem = selected_node:find("/propertyElement")
	local attr, value = get_event_source_attrs("text")
	prop_elem:attr({[attr] = value})
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(prop_elem), [attr] = value})
	d.delete_event(ev)
end

function make_elemTye_transformation_tab(tab, object_type)
	local element_group_box = d.add_component(tab, {id = "group_box", caption = "Element"}, "D#GroupBox")
		add_transformation_field(element_group_box, "L2Click", "l2ClickEvent", object_type)
		add_transformation_field(element_group_box, "Properties", "procProperties", object_type)
		add_transformation_field(element_group_box, "Dynamic Context Menu", "procDynamicPopUp", object_type)
		add_transformation_field(element_group_box, "Dynamic Tooltip", "procDynamicTooltip", object_type)
		add_transformation_field(element_group_box, "Pre Condition", "procPreCondition", object_type)
		add_transformation_field(element_group_box, "New Element", "procNewElement", object_type)
		--add_transformation_field(element_group_box, "Element Entered", "procElementEntered", object_type)
	local domain_group_box = d.add_component(tab, {id = "domain_group_box", caption = "Domain"}, "D#GroupBox")
		add_transformation_field(domain_group_box, "Create Domain", "procCreateElementDomain", object_type)
		add_transformation_field(domain_group_box, "Delete Element", "procDeleteElement", object_type)
		add_transformation_field(domain_group_box, "Delete Domain", "procDeleteElementDomain", object_type)
		add_transformation_field(domain_group_box, "Copy Element", "procCopyElement", object_type)
		add_transformation_field(domain_group_box, "Copy Domain", "procCopied", object_type)
		--add_transformation_field(domain_group_box, "Paste Domain", "procPasted", object_type)
		
	--add_transformation_field(tab, "Get Definition", "procGetDefinition", object_type)
	--add_transformation_field(tab, "Insert Definition Into Scope", "procInsertDefinitionIntoScope", object_type)
--type specific fields
	if object_type:filter(".NodeType"):size() > 0 then
		add_transformation_field(element_group_box, "Container Changed", "procContainerChanged", object_type)
	elseif object_type:filter(".EdgeType"):size() > 0 then
		add_transformation_field(element_group_box, "Move Line", "procMoveLine", object_type)
	elseif object_type:filter(".PortType"):size() > 0 then
		--currently nothing
	end
	d.add_component(tab, {id = "empty_box"}, "D#HorizontalBox")
end

function make_compartType_transformation_tab(tab, object_type)
	local group_box = d.add_component(tab, {id = "group_box", caption = "Dialog"}, "D#GroupBox")
		add_transformation_field(group_box, "Start Value Generate", "procGenerateInputValue", object_type)
		add_transformation_field(group_box, "Blocking Field Entered", "procBlockingFieldEntered", object_type)
		add_transformation_field(group_box, "Forced Values Field Entered", "procForcedValuesEntered", object_type)
		add_transformation_field(group_box, "Check Compartment Field Entered", "procCheckCompartmentFieldEntered", object_type)
		add_transformation_field(group_box, "Generate Items ClickBox", "procGenerateItemsClickBox", object_type)
		add_transformation_field(group_box, "Field Entered", "procFieldEntered", object_type)
	group_box = d.add_component(tab, {id = "compartment_group_box", caption = "Attribute"}, "D#GroupBox")
		add_transformation_field(group_box, "Compose", "procCompose", object_type)
		add_transformation_field(group_box, "Decompose", "procDecompose", object_type)
		add_transformation_field(group_box, "Get Prefix", "procGetPrefix", object_type)
		add_transformation_field(group_box, "Get Suffix", "procGetSuffix", object_type)
		add_transformation_field(group_box, "Get Pattern", "procGetPattern", object_type)
		add_transformation_field(group_box, "Is Hidden", "procIsHidden", object_type)
	group_box = d.add_component(tab, {id = "domain_group_box", caption = "Domain"}, "D#GroupBox")
		add_transformation_field(group_box, "Create Domain", "procCreateCompartmentDomain", object_type)
		add_transformation_field(group_box, "Update Domain", "procUpdateCompartmentDomain", object_type)
		add_transformation_field(group_box, "Delete Domain", "procDeleteCompartmentDomain", object_type)
	d.add_component(tab, {id = "empty_box"}, "D#HorizontalBox")
end

function update_ID_field()
	update_elem_type_ID()
	update_form_field("text")
end

function update_type_ID_input_field()
	update_compart_type_ID()
	update_form_field("text")
end

function elem_type_versioning(elem_type)
	obj_type_versioning(elem_type, "CompartTypes")
end

function diagram_type_versioning(diagram_type)
	obj_type_versioning(diagram_type, "ElemTypes")
end

function compart_type_versioning(compart_type)
	if compart_type:find("/elemType"):is_not_empty() then
		obj_type_versioning(compart_type, "CompartTypes")
	else
		obj_type_versioning(compart_type, "SubCompartTypes")
	end
end

function obj_type_versioning(obj_type, child_types)
	local obj_type_id = obj_type:attr("id")
	local definition, new_name = address_list_from_obj_type(obj_type, obj_type_id)
	local str = string.format("%s%s = {%s = {}, Status = 'New'}\n", definition, new_name, child_types)
	utilities.append_to_session_file(str)
end

function address_list_from_obj_type(obj_type, id)
	local res = ""
	local list = {}
	list_of_all_steps(list, obj_type, id)
	return table.concat(list), list[#list - 1]
end

function list_of_all_steps(list, obj_type, id)
	if obj_type:filter(".GraphDiagramType"):is_not_empty() then
		local step = make_one_step(obj_type, id)
		table.insert(list, "List = List or {}\n")
		table.insert(list, string.format("List%s", step))
		table.insert(list, string.format(' = List%s or {}\n', step))
	elseif obj_type:filter(".ElemType"):is_not_empty() then
		list_of_all_steps(list, obj_type:find("/graphDiagramType"))
		local index = list[#list - 1]
		local step = make_one_step(obj_type, id)
		table.insert(list, string.format("%s['ElemTypes'] = %s['ElemTypes'] or {}\n", index, index))
		table.insert(list, string.format("%s['ElemTypes']%s", index, step))	
		table.insert(list, string.format(" = %s['ElemTypes']%s or {}\n", index, step))
	elseif obj_type:filter(".CompartType"):is_not_empty() then
		local parent_type = obj_type:find("/elemType")
		local child_type = "CompartTypes"
		if parent_type:is_empty() then
			parent_type = obj_type:find("/parentCompartType")
			child_type = "SubCompartTypes"
		end
		list_of_all_steps(list, parent_type)
		local index = list[#list - 1]
		local step = make_one_step(obj_type, id)
		table.insert(list, string.format("%s['%s'] = %s['%s'] or {}\n", index, child_type, index, child_type))
		table.insert(list, string.format("%s['%s']%s", index, child_type, step))	
		table.insert(list, string.format(" = %s['%s']%s or {}\n", index, child_type, step, index, child_type, step))
	end
end

function make_one_step(obj_type, id)
	if id == nil then	
		id = obj_type:attr("id")
	end
	return string.format("['%s']", id)
end

function update_elem_type_ID()
	local elem_type = get_selected_obj_type()
	local elem_type_id = elem_type:attr("id")
	local _, new_elem_type_id = get_event_source_attrs("text")
	if elem_type_id ~= new_elem_type_id then
		local diagram_type = elem_type:find("/graphDiagramType")
		local diagram_type_id = diagram_type:attr("id")
		local _, old_name = address_list_from_obj_type(elem_type, elem_type_id)
		local new_definition, new_name = address_list_from_obj_type(elem_type, new_elem_type_id)
		local str = string.format("%s%s = %s\n%s = nil\n",  new_definition, new_name, old_name, old_name)
		utilities.append_to_session_file(str)
	end
end

function update_diagram_type_ID(diagram_type)
	local diagram_type_id = diagram_type:attr("id")
	local _, new_elem_type_id = get_event_source_attrs("text")
	if diagram_type_id ~= new_elem_type_id then
		local _, old_name = address_list_from_obj_type(diagram_type, diagram_type_id)
		local new_definition, new_name = address_list_from_obj_type(diagram_type, new_elem_type_id)
		local str = string.format("%s%s = %s\n%s = nil\n", new_definition, new_name, old_name, old_name)
		utilities.append_to_session_file(str)
	end
end

function update_compart_type_ID()
	local compart_type = get_selected_obj_type()
	local compart_type_id = compart_type:attr("id")
	local _, new_compart_type_id = get_event_source_attrs("text")
	if new_elem_type_id ~= new_compart_type_id then
		local _, old_name = address_list_from_obj_type(compart_type, compart_type_id)
		local new_definition, new_name = address_list_from_obj_type(compart_type, new_compart_type_id)
		local str = string.format("%s%s = %s\n%s = nil\n", new_definition, new_name, old_name, old_name)
		utilities.append_to_session_file(str)
	end
end

function versioning()
	new_version_form()
end

function new_version_form()
	log_button_press("Versioning")
	local form = d.add_form({id = "new_version_form", caption = "Versioning", minimumWidth = 400})	
	local tab_container = d.add_component(form, {id = "versioning_tab_container"}, "D#TabContainer")
	d.add_event_handlers(tab_container, {TabChange = "lua.configurator.configurator.tab_changed"})	

	local tab1 = d.add_component(tab_container, {id = "Tab1", caption = "Versions"}, "D#Tab")
		local form_horizontal_box = d.add_component(tab1, {id = "form_horizontal_box", horizontalAlignment = 1}, "D#HorizontalBox")
		--add_input_field_event_function(form_horizontal_box, "New Vesion", "version", project, {FocusLost = "lua.configurator.configurator.update_from_project_version_field"})
		local project = lQuery("Project")	
		add_input_field_event_function(tab1, "Current Version", "version", project, {})
		d.add_row_labeled_field(tab1, {caption = "New Version"}, {id = "new_version", text = make_new_version_value()}, {id = "row_version"}, "D#InputField", {Change = "lua.configurator.configurator.check_unique_version"})

	local tab2 = d.add_component(tab_container, {id = "Tab2", caption = "Migration"}, "D#Tab")
		local label_caption = tda.GetProjectPath() .. "\\Migration\\"
		local check_box = d.add_row_labeled_field(tab2, {caption = "Automatic Migration"}, {id = "migration_mode", checked = "true"}, {id = "row_migration_mode"}, "D#CheckBox", {Change = "lua.configurator.configurator.switch_migration_modes"})
		local label = d.add_component(tab2, {caption = label_caption, id = "label_field",}, "D#Label")
		local field_id = "execute_script_field1"
		d.add_row_labeled_field(tab2, {caption = "Script"}, {id = field_id, text = ""}, {id = "row_" .. field_id}, "D#ComboBox", {DropDown = "lua.configurator.configurator.get_migration_file_list"})

	local button_box = d.add_component(form, {id = "dialog_button_box", horizontalAlignment = 1}, "D#HorizontalBox")
		local cancel_button = d.add_button(button_box, {id = "dialog_close_button", caption = "Cancel"}, {Click = "lua.dialog_utilities.close_form"})
													:link("defaultButtonForm", lQuery("D#Form[id = 'new_version_form']"))
		local ok_button = d.add_button(button_box, {id = "dialog_close_button", caption = "OK"}, {Click = "lua.configurator.configurator.close_versioning()"})										
	d.delete_event()
	d.show_form(form)
end

function check_unique_version()
	local file_name_list = get_list_of_version_names(get_migration_files())
	local entered_new_version_field = d.get_component_by_id("new_version")
	if file_name_list[entered_new_version_field:attr("text")] then
		d.set_error_field(entered_new_version_field, "Enter unique version!", true)
	else
		d.set_field_ok(entered_new_version_field, true)
	end
end

function make_new_version_value()
	local version = "nextVersion"
	local file_name_list = get_list_of_version_names(get_migration_files())
	for i = 1,math.huge do
		if not(file_name_list[version]) then
			return version
		end
		version = version .. i
	end
end

function get_list_of_version_names(file_list)
	local file_name_list = {}
	for _, file_name in ipairs(file_list) do
		local start_version_name = get_start_version(file_name)
		file_name_list[start_version_name] = true
	end
	file_name_list[lQuery("Project"):attr("version")] = true
	return file_name_list
end


--function tab_changed()
	--do nothing, otherwise dialog engine does not change activeTab link
--end

function switch_migration_modes()
	local check_box_val = d.get_component_by_id("migration_mode"):attr("checked")
	local combo_box = d.get_component_by_id("execute_script_field1")
	if check_box_val == "true" then
		--disable
		combo_box:attr({enabled = "false", editable = "false"})
	else
		--enable
		combo_box:attr({enabled = "true", editable = "true"})
	end
end

function get_migration_file_list()
	local luafiles = get_migration_files()
	local combo_box = d.get_component_by_id("execute_script_field1")
	d.clear_list_box(combo_box)
	add_configurator_comboBox(luafiles, combo_box)
end

function get_migration_files()
	local file_name = "_tmp"
	local path = tda.GetProjectPath() .. "\\Migration"
	local dircmd = "cd " .. path .." && dir /b/s > " .. file_name
	os.execute(dircmd)
	local luafiles = {}
	local path_to_file = path .. "\\" .. file_name
	for f in io.lines(path_to_file) do
	    if f:sub(-4) == ".lua" then
	        luafiles[#luafiles+1] = utilities.get_last_item_from_path(f)
	    end
	end
	os.execute("del " .. path_to_file)
	return luafiles
end

function automatic_migration()
	local file_list = get_migration_files()
	local indexed_file_list = {}
	for _, file_name in ipairs(file_list) do
		local start_version = get_start_version(file_name)
		indexed_file_list[start_version] = file_name
	end
	local project = lQuery("Project")
	for i = 1, #file_list do
		local version = project:attr("version")
		if indexed_file_list[version] == nil then
			break
		end
		execute_migration_file(indexed_file_list[version])
    end
end

function get_start_version(file_name)
	local start = string.find(file_name, "_to_")
	if start == nil then
		error("Migration file naming error")
	end
	return string.sub(file_name, 1, start-1)
end

function execute_migration_file(file_name)
	local path_to_file = tda.GetProjectPath() .. "\\Migration\\" .. file_name
	dofile(path_to_file)
end

function close_versioning()
	local tab_container = d.get_component_by_id("versioning_tab_container")
	local active_tab = tab_container:find("/activeTab")
	if active_tab:attr("id") == "Tab1" then
		close_new_version_form()
	elseif active_tab:attr("id") == "Tab2" then
		local check_box_val = d.get_component_by_id("migration_mode"):attr("checked")
		if check_box_val == "true" then
			automatic_migration()
		else
			local text_field = d.get_component_by_id("execute_script_field1")
			execute_migration_file(text_field:attr("text"))
		end
		utilities.close_form("new_version_form")
	else
		error("Error in close versioning")
	end
end

function close_new_version_form()
	log_button_press("Close")
	update_from_project_version_field()
	local project = lQuery("Project")
	local tag_ = utilities.get_tags(project, "isFirstVersion")
	local is_new_version_file_needed = true
	if tag_:is_not_empty() then
		is_new_version_file_needed = false
		tag_:delete()
	end
	make_new_version_file(is_new_version_file_needed)
	utilities.clear_session_file()
	utilities.close_form("new_version_form")
	rep.Save()
end

function update_from_project_version_field()
	local project = lQuery("Project")
	local old_version = project:attr("version")
	local value = d.get_component_by_id("new_version"):attr("text")
	project:attr({version = value})
	utilities.get_tags(project, "OldVersion"):delete()
	utilities.add_tag(project, "OldVersion", old_version, true)
end

function make_new_version_file(is_new_version_file_needed)
	local List = {}
	local list_of_configurator_diagram_types = {specificationDgr = true, Repository = true, MMInstances = true}
	lQuery("GraphDiagramType"):each(function(diagram_type)
		local diagram_type_id = diagram_type:attr("id")
		if list_of_configurator_diagram_types[diagram_type_id] ~= true then
			List[diagram_type_id] = {Status = "Updated", ElemTypes = {}, OldName = diagram_type_id}
			diagram_type:find("/elemType"):each(function(elem_type)
				local elem_type_id = elem_type:attr("id")
				List[diagram_type:attr("id")]["ElemTypes"][elem_type_id] = {Status = "Updated", CompartTypes = {}, OldName = elem_type_id}
				elem_type:find("/compartType"):each(function(compart_type)
					local compart_type_id = compart_type:attr("id")
					List[diagram_type:attr("id")]["ElemTypes"][elem_type_id]["CompartTypes"][compart_type_id] = {Status = "Updated", SubCompartTypes = {}, OldName = compart_type_id}
					make_subcompartments_in_new_version_file(compart_type, List[diagram_type:attr("id")]["ElemTypes"][elem_type_id]["CompartTypes"][compart_type_id]['SubCompartTypes'])
				end)
			end)
		end
	end)
	local tmp_version_content = ""
	local file = utilities.open_tmp_version_file("r")
	if file ~= nil then
		tmp_version_content = file:read("*a")
		io.close(file)
	end
	local session_file_content = ""
	file = utilities.open_session_file("r")
	session_file_content = file:read("*a")
	io.close(file)
	local old_version, new_version = get_project_old_and_new_versions()
	local file = utilities.open_file_from_current_project(string.format("\\migration\\%s_to_%s.lua", old_version, new_version), "w")
	assert(file, "Failed to create migration file")
	if is_new_version_file_needed then
		file:write('migration = require("interpreter.Migration")\nmigration.add_tag()\nlocal target_type_list = migration.delete_configurator_types()\n', delta.dump_configurator(), tmp_version_content, session_file_content, 'migration.process_version_list(List)\nmigration.delete_target_types(target_type_list)\n')
	else
		file:write('--first migration\n')
	end
	file:write(string.format('lQuery("Project"):attr("version", "%s")', new_version))
	io.close()
	file = utilities.open_file_from_current_project("\\tmp_version.lua", "w")
		file:write("List = " .. dumptable(List) .. "\n")
	io.close(file)
end

function make_subcompartments_in_new_version_file(compart_type, list)
	compart_type:find("/subCompartType"):each(function(sub_compart_type)	
		local sub_compart_type_id = sub_compart_type:attr("id")
		list[sub_compart_type_id] = {Status = "Updated", SubCompartTypes = {}, OldName = sub_compart_type_id}
		make_subcompartments_in_new_version_file(sub_compart_type, list[sub_compart_type_id]['SubCompartTypes'])
	end)
end

function get_project_old_and_new_versions()
	local project = lQuery("Project")
	local new_version = project:attr("version")
	local old_version = utilities.get_tags(project, "OldVersion"):attr("value")
	return old_version, new_version
end

function make_path_from_compart_type_to_elem_type(compart_type, str)
	local parent_type = compart_type:find("/elemType")
	local compart_type_id = compart_type:attr("id")
	if parent_type:is_not_empty() then
		return ':find("/compartType[id = ' .. compart_type_id  .. ']"' .. str .. ")\n\t"
	else
		local tmp_str = '/subCompartType[id = ' .. compart_type_id .. ']' .. str
		return make_path_from_compart_type_to_elem_type(compart_type:find("/parentCompartType"), tmp_str)
	end
end

function make_path_from_diagram_type(diagram_type)
	return 'lQuery("GraphDiagramType[id = ' .. diagram_type:attr("id") .. ']"):filter(":not([isNew = true])"):log("id")\n\t'
end

function make_path_from_elem_type(elem_type)
	return ':find("/elemType[id = ' .. elem_type:attr("id") .. ']"):log("id")\n\t'
end

function make_path_from_compart_type(compart_type)
	if compart_type:find("/elemType"):is_not_empty() then
		return ':find("/compartType[id = ' .. compart_type:attr("id") .. ']"):log("id")\n\t'
	else
		return ':find("/subCompartType[id = ' .. compart_type:attr("id") .. ']"):log("id")\n\t'
	end
end

function set_new_attr_value()
	local attr, value = get_event_source_attrs("text")
	return ':attr({id = "' .. value .. '"}):log("id")\n'
end

function update_transformation_field()
	local attr, value = get_event_source_attrs("text")
	local obj_type = get_selected_obj_type()
	cu.add_translet_to_obj_type(obj_type, attr, value)
	--local translet = obj_type:find("/translet[extensionPoint = " .. attr .. "]")
	
	report.event("Translet " .. attr, {
		ObjectType = utilities.get_class_name(obj_type),
		[attr] = value
	})
	--:attr({procedureName = value})
end

function update_type_input_field()
	update_form_field("text")
end

function update_check_box_field()
	update_form_field("checked")
end

function update_form_field(attr_name)
	local attr, value = get_event_source_attrs(attr_name)
	local obj_type = get_selected_obj_type()
	obj_type:attr(attr, value)
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(obj_type), [attr] = value})
end

function update_tree_node_from_caption_field()
	local attr, value = get_event_source_attrs("text")
	local tree_node = d.get_selected_tree_node()
	tree_node:find("/type"):attr({caption = value})
	tree_node:find("/target"):attr({caption = value})
	tree_node:attr({text = value, id = value})
	local parent_tree = tree_node:find("/parentTree")
	d.execute_d_command(parent_tree, "Refresh")
	local is_abstract = d.get_component_by_id("isAbstract")
	if is_abstract:attr("chekced") ~= "true" then
		local palette_name_component = lQuery("D#Component[id = 'row_caption']:has(/component[id = 'label_box']/component[caption = 'Palette Element Name'])/component[id = 'field_box']/component")
		--local id_field = lQuery("D#Component[id = 'row_id']:has(/component[id = 'label_box']/component[caption = 'ID'])/component[id = 'field_box']/component")
		--refresh_component_from_caption(id_field, value)
		refresh_component_from_caption(palette_name_component, value)
	end
end

function refresh_component_from_caption(component, value)
--vajag vel sataisit, lai ari dzesana ari tiktu nemta vera
	if component:attr("text") == string.sub(value, 1, -2) then
		component:attr({text = value})
		d.execute_d_command(component, "Refresh")
	end
end

function update_tree_node_from_caption_field_compart()
	local attr, value = get_event_source_attrs("text")
	local tree_node = d.get_selected_tree_node()
	tree_node:attr({text = value, id = value})
	local parent_tree = tree_node:find("/parentTree")
	d.execute_d_command(parent_tree, "Refresh")
	--local id_field = lQuery("D#Component[id = 'row_id']:has(/component[id = 'label_box']/component[caption = 'ID'])/component[id = 'field_box']/component")
	--refresh_component_from_caption(id_field, value)
end

function update_seed_caption()
	local attr, value = get_event_source_attrs("text")
	update_target_diagram_type(attr, value)
	local active_elem = utilities.active_elements()
	get_name_compart(active_elem):attr({input = value, value = value})
	local target_diagram = active_elem:find("/child")
	if target_diagram:is_empty() then
		target_diagram = active_elem:find("/target")
	end
	if target_diagram:is_not_empty() then
		target_diagram:attr({caption = value})
		utilities.execute_cmd("AfterConfigCmd", {graphDiagram = active_elem:find("/graphDiagram/target_type"):find("/graphDiagram")})
	end
end

function update_seed_id()
	local attr, value = get_event_source_attrs("text")
	update_target_diagram_type(attr, value)
end
 
function update_target_diagram_type(attr, value)
	local active_elem = utilities.active_elements()
	local target_type = active_elem:find("/target_type")
	local target_type_id = target_type:attr("id")
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(target_type), [attr] = value})
	target_type:attr({[attr] = value})--:find("/paletteElement"):attr({id = value, caption = value})
	target_type:find("/propertyDiagram"):attr({[attr] = target_type:attr(attr)})
	local target_diagram_type = target_type:find("/target")
	if target_diagram_type:is_not_empty() then
		if attr == "id" then
			update_diagram_type_ID(target_diagram_type)
		end
		target_diagram_type:attr({[attr] = value})
	end
end

function get_name_compart(elem)
	return elem:find("/compartment:has(/compartType[id = 'AS#Name'])")
end

function get_attribute_compart(elem)
	return elem:find("/compartment:has(/compartType[id = 'AS#Attributes'])")
end

function update_compart_caption()
	local attr, value = get_event_source_attrs("text")
	--local id_field_value = lQuery("D#Component[id = 'row_id']:has(/component[id = 'label_box']/component[caption = 'ID'])/component[id = 'field_box']/component"):attr("text")
	local compart_type = get_selected_obj_type()
	--local compart_id = compart_type:attr_e("id")
	--local compart_style = compart_type:find("/compartStyle:has([id = '" .. compart_id .. "'])"):log()
	local compart_style = compart_type:find("/compartStyle")
	compart_type:find("/propertyRow"):attr({caption = value})
	compart_type:attr({caption = value})
	compart_style:attr({caption = value})
end

function navigate_start_value()
	return utilities.active_elements():find("/target_type/target"):attr_e("id")
end

function get_event_source()
	local ev = lQuery("D#Event")
	local source = ev:find("/source")
	return source, ev
end

function delete_event()
	lQuery("D#Event"):delete()
end

function get_event_source_attrs(attr_name)
	return d.get_event_source_attrs(attr_name)
end

function add_transformation_field(container, label, field_id, object_type)
	local translet_name = object_type:find("/translet[extensionPoint = " .. field_id .. "]"):attr_e("procedureName")
	local row = d.add_row_labeled_field(container, {caption = label}, {id = field_id, text = translet_name}, {id = "row_" .. field_id}, "D#InputField", {FocusLost = "lua.configurator.configurator.update_transformation_field"})
	local button = d.add_button(row, {id = field_id .. "_button", caption = "..."}, {Click = "lua.configurator.configurator.add_specific_transformation()"})
end

function add_transformation_field_with_events(container, label, field_id, object_type, event_table)
	local translet_name = object_type:find("/translet[extensionPoint = " .. field_id .. "]"):attr_e("procedureName")
	local row = d.add_row_labeled_field(container, {caption = label}, {id = field_id, text = translet_name}, {id = "row_" .. field_id}, "D#InputField", event_table)
	local button = d.add_button(row, {id = field_id .. "_button", caption = "..."}, {Click = "lua.configurator.configurator.add_specific_transformation()"})
end

function add_input_field(container, label, field_id, object_type)
	add_input_field_function(container, label, field_id, object_type, "lua.configurator.configurator.update_type_input_field")
end

function add_ID_input_field(container, label, field_id, object_type)
	add_input_field_function(container, label, field_id, object_type, "lua.configurator.configurator.update_type_ID_input_field")
end

function add_input_field_change(container, label, field_id, object_type, change_function_name, focus_lost_function)
	local func_table = {}
	if change_function_name ~= "" and change_function_name ~= nil then
		func_table["Change"] = change_function_name
	end
	if focus_lost_function ~= "" and focus_lost_function ~= nil then
		func_table["FocusLost"] = focus_lost_function
	end
	return add_input_field_event_function(container, label, field_id, object_type, func_table)
end

function add_input_field_function(container, label, field_id, object_type, function_name)
	return add_input_field_event_function(container, label, field_id, object_type, {FocusLost = function_name})
end

function add_input_field_event_function(container, label, field_id, object_type, event_function_table)
	return d.add_row_labeled_field(container, {caption = label}, {id = field_id, text = object_type:attr_e(field_id)}, {id = "row_" .. field_id}, "D#InputField", event_function_table)
end

function add_multi_field(container, label, field_id, object_type, event_list)
	if event_list == nil then
		event_list = {FocusLost = "lua.configurator.configurator.update_type_input_field"}
	end
	local row = d.add_row_labeled_field(container, {caption = label}, {id = field_id, text = object_type:attr(field_id)}, {id = "row_" .. field_id}, "D#TextArea", event_list)
end

function add_checkBox_field(container, label, field_id, object_type)
	local row = d.add_row_labeled_field(container, {caption = label}, {id = field_id, checked = object_type:attr(field_id)}, {id = "row_" .. field_id}, "D#CheckBox", {FocusLost = "lua.configurator.configurator.update_check_box_field"})
end

function add_checkBox_field_function(container, label, field_id, object_type, function_list)
	return d.add_row_labeled_field(container, {caption = label}, {id = field_id, checked = object_type:attr(field_id)}, {id = "row_" .. field_id}, "D#CheckBox", function_list)
end

function add_comboBox_field(container, label, field_id, is_editable, item_generator, object_type)
	return add_comboBox_field_function(container, label, field_id, is_editable, "lua.configurator.configurator.update_type_input_field", item_generator, object_type)
end

function add_comboBox_field_function(container, label, field_id, is_editable, focus_lost, item_generator, object_type)
	return add_comboBox_field_function_value(container, label, field_id, is_editable, focus_lost, item_generator, object_type:attr(field_id))
end

function add_comboBox_field_function_start_value(container, label, field_id, is_editable, focus_lost, item_generator, field_value_generator)
	return add_comboBox_field_function_value(container, label, field_id, is_editable, focus_lost, item_generator, field_value_generator)
end

function add_comboBox_field_function_value(container, label, field_id, is_editable, focus_lost, item_generator, value)
	return d.add_row_labeled_field(container, {caption = label}, {id = field_id, editable = is_editable, text = value, enabled = "true"},
	{id = "row_" .. field_id}, "D#ComboBox", {FocusLost = focus_lost, DropDown = item_generator})
end

function add_comboBox_field_change_dropdown(container, label, field_id, is_editable, change, item_generator, object_type)
	return d.add_row_labeled_field(container, {caption = label}, {id = field_id, editable = is_editable, enabled = "true", text = object_type:attr_e(field_id)},
	{id = "row_" .. field_id}, "D#ComboBox", {Change = change, DropDown = item_generator})
end

function add_checkBox_comboBox_field(container, label, field_id, is_editable, change, item_generator, object_type)
	local value = object_type:attr_e(field_id)
	local row, combo = d.add_vertical_box_labeled_field(container, {caption = label}, {id = field_id, editable = is_editable, text = value},
	{id = "row_" .. field_id}, "D#ComboBox", {Change = change, DropDown = item_generator})
	manage_property_row_field_table(combo, value, "true")
	return row, combo
end

function navigate_to_diagram(combo_box)
	if combo_box == nil then
		combo_box = get_event_source()
	end
	local res_table = {}
	table.insert(res_table, "")
	make_combo_box_item_table(lQuery("GraphDiagramType"):filter(":not([id = 'specificationDgr'], [id = 'diagramTypeDiagram'], [id = 'MMInstances'], [id = 'Repository'])"), "id", res_table)
	add_lQuery_configurator_comboBox(res_table, combo_box)
end

function update_navigate_to_diagram()
	local attr, value = get_event_source_attrs("text")
	local elem_type = utilities.active_elements():find("/target_type")
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(elem_type), NavigateToDiagram = value})
	elem_type:remove_link("target")
	local attr_table = {}
	if value ~= "" then
		attr_table = {
			l2ClickEvent = "utilities.navigate",
			procCreateElementDomain = "utilities.add_navigation_diagram",
			procDeleteElement = "interpreter.Delete.delete_seed",
			procPasted = "interpreter.CutCopyPaste.copy_paste_diagram_seed",
			procCopied = "interpreter.CutCopyPaste.copy_paste_diagram_seed"}
		lQuery("GraphDiagramType[id = '" .. value .."']"):link("source", elem_type)
	else
		attr_table = {
			l2ClickEvent = "interpreter.Properties.Properties",
			procCreateElementDomain = "",
			procDeleteElement = "",
			procPasted = "",
			procCopied = ""}
	end
	cu.add_translet_to_obj_type(elem_type, "l2ClickEvent", attr_table["l2ClickEvent"])
	cu.add_translet_to_obj_type(elem_type, "procCreateElementDomain", attr_table["procCreateElementDomain"])
	cu.add_translet_to_obj_type(elem_type, "procDeleteElement", attr_table["procDeleteElement"])
	cu.add_translet_to_obj_type(elem_type, "procPasted", attr_table["procPasted"])
	cu.add_translet_to_obj_type(elem_type, "procCopied", attr_table["procCopied"])

	local l2Click = d.get_component_by_id("l2ClickEvent")
	local procCreateElementDomain = d.get_component_by_id("procCreateElementDomain")
	local procDeleteElement = d.get_component_by_id("procDeleteElement")
	local procPasted = d.get_component_by_id("procPasted")
	local procCopied = d.get_component_by_id("procCopied")
	if l2Click:is_not_empty() and procCreateElementDomain:is_not_empty() and procDeleteElement:is_not_empty() then
		utilities.refresh_form_component(l2Click:attr({text = attr_table["l2ClickEvent"]}))
		utilities.refresh_form_component(procCreateElementDomain:attr({text = attr_table["procCreateElementDomain"]}))
		utilities.refresh_form_component(procDeleteElement:attr({text = attr_table["procDeleteElement"]}))
		utilities.refresh_form_component(procPasted:attr({text = attr_table["procPasted"]}))
		utilities.refresh_form_component(procCopied:attr({text = attr_table["procCopied"]}))
	end
end

function add_configurator_comboBox(items, combo_box)
	if combo_box == nil then
		combo_box = empty_comboBox()
	end	
	add_comboBox_items(combo_box, items)
end

function add_lQuery_configurator_comboBox(item_table, combo_box)
	if combo_box == nil then
		combo_box = get_event_source()
	end
	empty_comboBox(combo_box)
	add_lQuery_comboBox_items(item_table, combo_box)
	combo_box:find("/item")
	return combo_box
end

function empty_comboBox(combo_box)
	if combo_box == nil then
		combo_box = get_event_source()
	end
	remove_combo_box_items(combo_box)
return combo_box
end

function add_compartType(treeNode, node_name)
	local parent = treeNode:find("/parentNode")
	local source_type = parent:find("/type")
	if parent:find("/tree"):is_not_empty() then
		local id = cu.generate_unique_id(node_name, source_type, "compartType")
		local compartType, compartStyle = add_compart_type_compart_style(id)
					:link("treeNode", treeNode:attr({text = id}))
		source_type:link("compartType", compartType)
		add_configurator_compart_type(compartType, compartStyle)
		compart_type_versioning(compartType)
	else
		local id = cu.generate_unique_id(node_name, source_type, "subCompartType")
		local compartType, compartStyle = add_compart_type_compart_style(id)
					:link("treeNode", treeNode:attr({text = id}))
		source_type:link("subCompartType", compartType)
		compart_type_versioning(compartType)
	end
end

function add_configurator_compart_type(compartType, compartStyle)
	local elem = utilities.active_elements()
	local attr_compart_type = elem:find("/elemType/compartType[id = 'AS#Attributes']")
	return lQuery.create("Compartment", {element = elem,
					target_type = compartType,
					compartStyle = compartStyle,
					compartType = attr_compart_type})
end

function add_compart_type_compart_style(node_name)
	local compart_type = add_compart_type(node_name)
	cu.add_compart_type_translets(compart_type)
	local compart_style = u.add_default_compart_style(compart_type:attr_e("id"), compart_type:attr_e("caption")):link("compartType", compart_type)
	return compart_type, compart_style
end

function add_compart_type(node_name)
	return lQuery.create("CompartType", { 
				id = node_name,
				caption = node_name,
				startValue = "",
				pattern = "a-zA-Z0-9-_",
				nr = 0,
				isStereotypable = "false",
				isStereotype = "false",
				isMultiple = "false",
				isHint = "false",
				toBeInvisible = "false",
				isEssential = "true",
				is_occurrence_compartment = "false",
				isDiagramName = "false",
				isGroup = "false"})
end

function delete_treeNode_compartType(selected_node)
	selected_node:find("/childNode"):each(function(child_node)
		delete_treeNode_compartType(child_node)	
	end)
	local obj_type = selected_node:find("/type")	
	local parent_type = obj_type:find("/parentCompartType[id ^= 'ASFictitious']")
	delete_compart_type_with_additions(obj_type)	
	manage_property(obj_type:find("/propertyRow"))
	obj_type:delete()
	if parent_type:is_not_empty() then
		delete_compart_type_with_additions(parent_type)
		manage_property(parent_type:find("/propertyRow"))
		parent_type:delete()
	end
end

function delete_compart_type_with_additions(compart_type)
	compart_type:find("/compartment"):delete()
	compart_type:find("/compartStyle"):delete()
	delete_choice_items(compart_type)
end

function add_main_popUp_table(container)
	local table = add_main_popUp_table_header(container, "lua.configurator.configurator.process_popUpTable", "Context Menu")
	fill_popUpTable(table)
end

function add_main_popUp_table_header(container, function_name, table_name)
	return add_default_popUp_table_header(container, "main_popUp_table", function_name, table_name)
end

function add_element_key_shortcuts(container)
	return add_key_shortcuts(container, "element_key_shortcuts", "lua.configurator.configurator.process_element_shortcut_table", "KeyShortcuts")
end

function add_key_shortcuts(container, id, function_name, table_name)
	--local label = d.add_component(container, {id = "table_id", caption = table_name}, "D#Label")
	local group_box = d.add_component(container, {id = "table_id", caption = table_name}, "D#GroupBox")
	
	local table = d.add_component(group_box, {id = id, editable = "true", insertButtonCaption = "Add", deleteButtonCaption = "Delete"}, "D#VTable") 
	d.add_event_handlers(table, {FocusLost = function_name})
	local shortcut_column = d.add_columnType(table, {caption = "KeyShortcut", editable = "true", horizontalAlignment = -1}, "D#ComboBox", {editable = "true"}, {DropDown = "lua.configurator.configurator.default_keyshortcuts"})
	local transformation_column = d.add_columnType(table, {caption = "TransformationName", editable = "true", horizontalAlignment = -1}, "D#ComboBox", {editable = "true"}, {DropDown = "lua.configurator.configurator.default_transformation_names"})
	fill_element_key_shortcuts(table)
return table
end

function add_contain_table(container)
	local group_box = d.add_component(container, {id = "table_id", caption = "Contains"}, "D#GroupBox")
	local list_box = d.add_component(group_box, {id = "contains_list_box",  multiSelect = "true", horizontalAlignment = 0, minimumWidth = 220, minimumHeight = 150}, "D#ListBox")
	d.add_event_handlers(list_box, {Change = "lua.configurator.configurator.change_contains()"})
	fill_contains_list_box(list_box)
end

function change_contains()
	log_list_box({Name = "Contains"})
	local ev = lQuery("D#Event")
	local selected_item = ev:find("/selected")
	local obj_type = get_type_from_tree_node()
	if selected_item:is_not_empty() then
		local selected_item_value = selected_item:attr("value")
		local component_type = obj_type:find("/graphDiagramType/elemType NodeType[id = '" .. selected_item_value .. "']")
		if component_type:is_not_empty() then
			component_type:link("containerType", obj_type)
		end
	else
		local deselected_item_val = ev:find("/deselected"):attr("value")
		local component_type = obj_type:find("/graphDiagramType/elemType NodeType[caption = '" .. deselected_item_val .. "']")
		obj_type:remove_link("componentType", component_type)
	end
	d.delete_event()
end

function fill_contains_list_box(list_box)
	local obj_type = get_type_from_tree_node()
	local contains_list = {}
	obj_type:find("/componentType"):each(function(component_type)
		local id = component_type:attr("id")
		contains_list[id] = true
	end)
	utilities.active_elements():find("/target_type/graphDiagramType/elemType NodeType"):each(function(node_type)
		local palette_element_type = node_type:find("/paletteElementType")
		if palette_element_type:is_not_empty() then
			local value = node_type:attr("id")
			local item = lQuery.create("D#Item", {value = value})
			list_box:link("item", item)
			if contains_list[value] then
				list_box:link("selected", item)
			end
		end
	end)
end

function process_element_contains()
	local obj_type = get_type_from_tree_node()
	obj_type:remove_link("componentType")
	get_event_source():find("/vTableRow"):each(function(row)
		row = lQuery(row)
		row:find("/vTableCell"):each(function(cell)
			cell = lQuery(cell)
			local cell_value = cell:attr_e("value")
			if cell_value ~= "" then
				local component_type = obj_type:find("/graphDiagramType/elemType NodeType[caption = '" .. cell_value .. "']")
				if component_type:size() > 0 then
					component_type:link("containerType", obj_type)
					component_type:link("parentType", obj_type)
				end
			end
		end)
	end)
end

function container_items()
	return add_lQuery_configurator_comboBox(make_combo_box_item_table(utilities.active_elements():find("/target_type/graphDiagramType/elemType NodeType"), "caption"))
end

function fill_container_table(table)
	fill_table(table, "/componentType", {"caption"})
end

function process_element_shortcut_table()
	process_shortcut_table("/keyboardShortcut", "elemType")
end

function process_shortcut_table(path_to_element, role)
	local obj_type = get_type_from_tree_node()
	process_shortcut_table_header(obj_type, role, path_to_element)
end

function process_shortcut_table_header(obj_type, role, path_to_element)
	log_table({Name = "KeyShortcuts"})
	local shortcut_table = {}
	obj_type:find(path_to_element):delete()
	get_event_source():find("/vTableRow"):each(function(row)
		local tmp_table = {}
		if row:attr_e("deleted") ~= "true" then
			row:find("/vTableCell"):each(function(cell)
				cell = lQuery(cell)
				table.insert(tmp_table, cell:attr_e("value"))
			end)
			table.insert(shortcut_table, tmp_table)
		end
	end)
	for i, row in pairs(shortcut_table) do  
		lQuery.create("KeyboardShortcut", {key = row[1], procedureName = row[2]}):link(role, obj_type)
	end
end

function fill_element_key_shortcuts(table)
	fill_table(table, "/keyboardShortcut", {"key", "procedureName"})
end

function fill_table(table, path_to_elem, attr_table)
	local obj_type = get_type_from_tree_node():log("id")
	fill_table_from_obj(obj_type, table, path_to_elem, attr_table)
end

function fill_table_from_obj(obj_type, table, path_to_elem, attr_table)
	obj_type:find(path_to_elem):each(function(elem)
		local row = lQuery.create("D#VTableRow"):link("vTable", table)
		for i, index in pairs(attr_table) do
			row:link("vTableCell", lQuery.create("D#VTableCell", {value = elem:attr_e(index)}))
		end
	end)
end

function add_specific_transformation()
--prieks transformaciju ievadisanas caur editoru
	print("add specific transformation")
end

function add_comboBox_items(combo_box, items)
	for i, item in ipairs(items) do
		combo_box:link("item", lQuery.create("D#Item", {value = item}))
	end
end

function add_lQuery_comboBox_items(item_table, combo_box)
	for _, item in pairs(item_table) do
		combo_box:link("item", lQuery.create("D#Item", {value = item}))
	end
end

function remove_combo_box_items(combo_box)
	combo_box:find("/item"):delete()
end

--palette name
function set_palette_name_line()
	local attr, value = get_event_source_attrs("text")
	local elem_type = utilities.active_elements():find("/target_type")
	local palette_type = elem_type:find("/graphDiagramType/paletteType")
	if palette_type:is_not_empty() then
		local palette_type_elem = palette_type:find("/paletteElementType[" .. attr .. " = " .. value .. "]")	
		local tmp_palette_elem_type = elem_type:find("/paletteElementType")
		if palette_type_elem:is_not_empty() then
			if tmp_palette_elem_type:id() ~= palette_type_elem:id() then
				if tmp_palette_elem_type:find("/elemType"):size() == 1 then	
					delete_palette_elem_type(tmp_palette_elem_type)
					elem_type:link("paletteElementType", palette_type_elem)
				else
					tmp_palette_elem_type:remove_link("elemType", elem_type)
					palette_type_elem:link("elemType", elem_type)
				end
			end
		else
			if tmp_palette_elem_type:find("/elemType"):size() == 1 then
				local pic = tmp_palette_elem_type:attr("picture")
				local nr = tmp_palette_elem_type:attr("nr")
				delete_palette_elem_type(tmp_palette_elem_type)	
				set_palette_element_type_attribute(get_palette_element_type(), {id = value, caption = value, picture = pic, nr = nr})
				utilities.set_palette_element_attribute()
			else
				tmp_palette_elem_type:remove_link("elemType", elem_type)
				--set_palette_element_name()
				set_palette_name()
			end
		end
	else
		set_palette_name()
		--set_palette_element_name()
	end
	local palette_type_elem = elem_type:find("/paletteElementType:has(/elemType.EdgeType)")
	local nr_value = palette_type_elem:attr_e("nr")
	local image_value = palette_type_elem:attr_e("picture")
	local _, nr, image = get_palette_components()
	refresh_palette_nr_and_image(nr:attr({text = nr_value}), image:attr({fileName = image_value}))
end

function delete_palette_elem_type(palette_elem_type)
	palette_elem_type:find("/presentationElement"):delete()
	palette_elem_type:delete()
end

function set_palette_name()
	local attr, value = get_event_source_attrs("text")
	local palette_elem_type = set_palette_element_type_attribute(get_palette_element_type(), {id = value, caption = value})
 	utilities.set_palette_element_attribute()
	log_configurator_field(attr, {ObjectType = "PaletteElementType", name = value})
	return palette_elem_type
end

--palette image
function set_palette_image_box()
	set_palette_image("PaletteBox")
end

function set_palette_image_line()
	set_palette_image("PaletteLine")
end

function set_palette_image_pin()
	set_palette_image("PalettePin")
end

function set_palette_image_free_box()
	set_palette_image("PaletteFreeBox")
end

function set_palette_image_free_line()
	set_palette_image("PaletteFreeLine")
end

function set_palette_image(name)
	local attr, fileName = get_event_source_attrs("fileName")
	log_configurator_field(attr, {type = "PaletteElementType", picture = fileName})
	local fileName_reverse = string.reverse(fileName)
	fileName = string.reverse(string.sub(fileName_reverse, 1, string.find(fileName_reverse, "\\") - 1))
	set_palette_element_type_attribute(get_palette_element_type(), {picture = fileName}, name)
	utilities.set_palette_element_attribute()
end

--palette nr
function set_palette_nr_box()
	set_palette_element_nr("PaletteBox")
end

function set_palette_nr_line()
	set_palette_element_nr("PaletteLine")
end

function set_palette_nr_pin()
	set_palette_element_nr("PalettePin")
end

function set_palette_nr_free_box()
	set_palette_element_nr("PaletteFreeBox")
end

function set_palette_nr_free_line()
	set_palette_element_nr("PaletteFreeLine")
end

function set_palette_element_nr(name)
	local attr, nr = get_event_source_attrs("text")
	local palette_element_type = get_palette_element_type()
	set_palette_element_type_attribute(palette_element_type, {nr = nr}, name)
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(palette_element_type), nr = nr})
end

function set_palette_element_type_attribute(palette_element_type, attrs)
	local diagram_type = utilities.active_elements():find("/target_type/graphDiagramType")
	local graphDiagram = diagram_type:find("/graphDiagram")
	if attrs["caption"] == "" and palette_element_type:is_not_empty() then
		delete_palette_element_type(palette_element_type)
	else
		if palette_element_type:is_not_empty() then 
			palette_element_type:attr(attrs)
		else
			local palette_type = diagram_type:find("/paletteType")
			if attrs["nr"] == nil then
				attrs["nr"] = palette_type:find("/paletteElementType"):size() + 1
			end
			if palette_type:is_not_empty() then	
				palette_elem_type = lQuery.create("PaletteElementType", {elemType = get_type_from_tree_node(), paletteType = palette_type}):attr(attrs)
			else
				palette_type = lQuery.create("PaletteType", {graphDiagramType = diagram_type})
				palette_elem_type = lQuery.create("PaletteElementType", attrs)
									:link("paletteType", palette_type)
									:link("elemType", get_type_from_tree_node())
			end
		end
	end
	return palette_elem_type
end


function delete_palette_element_type(palette_element_type)
	local palette_type = palette_element_type:find("/paletteType")
	local palette_size = palette_type:find("/paletteElementType"):size()
	if palette_size == 1 then
		palette_type:delete()
	end
	local palette_name, palette_nr, palette_image = get_palette_components()
	utilities.refresh_form_component(palette_name)
	utilities.refresh_form_component(palette_nr)
	utilities.refresh_form_component(palette_image)
	palette_element_type:find("/presentationElement"):each(function(palette_element)
		delete_palette_element(palette_element)
	end)
	palette_element_type:delete()
end

function delete_palette_element(palette_element)
	local palette = palette_element:find("/palette")
	local diagram = palette:find("/graphDiagram")
	local palette_size = palette:find("/paletteElement"):size()
	if palette_size == 1 then
		palette:delete()
	end
	palette_element:delete()
end

function get_palette_components()
	local palette_name = lQuery("D#Component[id = 'row_caption']:has(/component/component[caption = 'Palette Element Name'])/component/component"):attr({text = ""})
	local palette_nr = lQuery("D#Component[id = 'row_nr']/component/component[id = 'nr']"):attr({text = ""})
	local palette_image = lQuery("D#Component[id = 'row_picture']/component/component[id = 'picture']"):attr({fileName = ""})
return palette_name, palette_nr, palette_image
end

function get_palette_element()
	return utilities.active_elements():find("/target_type/paletteElementType/paletteElement")
end

function get_palette_element_type()
	return utilities.active_elements():find("/target_type/paletteElementType")
end

function row_type_generator(combo)
	add_configurator_comboBox({"", 
				"InputField",
				"ComboBox",
				"CheckBox",
				"TextArea",
				"Label",
				"ListBox",
				"InputField+Button",
				"ComboBox+Button",
				"TextArea+Button",
				"TextArea+DBTree",
				"CheckBox+Button",
				"Performers"}, combo)
	--"MultiLineTextBoxRow+Tree","GroupedInputsRow", "TagRow", "StereotypeRow", "EmptyRow"})
end

function row_tab_generator()
	add_lQuery_configurator_comboBox(make_combo_box_item_table(get_property_diagram(get_selected_type()):find("/propertyTab"), "id"))
end

function set_row_tab()
print("function set row tab")
	if lQuery("D#Component:has([id = 'rowType'])"):attr("text") ~= "" then
		local attr, value = get_event_source_attrs("text")
		local object_type = get_selected_obj_type()
		log_configurator_field(attr, {Tab = value})
		local diagram = get_property_diagram(object_type)
		local row = object_type:find("/propertyRow")
		local tab = get_tab_by_name(diagram, attr, value)
		if value == "" then 
			print("empty tab")
			local parent_tab = row:find("/propertyTab")
			row:remove_link("propertyTab", parent_tab):link("propertyDiagram", diagram)
			local rows = parent_tab:find("/propertyRow")
			if rows:size() == 0 then
				print("delete tab")
				delete_empty_property_tab(parent_tab)
			end
		else
print("else tab")
			if tab == nil then
			print("new tab")
				set_property_tab(attr, value, diagram, row)
			else
			print("change tab")
				change_to_tab(tab, row)
			end
		end
	end
print("end set row tab")
end

function change_to_tab(tab, row)
	local diagram = row:find("/propertyDiagram")
	if diagram:size() > 0 then
		diagram:remove_link("propertyRow", row)
	else
		local parent_tab = row:find("/propertyTab")
		if parent_tab:size() > 0 then
			parent_tab:remove_link("propertyRow", row)
			if parent_tab:find("/propertyRow"):size() == 0 then 
				delete_empty_property_tab(parent_tab)
			end
		end
	end
	tab:link("propertyRow", row)
end

function get_tab_by_name(diagram, attr, value)
	local res = nil
	diagram:find("/propertyTab"):each(function(tab)
		tab = lQuery(tab)
		if tab:attr(attr) == value then
			res = tab
		end
	end)
return res
end

function set_property_tab(attr, value, diagram, row)
	local tab = lQuery.create("PropertyTab"):link("propertyDiagram", diagram)
	tab:attr(attr, value)
	change_to_tab(tab, row)
return tab
end

function get_element_styles()
	local obj_type = u.get_elem_type_from_compartment(get_selected_obj_type())
	return get_style_names_from_object(obj_type, "/elemStyle")
end

function get_compart_styles()
	return get_style_names_from_object(get_selected_obj_type(), "/compartStyle")
end

function get_style_names_from_object(obj, path)
	local res = {}
	obj:find(path):each(function(style)
		table.insert(res, lQuery(style):attr_e("id"))
	end)
	add_configurator_comboBox(res)
end

function set_notation_field()
	local table = d.get_component_by_id("click_box_table")
	table:find("/selectedRow/vTableCell"):find("/componentType")
end

function set_combobox_editable()
	local _, value = get_event_source_attrs("checked")
	get_selected_type():find("/propertyRow"):attr({isEditable = value})
end

function add_click_box_table(container, table_attr_list, focus_lost_function)
	local table = d.add_component(container, table_attr_list, "D#VTable")
		:attr({minimumWidth = 100, minimumHeight = 100})
	d.add_event_handlers(table, {FocusLost = focus_lost_function})
	local choice_item = d.add_columnType(table, {caption = "ChoiceItem", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
	local elem_style = d.add_columnType(table, {caption = "ElemStyle", editable = "true", horizontalAlignment = -1}, "D#ComboBox", {editable = "true"}, {DropDown = "lua.configurator.configurator.get_element_styles"})
	local compart_style = d.add_columnType(table, {caption = "CompartStyle", editable = "true", horizontalAlignment = -1}, "D#ComboBox", {editable = "true"}, {DropDown = "lua.configurator.configurator.get_compart_styles"})
return table
end

function make_property_field()
	local attr, value = get_event_source_attrs("text")
	local field = d.get_component_by_id(attr)
	log_configurator_field(attr, {ObjectType = utilities.get_class_name(field), [attr] = value})
-- vajag izdzçst check box un combo box tabulu sarazoto domain
	manage_property_row_field_table(field, value, "false")
	set_row_type()
end

function update_from_click_box_table()
	local compart_type = get_selected_type()
	delete_choice_items_and_notation(compart_type)
	local res_table = get_res_table_from_table(get_event_source())
	local elem_type = u.get_elem_type_from_compartment(compart_type)
	for _, row in pairs(res_table) do  
		create_choice_item(compart_type, elem_type, row)
	end
end

function delete_choice_items_and_notation(compart_type)
	local choice_items = compart_type:find("/choiceItem")
	if choice_items:size() > 0 then
		local notation = choice_items:find("/notation")
		if notation:size() > 0 then
			notation:delete()
		end
		choice_items:delete()
	end
end

function update_from_combo_box_table()
	local compart_type = get_selected_type()
	delete_choice_items_and_notation(compart_type)
	local res_table = get_res_table_from_table(get_event_source())
	local elem_type = u.get_elem_type_from_compartment(compart_type)
	for _, row in pairs(res_table) do
		local choice_item = create_choice_item_without_notation(compart_type, elem_type, row)
		if row[4] ~= "true" then
			local val = core.build_input_from_value(row[1], compart_type)
			choice_item:link("notation", create_notation(val))
		end
	end
end

function get_style_from_type_object(object, path)
	if object ~= nil then
		return object:find(path)
	else
		return nil
	end
end

function get_res_table_from_table(source)
	local res_table = {}
	local indexed_res_table = {}
	source:find("/vTableRow"):each(function(row)
		local tmp_table = {}
		if row:attr_e("deleted") ~= "true" then
			local buls = 0
			local id = ""
			row:find("/vTableCell"):each(function(cell)
				if buls == 0 then
					id = cell:attr_e("value")
					buls = 1
				end
				table.insert(tmp_table, cell:attr_e("value"))
			end)
			table.insert(res_table, tmp_table)
			indexed_res_table[id] = tmp_table
		end
	end)
	return res_table, indexed_res_table
end

function manage_property_row_field_table(field, value, start_build)
	local compart_type = get_selected_type()
	local active_tab = active_tab()
	local row_type_box = d.get_component_by_id_in_depth(active_tab, "row_rowType")
	local vertical_box = d.get_component_by_id_in_depth(row_type_box, "field_box")
	local table = d.get_component_by_id_in_depth(vertical_box, "click_box_table")
	if table ~= nil then
		table:delete()
	end
	local combo_box = d.get_component_by_id_in_depth(vertical_box, "row_editable")
	if combo_box ~= nil then
		combo_box:delete()
	end
	if value == "CheckBox" or value == "ComboBox" or value == "CheckBox+Button" then
		if start_build ~= "true" then
			local choice_items = compart_type:find("/choiceItem"):delete()
		end
		if value == "CheckBox" or value == "CheckBox+Button" then
			if start_build ~= "true" then
				add_default_check_box_items(compart_type)
			end
			table = add_click_box_table(vertical_box, {id = "click_box_table", editable = "false"}, "lua.configurator.configurator.update_from_click_box_table")
			d.add_columnType(table, {caption = "Notation", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
			fill_click_box_table(table, "Notation")
		elseif value == "ComboBox" then
			table = add_click_box_table(vertical_box, {id = "click_box_table", editable = "true", insertButtonCaption = "Add", deleteButtonCaption = "Delete"}, "lua.configurator.configurator.update_from_combo_box_table")
			local is_visible = d.add_columnType(table, {caption = "IsInvisible", editable = "true", horizontalAlignment = -1}, "D#CheckBox", {editable = "true"})
			local _, check_box = add_checkBox_field_function(vertical_box, "Is Editable", "editable", field, {Change =  "lua.configurator.configurator.set_combobox_editable"})			
			check_box:attr({checked = compart_type:find("/propertyRow"):attr("isEditable")})
			fill_click_box_table(table, "IsVisible")
		end
	end
	if start_build ~= "true" then
		local old_row_type = compart_type:find("/propertyRow"):attr("rowType")
		if (old_row_type == "ComboBox" and value ~= "ComboBox") or (old_row_type == "CheckBox" and value ~= "CheckBox") or
		(value == "ComboBox" and old_row_type ~= "ComboBox") or (value == "CheckBox" and old_row_type ~= "CheckBox") or
		(old_row_type == "CheckBox+Button" and value ~= "CheckBox+Button") or (value == "CheckBox+Button" and old_row_type ~= "CheckBox+Button") then
			utilities.refresh_form_component(vertical_box)
		end
	end
end

function get_choice_item()
	local choice_item_id = d.get_component_by_id("click_box_table"):find("/selectedRow/vTableCell:first()"):attr("value")
	local compart_type = d.get_component_by_id("Tree"):find("/selected/type")
	local res = nil
	local buls = 0
	compart_type:find("/choiceItem"):each(function(choice_item)
		if choice_item:attr("value") == choice_item_id and buls == 0 then
			buls = 1
			res = choice_item
		end	
	end)
	return res
end

function add_default_check_box_items(compart_type)
print("add default check box items")
	local elem_type = u.get_elem_type_from_compartment(compart_type)
	create_choice_item(compart_type, elem_type, {"true", "", "", "true"})
	create_choice_item(compart_type, elem_type, {"false", "", "", "false"})

	compart_type:find("/choiceItem"):log()
print("end add default check box items")
end

function create_choice_item(compart_type, elem_type, row)
	return create_choice_item_without_notation(compart_type, elem_type, row):link("notation", create_notation(row[4], row[1]))
end

function create_choice_item_without_notation(compart_type, elem_type, row)
print("create choice item")
	return lQuery.create("ChoiceItem", {
		compartType = compart_type,
		value = row[1],
		elemStyleByChoiceItem = get_style_from_type_object(elem_type, "/elemStyle:has([id = '" .. row[2] .. "'])"),
		compartStyleByChoiceItem = get_style_from_type_object(compart_type, "/compartStyle:has([id = '" .. row[3] .. "'])"):log()})
end

function create_notation(val, default_val)
	if val == nil then
		return lQuery.create("Notation", {value = default_val})
	else
		return lQuery.create("Notation", {value = val})
	end
end

function fill_click_box_table(table, last_cell)
	get_selected_type():find("/choiceItem"):each(function(item)
		local table_row = lQuery.create("D#VTableRow"):link("vTable", table)
		lQuery.create("D#VTableCell", {vTableRow = table_row, value = item:attr_e("value")})
		lQuery.create("D#VTableCell", {vTableRow = table_row, value = item:find("/elemStyleByChoiceItem"):attr_e("id")})
		lQuery.create("D#VTableCell", {vTableRow = table_row, value = item:find("/compartStyleByChoiceItem"):attr_e("id")})
		if last_cell == "Notation" then
			local notation_value = item:find("/notation"):attr_e("value")
			lQuery.create("D#VTableCell", {vTableRow = table_row, value = notation_value})
		elseif last_cell == "IsVisible" then
			if item:find("/notation"):is_empty() then
				lQuery.create("D#VTableCell", {vTableRow = table_row, value = "true"})
			else
				lQuery.create("D#VTableCell", {vTableRow = table_row, value = "false"})
			end
		elseif last_cell == "button" then
			lQuery.create("D#VTableCell", {vTableRow = table_row})
		end
	end)
end

function set_row_type()
	local attr, value = get_event_source_attrs("text")
	local object_type = get_selected_obj_type()
	local name = object_type:attr("caption")
	--remove_fiction_compartment(object_type)
	if value == "" then 
		manage_property(object_type:find("/propertyRow"))
	else
		set_property_row(name, value, object_type)
	end
	local buls = is_dialog_button_enabled(get_active_target_type())
	local dialog_button = d.get_component_by_id_in_depth(lQuery("D#Form[id = 'configurator_form']"), "dialog_button")
	dialog_button:attr({enabled = buls})
	d.execute_d_command(dialog_button, "Refresh")
end

function add_called_diagram(row)
	local parent, role = get_existing_row_parent(row)
	local obj_type = row:find("/compartType")
	local called_dgr = create_property_diagram(obj_type, "compartType")
	obj_type:find("/propertyDiagram", called_dgr)
	row:link("calledDiagram", called_dgr, parent, role)
	relink_property_rows(obj_type, called_dgr, parent, role)
end

function relink_property_rows(obj_type, called_dgr, parent, role)
	local sub_compart_type = obj_type:find("/subCompartType")
	if sub_compart_type:size() > 0 then
		sub_compart_type:each(function(compart_type)
			local row = compart_type:find("/propertyRow")
			if row:size() > 0 then
				local row_parent, parent_role = get_existing_row_parent(row)
				if row_parent:filter(".PropertyTab"):size() > 0 then
					if row_parent:find("/propertyRow"):size() == 1 then
						row_parent:remove_link("propertyDiagram")
						row_parent:link("propertyDiagram", called_dgr)
					else
						--japadoma, vai nevajag izveidot jaunu tabu?
						row:remove_link(parent_role, row_parent)
						row:link("propertyDiagram", called_dgr)
						remove_up_the_tree_from_row(row_parent:find("/calledPropertyRow"))
					end
				else
					row:remove_link("propertyDiagram", row_parent)
					row:link("propertyDiagram", called_dgr)
					remove_up_the_tree_from_row(row_parent:find("/calledPropertyRow"))
				end
			end
			relink_property_rows(compart_type, called_dgr, parent, role)
		end)
	end
end

function remove_up_the_tree_from_row(row)
	local tab = row:find("/propertyTab")
	local diagram = row:find("/propertyDiagram")
	if tab:size() > 0 then
		if tab:find("/propertyRow"):size() == 1 then
			diagram = find("/propertyDiagram")
			tab:delete()
			if diagram:find("/propertyRow"):size() == 0 and diagram:find("/propertyTab"):size() == 0 then
				local calling_row = diagram:find("/calledPropertyRow")
				diagram:delete()
				remove_up_the_tree_from_row(calling_row)
			end
		end
	elseif diagram:size() > 0 then
		if diagram:find("/propertyRow"):size() == 1 and diagram:find("/propertyTab"):size() == 0 then
			local calling_row = diagram:find("/calledPropertyRow")
			diagram:delete()
			remove_up_the_tree_from_row(calling_row)	
		end
	end
end

function get_existing_row_parent(row)
	local tab = row:find("/propertyTab")
	local diagram = row:find("/propertyDiagram")
	if tab:size() > 0 then
		return tab, "propertyTab"
	elseif diagram:size() > 0 then
		return diagram, "propertyDiagram"
	else
		print("Error in get_existing_row_parent")
	end
end

function set_property_row(name, value, object_type)
	local row_parent, parent_role = get_property_row_parent(object_type)
	local property_row = object_type:find("/propertyRow")
	if property_row:is_not_empty() then
		print("old row")
		manage_called_diagram(property_row, value, row_parent, parent_role)
		set_property_row_attributes(property_row, {id = name, rowType = value})
	else
		print("else row")
		local property_row
		if row_parent:filter(".PropertyDiagram"):is_not_empty() and row_parent:find("/compartType/propertyRow[rowType = 'CheckBox+Button']"):is_not_empty() then
			property_row = create_property_row(object_type:attr("id"), name, value, row_parent, parent_role, object_type)
		else
			property_row = create_property_row(object_type:attr("id"), name, value, row_parent, parent_role, object_type)
		end

		--local property_row = create_property_row(object_type:attr("id"), name, value, row_parent, parent_role, object_type)
		--if value == "InputField+Button" or value == "TextArea+Button" or value == "CheckBox+Button" then
		if value == "TextArea+Button" or value == "CheckBox+Button" then
			print("add called diagram")
			
			if value == "CheckBox+Button" then
				add_called_diagram(property_row)

				add_fiction_compart_for_check_box_button(object_type)
			else
				print("in fiction")
				add_called_diagram(property_row)
				add_fiction_copmart_for_text_field(object_type)
			end
		else
			remove_sub_property_rows(property_row)
		end
	end
end

function remove_sub_property_rows(property_row)
	local compart_type = property_row:find("/compartType")
	compart_type:find("/subCompartType"):each(function(c_type)
		local row = c_type:find("/propertyRow")
		local dgr = row:find("/calledDiagram")
		delete_called_diagram(dgr)
		remove_up_the_tree_from_row(row)
		remove_sub_property_rows(row)
		row:delete()
	end)
end

function get_property_row_parent(object_type)
	print("get property row parent")
	local tab_value = lQuery("D#Component:has([id = 'id'])"):filter(".D#ComboBox"):attr("text")
	if tab_value ~= "" then
		print("in tab")
		local diagram = get_property_diagram(object_type)
		local tab = get_tab_by_name(diagram, "caption", tab_value)
		if tab ~= nil then
			return tab, "propertyTab"
		else
			return lQuery.create("PropertyTab", {caption = tab_value}):link("propertyDiagram", diagram), "propertyTab"
		end
	else 
		print("diagram")
		local parent_type = object_type:find("/parentCompartType")
		if parent_type:is_not_empty() then
			print("compartType")
			local diagram = parent_type:find("/propertyDiagram")
			if diagram:is_not_empty() then 
				return diagram, "propertyDiagram"
			else	
				print("add diagram")
				local row = parent_type:find("/propertyRow")
				local row_value = row:attr("rowType")
				if row_value == "InputField+Button" or row_value == "TextArea+Button" or row_value == "ComboBox+Button"then
					print("button")
					local called_diagram = parent_type:find("/propertyDiagram")
					--local called_diagram = row:find("/calledDiagram")
					if called_diagram:is_not_empty() then
						return called_diagram, "propertyDiagram"
					else
						--return create_property_diagram(parent_type, "compartType"), "propertyDiagram"
						local prop_dgr = create_property_diagram(row, "calledPropertyRow")
						prop_dgr:link("compartType", parent_type)
						return prop_dgr, "propertyDiagram"
					end
				elseif row_value == "CheckBox+Button" then
					print("check box + button")
					local called_diagram = parent_type:find("/propertyDiagram")
					--local called_diagram = row:find("/calledDiagram")
					if called_diagram:is_not_empty() then
						return called_diagram, "propertyDiagram"
					else
						--return create_property_diagram(parent_type, "compartType"), "propertyDiagram"
						local prop_dgr = create_property_diagram(row, "calledPropertyRow")
						prop_dgr:link("compartType", parent_type)
						return prop_dgr, "propertyDiagram"
					end

				else
					print("in else")

					local tmp_dgr = parent_type:find("/subCompartType:has(/propertyRow[rowType = 'CheckBox+Button'])/propertyDiagram")
					if tmp_dgr:is_not_empty() then
					--	print("in if")
						return tmp_dgr, "propertyDiagram"
					else
					--	print("get parent")
						return get_property_row_parent(parent_type)
					end
				end
			end
		else	
			parent_type = object_type:find("/elemType")
			local diagram = parent_type:find("/propertyDiagram")
			if diagram:is_not_empty() then
				return diagram, "propertyDiagram"
			else
				return create_property_diagram(parent_type, "elemType"), "propertyDiagram"
			end
		end
	end

	print("end get property row parent")
end

function manage_called_diagram(property_row, value, row_parent, role)
	local old_value = property_row:attr("rowType")
	print("old value " .. old_value .. " new value " .. value)
	if (old_value == "InputField+Button" or old_value == "TextArea+Button" or old_value == "ComboBox+Button") and
	(value ~= "InputField+Button" and value ~= "TextArea+Button" and value ~= "CheckBox+Button" and value ~= "ComboBox+Button") then
		--local dgr = property_row:find("/calledDiagram")
		local dgr = property_row:find("/compartType/propertyDiagram")
		delete_called_diagram(dgr)
	elseif old_value == "CheckBox+Button" then --and (value ~= "InputField+Button" and value ~= "TextArea+Button" and value ~= "CheckBox+Button") then
		local compart_type = property_row:find("/compartType")
		local diagram = compart_type:find("/propertyDiagram")
		local rows = diagram:find("/propertyRow")
		local tabs = diagram:find("/propertyTab")
		diagram:remove_link("propertyRow")
			:remove_link("propertyTab")
		local new_tab = property_row:find("/propertyTab")
		local new_diagram = property_row:find("/propertyDiagram")
		if new_tab:is_not_empty() then
			new_diagram = new_tab:find("/propertyDiagram")
			new_diagram:link("propertyTab", tabs)
			new_tab:link("propertyRow", rows)
		else
			new_diagram:link("tab", tabs)
			new_diagram:link("propertyRow", rows)
		end
		diagram:delete()
		local parent_type = utilities.get_obj_type_parent(compart_type)
		local parent_tree_node = parent_type:find("/treeNode")
	
		local parent_parent_type, role = utilities.get_obj_type_parent(parent_type)
		local parent_parent_tree_node = parent_parent_type:find("/treeNode")

		local sub_types = parent_type:find("/subCompartType")
		local sub_tree_nodes = sub_types:find("/treeNode")

		parent_type:remove_link("subCompartType")
		parent_type:remove_link("parentCompartType")
		parent_type:delete()
		parent_tree_node:remove_link("childNode")
		parent_tree_node:remove_link("parentNode")
		parent_tree_node:delete()

		sub_types:link(role, parent_parent_type)
		parent_parent_tree_node:link("childNode", sub_tree_nodes)
		utilities.refresh_form_component(d.get_component_by_id("Tree"))
		if old_value == "CheckBox+Button" and (value == "InputField+Button" and value == "TextArea+Button" and value == "ComboBox+Button") then
			--local compart_type = property_row:find("/compartType")
			add_fiction_copmart_for_text_field(compart_type)
		end
	elseif value == "CheckBox+Button" then
		add_called_diagram(property_row)
		add_fiction_compart_for_check_box_button(property_row:find("/compartType"))
	elseif (old_value == "InputField+Button" or old_value == "TextArea+Button" or old_value == "ComboBox+Button") and value == "CheckBox+Button" then
		local dgr = property_row:find("/compartType/propertyDiagram")
		delete_called_diagram(dgr)
		add_fiction_compart_for_check_box_button(compart_type)
	
	elseif value == "InputField+Button" or value == "TextArea+Button" or value == "ComboBox+Button" then
		local compart_type = property_row:find("/compartType")
		add_fiction_copmart_for_text_field(compart_type)
	end
end

function add_rows_to_diagram_from_compart_type(object_type)
	local child_type = object_type:find("/subCompartType")
	if child_type:size() > 0 then
		local called_dgr = create_property_diagram(object_type, "compartType"):link("calledPropertyRow", property_row)
		child_type:find("/propertyRow"):remove_link("propertyTab")
					:remove_link("propertyDiagram")
					:link("propertyDiagram", called_dgr)
		child_type:find("/subCompartType"):each(function(child)
			add_rows_to_diagram_from_compart_type(child)
		end)
	end
end

--vajag vel izdzest rowus patvaliga dziluma
function delete_called_diagram(diagram)
	print("delete called diagram")
	if diagram:size() > 0 then
		diagram:find("/propertyTab"):each(function(tab)
			tab:find("/propertyRow"):each(function(row)
				local called_dgr = row:find("/calledDiagram")
				row:delete()
				delete_called_diagram(called_dgr)
			end)
			tab:delete()
		end)
		diagram:find("/propertyRow"):each(function(row)
			local called_dgr = row:find("/calledDiagram")
			row:delete()
			delete_called_diagram(called_dgr)
		end)
		diagram:delete()
	end
	print("end delete called diagram")
end

function get_type_parent(object_type)
	local parent_type = object_type:find("/parentCompartType")
	if parent_type:size() > 0 then
		return parent_type
	else
		return object_type:find("/elemType")
	end
end

function get_property_diagram(object_type)
	local parent_type = object_type:find("/parentCompartType")
	if parent_type:is_empty() then
		parent_type = object_type:find("/elemType")
	end
	local dgr = parent_type:find("/propertyDiagram")
	if dgr:is_empty() then
		local sub_compart_type = parent_type:find("/subCompartType:has(/propertyRow[rowType = 'CheckBox+Button'])")
		local tmp_dgr = sub_compart_type:find("/propertyDiagram")
		if tmp_dgr:is_not_empty() and object_type:id() ~= sub_compart_type:id() then
			return tmp_dgr
		else
			return get_property_diagram(parent_type)
		end
	else
		return dgr
	end
end

function create_property_diagram(object_type, role_type)
	return lQuery.create("PropertyDiagram", {id = object_type:attr("id"), caption = object_type:attr("caption")}):link(role_type, object_type)
end

function create_property_row(attr, caption, value, row_parent, parent_role, object_type)
	return lQuery.create("PropertyRow", {id = attr, caption = caption, rowType = value, isEditable = "true", isReadOnly = "false", isFirstRespondent = "false"})
			:link(parent_role, row_parent)
			:link("compartType", object_type)
end

function set_property_row_attributes(property_row, attrs)
	property_row:attr(attrs)
end

function manage_property(property_row)
	print("manage property")
	property_row:log("rowType")
	local property_diagram = property_row:find("/propertyDiagram")
	local property_tab = property_row:find("/propertyTab")
	local called_diagram = property_row:find("/calledDiagram")
	if called_diagram:size() > 0 then
		print("in called diagram")
		local called_tab = called_diagram:find("/propertyTab")
		local called_rows = called_diagram:find("/propertyRow")
		called_diagram:remove_link("propertyRow")
				:remove_link("propertyTab")
				:delete()
		if property_tab:size() > 0 then
			print("property tab")
			local diagram = property_tab:find("/propertyDiagram")
			called_tab:link("propertyDiagram", diagram)
			called_rows:link("propertyTab", property_tab)	
		else
			called_rows:link("propertyDiagram", property_diagram)	
		end
		property_row:delete()
		if property_tab:find("/propertyRow"):size() == 0 then
			print("property tab delete")
			property_tab:delete()
		end
	elseif property_tab:find("/propertyRow"):size() == 1 then
		print("in tab")
		local res = manage_property_diagram(property_tab)
		if res == "not_deleted" then 
			property_tab:delete() 	
		end
	elseif property_diagram:find("/propertyRow"):size() == 1 and property_diagram:find("/propertyTab"):size() == 0 then
		print("in diagram")
		property_row:delete()
		property_diagram:delete()
	else
		print("in row")
		property_row:delete()
	end
	print("end manage property")

--		print("manage property emptpy")
--		local called_diagram = property_row:find("/calledDiagram"):log()
--		local row_parent, role = get_property_row_parent(property_row:find("/compartType"))
--		row_parent:log()
--		print("role " .. role)
--
--		if called_diagram:size() > 0 then
--			print("called diagram")
--			called_diagram:find("/propertyRow"):link(role, row_parent)
--			called_diagram:remove_link("propertyRow")
--			if role == "propertyDiagram" then
--				called_diagram:find("/propertyTab"):link(role, row_parent)
--			elseif role == "propertyTab" then
--				local parent_diagram = row_parent:find("/propertyDiagram")
--				called_diagram:find("/propertyTab"):link("propertyDiagram", parent_diagram)
--			end
--			delete_called_diagram(called_diagram)
--		end
--		property_row:delete() 
--	end
end

--function delete_called_diagram(property_row)
--	property_row:find("/calledDiagram"):delete()
--end

function manage_property_diagram(property_tab)
	local result = "not_deleted"
	local property_diagram = property_tab:find("/propertyDiagram")
	if property_diagram:find("/propertyTab"):size() == 1 and property_diagram:find("/propertyRow"):size() == 0 then
		property_diagram:delete()
		result = "deleted"
	end
return result
end

function get_selected_type()
	return d.get_selected_tree_node():find("/type")
end

function get_active_target_type()
	return utilities.active_elements():find("/target_type")
end

function delete_empty_property_tab(property_tab)
	local res = manage_property_diagram(property_tab)
	--print("delete tab res " .. res)
	if res == "not_deleted" then
		property_tab:delete()
	end
end

function close_configurator_form()
	log_button_press("Close")
	local active_elem = utilities.active_elements()
	active_elem:find("/compartment"):find("/compartType")
	relink_palette(active_elem)
	--if active_elem:filter(".Edge"):size() == 0 and active_elem:filter(".FreeLine"):size() == 0 and active_elem:filter(".Port"):size() == 0 then
	--	manage_element_properties(active_elem)
	--end
	add_command_without_diagram(active_elem, "OkCmd", {})
	utilities.close_form("configurator_form")
end

function relink_palette(elem)
	local palette_elem_type = elem:find("/target_type/paletteElementType")
	relink_palette_from_palette_elem_type(palette_elem_type)
end

function relink_palette_from_palette_elem_type(palette_elem_type)
	if palette_elem_type:is_not_empty() then
		local palette_type = palette_elem_type:find("/paletteType")
		local nr = tonumber(palette_elem_type:attr("nr")) or math.huge
		if palette_type:find("/paletteElementType"):size() > 1 then
			palette_elem_type:remove_link("paletteType", palette_type)	
			local palette_elems = palette_type:find("/paletteElementType")
			local min_nr = tonumber(palette_elems:filter(":first()"):attr("nr")) or math.huge
			local max_nr = tonumber(palette_elems:filter(":last()"):attr("nr")) or math.huge
			if nr < min_nr then
				palette_type:remove_link("paletteElementType", palette_elems)
				palette_elem_type:link("paletteType", palette_type)
				palette_type:link("paletteElementType", palette_elems)
			elseif nr > max_nr then
				palette_elem_type:link("paletteType", palette_type)
			else	
				local is_added = false
				palette_elems:each(function(tmp_palette_elem_type)
					if (tonumber(tmp_palette_elem_type:attr("nr")) or math.huge) >= nr and not(is_added) then
						tmp_palette_elem_type:remove_link("paletteType", palette_type)
						palette_elem_type:link("paletteType", palette_type)
						tmp_palette_elem_type:link("paletteType", palette_type)
						is_added = true
					elseif (tonumber(tmp_palette_elem_type:attr("nr")) or math.huge) >= nr and is_added then
						tmp_palette_elem_type:remove_link("paletteType", palette_type)
						tmp_palette_elem_type:link("paletteType", palette_type)	
					end		
				end)
			end
		end
		relink_palette_elements(palette_type)
		utilities.execute_cmd("AfterConfigCmd")
	end
end

function relink_palette_elements(palette_type)
	palette_type:find("/presentationElement"):each(function(palette)
		palette:find("/paletteElement"):delete()
		palette_type:find("/paletteElementType"):each(function(palette_elem_type)
			utilities.add_element_to_base(palette, "PaletteElement", "paletteElement", palette_elem_type)
		end)
		palette:find("/paletteElement")
	end)
end

function relink_compart_types()
	local tree = d.get_component_by_id("Tree")
	traverse_tree_node_children(tree:find("/treeNode"), "compartType")
end

function traverse_tree_node_children(tree_node, role)
	local parent_type = tree_node:find("/type")
	tree_node:find("/childNode"):each(function(child_node)	
		local compart_type = child_node:find("/type")
		relink_to_parent(parent_type, role, compart_type)
		traverse_tree_node_children(child_node, "subCompartType")
	end)
end

function relink_to_parent(parent, role, elem)
	parent:remove_link(role, elem)
		:link(role, elem)
end

function add_fiction_compart_for_check_box_button(compart_type)
--	local parent, role = utilities.get_obj_type_parent(compart_type)
--	compart_type:remove_link(role, parent)
--	local name = "CheckBoxFictitious" .. compart_type:attr("id")
--	local fiction_type = add_compart_type(name)
--	u.add_default_compart_style(name, name):link("compartType", fiction_type)
--	local sub_compart_types = compart_type:find("/subCompartType")
--	compart_type:remove_link("subCompartType", sub_compart_types)
--	fiction_type:link(role, parent)
--			:link("subCompartType", compart_type)
--			:link("subCompartType", sub_compart_types)
--	local tree_node = compart_type:find("/treeNode")
--	local parent_node = tree_node:find("/parentNode")
--	tree_node:remove_link("parentNode", parent_node)
--	local id = fiction_type:attr("id")
--	d.add_tree_node(parent_node, "parentNode", {id = id, text = id, expanded = "true"})
--			:link("typeWithMapping", fiction_type)
--			:link("childNode", tree_node)
--	utilities.refresh_form_component(d.get_component_by_id("Tree"))


	add_fiction_compart("CheckBoxFictitious" .. compart_type:attr("id"), compart_type)


--	if parent:filter(".ElemType"):is_not_empty() then
--		local compart = compart_type:find("/presentation")
--		compart_type:remove_link("presentation", compart)
--		fiction_type:link("presentation", compart)
--		local compart_style = compart_type:find("/compartStyle")
--		compart_type:remove_link("compartStyle", compart_style)
--		fiction_type:link("compartStyle", compart_style)
--	end
--	fiction_type:attr({concatStyle = compart_type:attr("concatStyle"), caption = compart_type:attr("caption")})
--	compart_type:attr({concatStyle = ""})
	return fiction_type
end

function add_fiction_copmart_for_text_field(object_type)
	--vajag pielikt fiction compartmentu
	add_fiction_compart("ASFictitious" .. object_type:attr("id"), object_type)

	local parent_type = object_type:find("/parentCompartType")
	local row = object_type:find("/propertyRow")
	local diagram = object_type:find("/propertyDiagram")
	object_type:remove_link("propertyRow")
			:remove_link("propertyDiagram")
	parent_type:link("propertyRow", row)
			:link("propertyDiagram", diagram)
end

function add_fiction_compart(name, compart_type)
	local parent, role = utilities.get_obj_type_parent(compart_type)
	compart_type:remove_link(role, parent)
	--local name = "CheckBoxFictitious" .. compart_type:attr("id")
	local fiction_type = add_compart_type(name)
	u.add_default_compart_style(name, name):link("compartType", fiction_type)
	local sub_compart_types = compart_type:find("/subCompartType")
	compart_type:remove_link("subCompartType", sub_compart_types)
	fiction_type:link(role, parent)
			:link("subCompartType", compart_type)
			:link("subCompartType", sub_compart_types)
	local tree_node = compart_type:find("/treeNode")
	local parent_node = tree_node:find("/parentNode")
	tree_node:remove_link("parentNode", parent_node)
	local id = fiction_type:attr("id")
	d.add_tree_node(parent_node, "parentNode", {id = id, text = id, expanded = "true"})
			:link("type", fiction_type)
			:link("childNode", tree_node)
	utilities.refresh_form_component(d.get_component_by_id("Tree"))

end

function add_fiction_compartment(compart_type)
	local role = "parentCompartType"
	local parent = compart_type:find("/" .. role)
	if parent:is_empty() then
		role = "elemType"
		parent = compart_type:find("/" .. role)
	end
	compart_type:remove_link(role, parent)
	local fiction_type = add_compart_type("ASFictitious" .. compart_type:attr("id"))
	if parent:filter(".ElemType"):is_not_empty() then
		local compart = compart_type:find("/presentation")
		compart_type:remove_link("presentation", compart)
		fiction_type:link("presentation", compart)
		local compart_style = compart_type:find("/compartStyle")
		compart_type:remove_link("compartStyle", compart_style)
		fiction_type:link("compartStyle", compart_style)
	end
	fiction_type:attr({concatStyle = compart_type:attr("concatStyle"), caption = compart_type:attr("caption")})
	compart_type:attr({concatStyle = ""})
	fiction_type:link(role, parent)
			:link("subCompartType", compart_type)
	return fiction_type
end

function close_dialog_form()
	log_button_press("Close")
	relink_property_diagram()
	utilities.close_form("dialog_form")
end

function relink_property_diagram()
	local prop_diagram = utilities.active_elements():find("/target_type/propertyDiagram")
	add_property_diagram_links(prop_diagram)
end

function add_property_diagram_links(prop_diagram)
	local tree = d.get_component_by_id("property_tree")
	link_property_diagram_elements(prop_diagram, tree:find("/treeNode"))
end

function link_property_diagram_elements(prop_parent, tree_node)
	tree_node:find("/childNode"):each(function(child_node)
		local prop_elem = child_node:find("/propertyElement")
		if prop_elem:filter(".PropertyRow"):is_not_empty() then
			prop_parent:remove_link("propertyRow", prop_elem)
					:link("propertyRow", prop_elem)
			local called_dgr = prop_elem:find("/calledDiagram")
			if called_dgr:is_not_empty() then
				link_property_diagram_elements(called_dgr, child_node:find("/childNode"))
			end
		else
			--local prop_tab = child_node:find("/propertyElement")
			if prop_elem:filter(".PropertyTab"):is_not_empty() then
				prop_parent:remove_link("propertyTab", prop_elem)
						:link("propertyTab", prop_elem)
				link_property_diagram_elements(prop_elem, child_node)
			end
		end
	end)
end

function default_keyshortcuts()
	add_configurator_comboBox({"Ctrl X", "Ctrl C", "Ctrl V", "Delete", "Enter", "Num Enter", "Application"})
end

function default_transformation_names()
	add_configurator_comboBox({"interpreter.CutCopyPaste.Cut", "interpreter.CutCopyPaste.Copy", "interpreter.Delete.Delete", "interpreter.CutCopyPaste.Paste", "interpreter.Properties.Properties"})
end

function process_popUpTable()
	local obj_type = get_type_from_tree_node()
	process_popUpTable_cells(obj_type:find("/popUpDiagramType"), obj_type, "elemType")
end

function process_popUpTable_cells(popUpDiagramType, obj_type, role)
	log_table({Name = "Context Menu"})
	if popUpDiagramType:size() > 0 then
		popUpDiagramType:find("/popUpElementType"):delete()
		popUpDiagramType:delete()
	end
	local popUpDiagramType = lQuery.create("PopUpDiagramType"):link(role, obj_type)
	add_popUpDiagram_type_from_table(popUpDiagramType, get_event_source())
end

function add_popUpDiagram_type_from_table(popUpDiagramType, event_source)
	local popUp_table = {}
	event_source:find("/vTableRow"):each(function(row)
		local tmp_table = {}
		if row:attr_e("deleted") ~= "true" then
			row:find("/vTableCell"):each(function(cell)
				table.insert(tmp_table, cell:attr_e("value"))
			end)
			table.insert(popUp_table, tmp_table)
		end
	end)
	table.sort(popUp_table, sort_context_menu_table_function)
	for _, row in ipairs(popUp_table) do
		lQuery.create("PopUpElementType", {id = row[1], caption = row[1], visibility = "true", nr = row[3], procedureName = row[2]}):link("popUpDiagramType", popUpDiagramType)
	end
end

function sort_context_menu_table_function(row1, row2)
	local nr1 = tonumber(row1[3])
	local nr2 = tonumber(row2[3])
	if nr1 ~= nil and nr2 ~= nil then
		if nr1 < nr2 then
			return row2
		end
	end
end

function fill_popUpTable(pop_up_table)
	fill_table(pop_up_table, "/popUpDiagramType/popUpElementType", {"id", "procedureName", "nr"})
end

function manage_palette_element()
	print("manage palette element")
end

function open_style_form()
	log_button_press("Symbol")
	local element = utilities.active_elements()
	local diagram = element:find("/graphDiagram")
	local name_compart = get_name_compart(element)
		utilities.add_tag(name_compart, "UnLinked", name_compart:id(), true)
		name_compart:remove_link("element", element)
	element:find("/compartment"):delete()
	make_configurator_element_compartments(element, element:find("/target_type"), "compartType")
	
	utilities.save_dgr_cmd(diagram)
	
	local style = element:attr("style")
	local target_type = element:find("/target_type")
	target_type:find("/element/graphDiagram"):each(function(dgr)
		utilities.save_dgr_cmd(dgr)
	end)
	local target_elems = target_type:find("/element[style = '" .. style .. "']")
	add_style_tags(target_elems)

	--diagram:link("command", utilities.execute_cmd("AfterConfigCmd"))
	--add_command(element, diagram, "OkCmd", {})
	
	add_command(element, diagram, "DefaultStyleCmd", {})
	add_command(element, diagram, "StyleDialogCmd", {info = ";lua_engine#lua.configurator.configurator.ok_style_dialog;lua_engine#lua.configurator.configurator.cancel_style_dialog"})
end

function add_style_tags(elems)
	utilities.add_tag(elems, "ConfiguratorStyle", "true")
end


function make_configurator_element_compartments(element, base_type, role_to_compart_type)
	base_type:find("/" .. role_to_compart_type):each(function(compart_type)
		if compart_type:attr("isGroup") == "true" then
			make_configurator_element_compartments(element, compart_type, "subCompartType")
		else
			local compart = lQuery.create("Compartment", {value = value,
									isGroup = compart_type:attr("isGroup"),
									element = element,
									compartStyle = compart_type:find("/compartStyle:first()")})
		end
	end)
end

function add_command(elem, diagram, command_name, attr_table)
	local cmd = lQuery.create(command_name, attr_table)
	cmd:link("element", elem)
		:link("graphDiagram", diagram)
	utilities.execute_cmd_obj(cmd)
end

function add_command_without_diagram(elem, command_name, attr_table)
	attr_table["element"] = elem
	attr_table["graphDiagram"] = elem:find("/graphDiagram")
	utilities.execute_cmd(command_name, attr_table)
end

function ok_style_dialog()
	--lQuery("OKStyleDialogEvent"):delete()
	log_button_press({Button = "OK", Context = "Style Box"})
	local dgr = utilities.current_diagram()
	local elem = utilities.active_elements()
	local style = elem:attr("style")
	local old_elem_style = utilities.make_elem_copy(elem:find("/elemStyle:first()"))
	utilities.execute_cmd("SaveStylesCmd", {graphDiagram = dgr})
	utilities.execute_cmd("AfterConfigCmd", {graphDiagram = dgr})
	local new_elem_style = elem:find("/elemStyle:first()")
	local list = utilities.get_object_difference(new_elem_style, old_elem_style)
	local target_type = elem:find("/target_type")	
	target_type:find("/element/graphDiagram"):each(function(target_dgr)
		utilities.save_dgr_cmd(target_dgr)
	end)
	local target_elems = elem:find("/target_type/element:has(/tag[key = 'ConfiguratorStyle'][value = 'true'])")
	utilities.set_elem_style(target_elems, list)
	if elem:filter(".Node"):size() > 0 or elem:filter(".FreeBox"):size() > 0 or elem:filter(".Edge"):size() > 0 then
		local name_compart = get_unlinked_box_freebox_compartments(elem)
		elem:find("/compartment"):delete()
		elem:link("compartment", name_compart)
			--:link("compartment", attr_compart)
	end
	remove_tags(elem)
end

function remove_tags(source)
	source:find("/target_type/element/tag[key = 'ConfiguratorStyle'][value = 'true']"):delete()
end

function cancel_style_dialog()
	log_button_press({Button = "Cancel", Context = "Style Box"})
	local elem = utilities.active_elements()
	local name_compart = get_unlinked_box_freebox_compartments(elem)
	local name_value = elem:find("/target_type"):attr_e("id")
	elem:find("/compartment"):delete()
	elem:link("compartment", name_compart)
	name_compart:attr({input = name_value, value = name_value})
	update_diagram_names_from_compart(name_compart)
	remove_tags(elem)
end

function get_unlinked_box_freebox_compartments(elem)
	--return elem:find("/elemType/compartType[id = 'AS#Name']/compartment")--, elem:find("/elemType/compartType[id = 'AS#Attributes']/compartment:not(:has(/element))")
	local key = lQuery("Tag[key = 'UnLinked']")
	local compart = key:find("/thing")
	key:delete()
	return compart
end

function make_dialog_form()
	log_button_press("Dialog")
	local form = d.add_form({id = "dialog_form", caption = "Dialog Properties", minimumWidth = 400, minimumHeight = 300})
	local prop_elem = get_active_target_type():find("/propertyDiagram")
	local form_horizontal_box = d.add_component(form, {id = "form_horizontal_box", horizontalAlignment = 1}, "D#HorizontalBox")
	local first_row = d.add_component(form_horizontal_box, {id = "vertical_box", verticalAlignment = -1}, "D#VerticalBox")
	local second_row = d.add_component(form_horizontal_box, {id = "vertical_box2", verticalAlignment = -1}, "D#VerticalBox")
	make_dialog_component_box(first_row)	
	
	local properties_group = d.add_component(second_row, {id = "dialog_properties_box", caption = "Form Properties"}, "D#GroupBox")
	d.add_row_labeled_field(properties_group, {caption = "Name"}, {id = "prop_elem_name", text = prop_elem:attr("id")}, {id = "row_style_name"}, "D#InputField", 
	{FocusLost = "lua.configurator.configurator.update_property_element_name", Change = "lua.configurator.configurator.refresh_property_element_tree_node"})
	d.add_row_labeled_field(properties_group, {caption = "Set Focused"}, {id = "isFirstRespondent", checked = "false", enabled = "false"}, {id = "row_isFirstRespondent"}, 
										"D#CheckBox", {Change = "lua.configurator.configurator.set_first_respondent"})	
	d.add_row_labeled_field(properties_group, {caption = "Is Read Only"}, {id = "isReadOnly", checked = "false", enabled = "false"}, {id = "row_isReadOnly"}, 
										"D#CheckBox", {Change = "lua.configurator.configurator.set_is_read_only"})
	add_input_field_event_function(properties_group, "Height", "height", prop_elem, {FocusLost = "lua.configurator.configurator.update_property_element_size", 
												Change = "lua.configurator.configurator.check_dialog_size"})
	add_input_field_event_function(properties_group, "Width", "width", prop_elem, {FocusLost = "lua.configurator.configurator.update_property_element_size", 
												Change = "lua.configurator.configurator.check_dialog_size"})

	--d.add_row_labeled_field(properties_group, {caption = "Label Alignment"}, {id = "alignment", editable = "true", enabled = "true", text = prop_elem:attr("alignment")},
	--{id = "row_alignment"}, "D#ComboBox", {Change = "lua.configurator.configurator.set_alignment", DropDown = "lua.configurator.configurator.get_alignment_options"})	
	
	local translet_group = d.add_component(second_row, {id = "dialog_translet_box", caption = "Translets"}, "D#GroupBox")
	build_translet_box(translet_group, false)
	local translet_group = d.add_component(second_row, {id = "dialog_translet_box2", caption = "Translets"}, "D#HorizontalBox")
	local button_box = d.add_component(form, {id = "dialog_button_box", horizontalAlignment = 1}, "D#HorizontalBox")
	local close_button = d.add_button(button_box, {id = "dialog_close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_dialog_form()"})
													:link("defaultButtonForm", lQuery("D#Form[id = 'dialog_form']"))
	d.delete_event()
	d.show_form(form)
end

function set_is_read_only()
	local prop_tree = d.get_component_by_id("property_tree")
	local selected_node = prop_tree:find("/selected")
	local prop_row = selected_node:find("/propertyElement")
	local check_box, ev = get_event_source()
	if ev:size() == 1 then
		prop_row:attr({isReadOnly = check_box:attr("checked")})
	end
	log_configurator_field("readOnly", {ObjectType = utilities.get_class_name(prop_row), isReadOnly = check_box:attr("checked")})
	d.delete_event()
end

function build_translet_box(translet_group, is_refresh_needed)
	if translet_group == nil then
		translet_group = d.get_component_by_id("dialog_translet_box")
	end
	translet_group:find("/component"):delete()
	local group_box = d.get_component_by_id("dialog_properties_box")
	local tree = d.get_component_by_id("property_tree")
	local selected_node = tree:find("/selected")
	local prop_elem = selected_node:find("/propertyElement")
	if prop_elem:filter(".PropertyDiagram"):is_not_empty() or selected_node:is_empty() then
		if selected_node:is_empty() then
			prop_elem = tree:find("/treeNode"):find("/propertyElement")
		end
		add_dialog_translet_field(prop_elem, translet_group, "onOpen", "onOpen")
		add_dialog_translet_field(prop_elem, translet_group, "onClose", "onClose")
		group_box:attr({caption = "Form Properties"})
	elseif prop_elem:filter(".PropertyTab"):is_not_empty() then
		add_dialog_translet_field(prop_elem, translet_group, "onShow", "onShow")
		group_box:attr({caption = "Tab Properties"})
	elseif prop_elem:filter(".PropertyRow"):is_not_empty() then
		add_dialog_translet_field(prop_elem, translet_group, "onFocusLost", "onFocusLost")
		add_dialog_translet_field(prop_elem, translet_group, "onChange", "onChange")
		add_dialog_translet_field(prop_elem, translet_group, "isReadOnly", "procIsReadOnly")
		--if prop_elem:attr("rowType") == "ComboBox" then
		--	add_dialog_translet_field(prop_elem, translet_group, "onDropDown", "onDropDown")
		--end
		if prop_elem:attr("rowType") == "TextArea+DBTree" then
			add_dialog_translet_field(prop_elem, translet_group, "onClick", "Click")
		end
		group_box:attr({caption = "Row Properties"})

	end
	local height = d.get_component_by_id("height"):attr({text = prop_elem:attr_e("height")})
	local width = d.get_component_by_id("width"):attr({text = prop_elem:attr_e("width")})
	local name_field = d.get_component_by_id("prop_elem_name"):attr({text = prop_elem:attr("id")})
	if is_refresh_needed then
		--utilities.refresh_form_component(name_field)
		--utilities.refresh_form_component(height)
		--utilities.refresh_form_component(width)
		utilities.refresh_form_component(translet_group)
		utilities.refresh_form_component(group_box)
	end
end

function add_dialog_translet_field(prop_elem, container, caption, attr_name)
	local handler = prop_elem:find("/propertyEventHandler[eventType = " .. attr_name .. "]")
	return d.add_row_labeled_field(container, {caption = caption}, {id = attr_name, text = handler:attr_e("procedureName")}, 
	{id = "row_" .. attr_name}, "D#InputField", {FocusLost = "lua.configurator.configurator.update_prop_elem_handler"})
end

function update_prop_elem_handler()
	local tree = d.get_component_by_id("property_tree")
	local selected_node = tree:find("/selected")
	local prop_elem = selected_node:find("/propertyElement")
	local event_type, proc_name = get_event_source_attrs("text")
	log_configurator_field("PopUpElement", {ObjectType = utilities.get_class_name(prop_elem), [event_type] = proc_name})
	local handler = prop_elem:find("/propertyEventHandler[eventType = " .. event_type .. "]")
	if proc_name ~= "" then
		if handler:is_empty() then
			prop_elem:link("propertyEventHandler", lQuery.create("PropertyEventHandler", {eventType = event_type, procedureName = proc_name}))
		else
			handler:attr({procedureName = proc_name})
		end
	else
		handler:delete()
	end
end

function set_alignment()
	local prop_tree = d.get_component_by_id("property_tree")
	local selected_node = prop_tree:find("/selected")
	local prop_diagram = selected_node:find("/propertyDiagram")
	if prop_diagram:is_not_empty() then
		prop_diagram:attr(get_event_source_attrs("text"))
	end
end

function get_alignment_options()
	add_configurator_comboBox({"Left", "Center", "Right"})
end

function rename_tab(prop_elem, val)
	local tab = d.get_component_by_id("Tree"):find("/selected/type/propertyRow/propertyTab")
	if prop_elem:id() == tab:id() then
		local row = d.get_component_by_id("row_id")
		local field = row:find(":has(/component[id = 'label_box']/component[caption = 'Tab'])"):find("/component/component[id = 'id']")
		field:attr({text = val})
		utilities.refresh_form_component(field)
	end
end

function set_first_respondent()
	local prop_tree = d.get_component_by_id("property_tree")
	local selected_node = prop_tree:find("/selected")
	local prop_row = selected_node:find("/propertyElement")
	local check_box, ev = get_event_source()
	log_configurator_field("FirstRespondent", {ObjectType = utilities.get_class_name(prop_row), isFirstRespondent = check_box:attr("checked")})
	if ev:size() == 1 then
		if check_box:attr("checked") == "true" then
			local prop_parent = prop_row:find("/propertyDiagram")
			if prop_parent:is_empty() then
				prop_parent = prop_row:find("/propertyTab")		
			end
			local focused_row = prop_parent:find("/propertyRow[isFirstRespondent = true]")
			if focused_row:id() ~= prop_row:id() then
				focused_row:attr({isFirstRespondent = "false"})
					:find("/treeNode"):attr({text = focused_row:attr("id")})
				prop_row:attr({isFirstRespondent = "true"})
				selected_node:attr({text = prop_row:attr("id") .. "(focused)"})
			end
		else
			prop_row:attr({isFirstRespondent = "false"})
			selected_node:attr({text = prop_row:attr("id")})
		end
		utilities.refresh_form_component(prop_tree)
	end
	d.delete_event()
end

function dialog_tree_node_moved()
	local ev = lQuery("D#Event")
	local old_parent = ev:find("/previousParent")
	local selected_node = ev:find("/treeNode")
	d.delete_event(ev)
	local new_parent = selected_node:find("/parentNode")
	if new_parent:id() ~= old_parent:id() or new_parent:is_empty() then
		if new_parent:is_empty() then
			selected_node:remove_link("tree", d.get_tree_from_tree_node(selected_node))
					:link("parentNode", old_parent)
		else
			selected_node:remove_link("parentNode", new_parent)
					:link("parentNode", old_parent)
		end
		utilities.refresh_form_component(d.get_component_by_id("property_tree"))
	end	
end

function make_dialog_component_box(container)
	local component_vertical_box = d.add_component(container, {id = "diagram_component_vertical_box", horizontalAlignment = -1}, "D#VerticalBox")
	local tree = d.add_component(component_vertical_box, {id = "property_tree", minimumHeight = 400, draggableNodes = "true"}, "D#Tree")
		d.add_event_handlers(tree, {TreeNodeMove = "lua.configurator.configurator.dialog_tree_node_moved",
					TreeNodeSelect = "lua.configurator.configurator.dialog_tree_node_changed"})
	fill_property_diagram_tree(tree)
	--d.add_component(component_vertical_box, {caption = "Property Diagram"}, "D#Label")
	--d.add_component_with_handler(component_vertical_box, {id = 'property_diagrams', maximumWidth = 250},, "D#ComboBox", {DropDown = "lua.configurator.configurator.get_property_diagrams", Change = "lua.configurator.configurator.update_property_listboxes"})
--		d.add_component(component_vertical_box, {caption = "Diagram Components"}, "D#Label")
--		local component_horizontal_box = d.add_component(component_vertical_box, {id = "component_horizontal_box", horizontalAlignment = 1}, "D#HorizontalBox")
--			d.add_component_with_handler(component_horizontal_box, {id = 'diagram_components', minimumWidth = 250, minimumHeight = 150}, "D#ListBox", {})
--			d.add_button(component_horizontal_box, {id = "component_add", caption = "+"}, {Click = "lua.configurator.configurator.component_add()"})
--			d.add_button(component_horizontal_box, {id = "component_add", caption = "-"}, {Click = "lua.configurator.configurator.component_remove()"})

--		local component_button_box = d.add_component(component_vertical_box, {id = "component_button_box", horizontalAlignment = 0}, "D#HorizontalBox")
--			d.add_button(component_button_box, {id = "component_add", caption = "+"}, {Click = "lua.configurator.configurator.component_add()"})
--			d.add_button(component_button_box, {id = "component_add", caption = "-"}, {Click = "lua.configurator.configurator.component_remove()"})

		--d.add_component(component_vertical_box, {caption = "Component Components"}, "D#Label")
		--local component_components_horizontal_box = d.add_component(component_vertical_box, {id = "component_components_horizontal_box", horizontalAlignment = 1}, "D#HorizontalBox")
		--	d.add_component_with_handler(component_components_horizontal_box, {id = 'diagram_component_components', minimumWidth = 250, minimumHeight = 150}, "D#ListBox", {})
		--	d.add_button(component_components_horizontal_box, {id = "component_add", caption = "+"}, {Click = "lua.configurator.configurator.component_add()"})
		--	d.add_button(component_components_horizontal_box, {id = "component_add", caption = "-"}, {Click = "lua.configurator.configurator.component_remove()"})
end

function dialog_tree_node_changed()
	build_translet_box(translet_group, true)
	local selected_node = d.get_component_by_id("property_tree"):find("/selected")
	local check_box = d.get_component_by_id("isFirstRespondent")
	local is_read_only_check_box = d.get_component_by_id("isReadOnly")
	local prop_row = selected_node:find("/propertyElement"):filter(".PropertyRow")
	if prop_row:is_not_empty() then
		check_box:attr({enabled = "true", checked = prop_row:attr("isFirstRespondent")})
		is_read_only_check_box:attr({enabled = "true", checked = prop_row:attr("isReadOnly")})
	else
		local prop_diagram = selected_node:find("/propertyElement"):filter(".PropertyDiagram")
		if prop_diagram:is_not_empty() then
			local height_field = d.get_component_by_id("height"):attr({text = prop_diagram:attr("height")})
			local width_field = d.get_component_by_id("width"):attr({text = prop_diagram:attr("width")})
		end
		check_box:attr({checked = "false", enabled = "false"})
		is_read_only_check_box:attr({checked = "false", enabled = "false"})
	end
	d.delete_event(lQuery("D#TreeNodeSelectEvent"))
	utilities.refresh_form_component(check_box)
	utilities.refresh_form_component(is_read_only_check_box)
	--d.delete_event()
end

function fill_property_diagram_tree(tree)
	local prop_dgr = utilities.active_elements():find("/target_type/propertyDiagram")
	local dgr_value = prop_dgr:attr_e("id")
	local treeNode = d.add_tree_node(tree, "tree", {id = "propertyDiagram", text = dgr_value, expanded = "true", propertyElement = prop_dgr})
	make_diagram_children(prop_dgr, treeNode)
end

function make_diagram_children(source, parent_node)
	if source:filter(".PropertyDiagram"):size() > 0 then
		process_property_object(source, parent_node, "propertyTab", "id", "propertyElement")
		process_property_object(source, parent_node, "propertyRow", "id", "propertyElement")
	elseif source:filter(".PropertyTab"):size() > 0 then
		process_property_object(source, parent_node, "propertyRow", "id", "propertyElement")
	elseif source:filter(".PropertyRow"):size() > 0 then
		process_property_object(source, parent_node, "calledDiagram", "id", "propertyElement")
	end
end

function process_property_object(source, parent_node, role, attr_name, role_from_tree_node)
	source:find("/" .. role):each(function(obj)
		local val = obj:attr_e(attr_name)
		local first_respondent = obj:attr("isFirstRespondent") 
		if first_respondent ~= nil and first_respondent ~= "false" then
			val = val .. "(focused)"
		end
		local parent = d.add_tree_node(parent_node, "parentNode", {id = role, text = val, expanded = "true"}):link(role_from_tree_node, obj)
		parent:find("/" .. role_from_tree_node)
		make_diagram_children(obj, parent)
	end)	
end

function make_compartType_tree_nodes1(treeNode, source_type, path, tree_link)
	if source_type ~= nil then
		source_type:find(path):each(function(obj_type)
			local caption = obj_type:attr("caption")
			local added_node = d.add_tree_node(treeNode, tree_link, {id = caption, text = caption, expanded = "true"}):link("type", obj_type)
			make_compartType_tree_nodes(added_node, obj_type, "/subCompartType", "parentNode")
		end)
	end
end

function make_free_component_box(container)
	local right_vertical_box = d.add_component(container, {id = "free_component_vertical_box", horizontalAlignment = -1}, "D#VerticalBox")	
		d.add_component(right_vertical_box, {caption = "Components"}, "D#Label")
		d.add_component_with_handler(right_vertical_box, {id = 'components'}, "D#ListBox", {})
end

function get_property_diagrams()
	add_lQuery_configurator_comboBox(make_combo_box_item_table(utilities.active_elements():find("/target_type/propertyDiagram"), "id"))
end

function update_property_listboxes()
	local listbox1 = d.get_component_by_id("diagram_components")
	add_items(listbox1, get_property_diagram_components())
	d.execute_d_command(listbox1, "Refresh")
	local listbox2 = d.get_component_by_id("diagram_component_components")
	local listbox3 = d.get_component_by_id("free_component_vertical_box")
end

function add_items(box, value_table)
	for _, value in pairs(value_table) do
		box:link("item", lQuery.create("D#Item", {value = value}))
	end
end

function get_property_diagram_components()
	local list = {}
	get_property_diagram_items("/target_type/propertyDiagram/propertyTab", "caption", list)
	get_property_diagram_items("/target_type/propertyDiagram/propertyRow", "id", list)
return list
end

function get_property_diagram_items(path, attr, list)
	utilities.active_elements():find(path):each(function(obj)
		obj = lQuery(obj)
		table.insert(list, obj:attr_e(attr))
	end)	
end



function add_diagram_popUp()
	local current_diagram = utilities.current_diagram()
	local diagram_type = current_diagram:find("/target_type")
	local form = d.add_form({id = "form", caption = "Diagram Context Menus", minimumWidth = 455, minimumHeight = 150, maximumHeight = 300})
	local tab_container = d.add_component(form, {id = "tab_container"}, "D#TabContainer")
	local empty_tab = d.add_component(tab_container, {id = "procDynamicPopUpE", caption = "Diagram", minimumWidth = 420, minimumHeight = 250}, "D#Tab")
	local empty_collection_translet = diagram_type:find("/translet[extensionPoint = 'procDynamicPopUpE']")
	add_input_field_event_function(empty_tab, "Dynamic Context Menu", "procedureName", empty_collection_translet, {FocusLost = "lua.configurator.configurator.set_dynamic_pop_up_dgr"})

	local collection_tab = d.add_component(tab_container, {id = "procDynamicPopUpC", caption = "Collection", minimumWidth = 300, minimumHeight = 250}, "D#Tab")
	local collection_translet = diagram_type:find("/translet[extensionPoint = 'procDynamicPopUpC']")
	add_input_field_event_function(collection_tab, "Dynamic Context Menu", "procedureName", collection_translet, {FocusLost = "lua.configurator.configurator.set_dynamic_pop_up_dgr"})

	local empty_table = add_main_popUp_table_header(empty_tab, "lua.configurator.configurator.process_empty_diagram_popUpTable", "Static Context Menu")
	local collection_table = add_main_popUp_table_header(collection_tab, "lua.configurator.configurator.process_collection_diagram_popUpTable", "Static Context Menu")

	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")
		local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	fill_table_from_obj(current_diagram, collection_table, "/target_type/rClickCollection/popUpElementType", {"id", "procedureName", "nr"})
	fill_table_from_obj(current_diagram, empty_table, "/target_type/rClickEmpty/popUpElementType", {"id", "procedureName", "nr"})
	d.show_form(form)
end

function set_dynamic_pop_up_dgr()
	local attr, val = get_event_source_attrs("text")
	local active_tab_name = get_event_source():find("/container/container/container"):attr("id")
	local diagram_type = utilities.current_diagram():find("/target_type")
	local translet = diagram_type:find("/translet[extensionPoint = '" .. active_tab_name .. "']")
	if val == "" then
		translet:delete()
	else
		if translet:is_empty() then
			cu.add_translet_to_obj_type(diagram_type, active_tab_name, val)
		else
			translet:attr({procedureName = val})
		end
	end
end

function close_form()
	log_button_press("Close")
	utilities.close_form("form")
end

function close_called_form()
	log_button_press("Close")
	utilities.close_form ("called_form")
end

function process_empty_diagram_popUpTable()
	process_diagram_popUpTable("/rClickEmpty", "eType")
end

function process_collection_diagram_popUpTable()
	process_diagram_popUpTable("/rClickCollection", "cType")
end

function process_diagram_popUpTable(path, role)
	local diagram_type = utilities.current_diagram():find("/target_type")
	process_popUpTable_cells(diagram_type:find(path), diagram_type, role)
end

function add_default_popUp_table_header(container, table_id, focus_lost_function, table_name)
	--local label = d.add_component(container, {id = "table_id", caption = table_name}, "D#Label")
	local group_box = d.add_component(container, {id = "table_group_box", caption = table_name}, "D#GroupBox")
	local table = d.add_component(group_box, {id = table_id, editable = "true", insertButtonCaption = "Add", deleteButtonCaption = "Delete"}, "D#VTable") 
	d.add_event_handlers(table, {FocusLost = focus_lost_function})
	local name_column = d.add_columnType(table, {caption = "ItemName", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
	local item_column = d.add_columnType(table, {caption = "TransformationName", editable = "true", horizontalAlignment = -1}, "D#ComboBox", {editable = "true"}, {DropDown = "lua.configurator.configurator.default_transformation_names"})
	local nr_column = d.add_columnType(table, {caption = "Nr", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
	--local should_be_included = d.add_columnType(table, {caption = "ShouldBeIncluded", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
return table
end

--keyboard shortcut
function add_diagram_key_shortcuts()
	local form = d.add_form({id = "form", caption = "Diagram Key Shortcuts", minimumWidth = 455, minimumHeight = 150, maximumHeight = 300})
	local tab_container = d.add_component(form, {id = "tab_container"}, "D#TabContainer")
	local empty_tab = d.add_component(tab_container, {id = "diagram_tab", caption = "Diagram", minimumWidth = 420, minimumHeight = 250}, "D#Tab")
	local collection_tab = d.add_component(tab_container, {id = "collection_tab", caption = "Collection", minimumWidth = 300, minimumHeight = 250}, "D#Tab")

	local empty_table = add_key_shortcuts(empty_tab, "element_key_shortcuts", "lua.configurator.configurator.process_empty_diagram_key_shortcut", "")
	local collection_table = add_key_shortcuts(collection_tab, "element_key_shortcuts", "lua.configurator.configurator.process_collection_diagram_key_shortcut", "")

	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")
		local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	fill_table_from_obj(utilities.current_diagram(), empty_table, "/target_type/eKeyboardShortcut", {"key", "procedureName"})
	fill_table_from_obj(utilities.current_diagram(), collection_table, "/target_type/cKeyboardShortcut", {"key", "procedureName"})
	d.show_form(form)
end

function process_empty_diagram_key_shortcut()
	process_shortcut_table_header(utilities.current_diagram():find("/target_type"), "eType", "/eKeyboardShortcut")
end

function process_collection_diagram_key_shortcut()
	process_shortcut_table_header(utilities.current_diagram():find("/target_type"), "cType", "/cKeyboardShortcut")
end

--toolbox
function add_diagram_toolbar()
	local form = d.add_form({id = "form", caption = "Toolbar", minimumWidth = 455, minimumHeight = 150, maximumHeight = 300})
	local toolbar_table = add_toolbar(form, "toolbar", "lua.configurator.configurator.process_diagram_toolbar")
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")
		local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	fill_table_from_obj(utilities.current_diagram():find("/target_type/toolbarType"), toolbar_table, "/toolbarElementType", {"caption", "picture", "procedureName"})
	d.show_form(form)
end

function add_toolbar(container, id, function_name, table_name)
	local table = d.add_component(container, {id = id, editable = "true", insertButtonCaption = "Add", deleteButtonCaption = "Delete"}, "D#VTable") 
	d.add_event_handlers(table, {FocusLost = function_name})
	local name_column = d.add_columnType(table, {caption = "Name", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
	local picture_column = d.add_columnType(table, {caption = "Picture", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
	local procedure_column = d.add_columnType(table, {caption = "TransformationName", editable = "true", horizontalAlignment = -1}, "D#TextBox", {editable = "true"})
return table:attr({minimumWidth = 150, minimumHeight = 150})
end

function process_diagram_toolbar()
	local toolbar_table = {}
	local diagram_type = utilities.current_diagram():find("/target_type")
	local toolbar = diagram_type:find("/toolbarType")
	if toolbar:size() > 0 then
		toolbar:find("/toolbarElementType"):delete()
	else
		toolbar = lQuery.create("ToolbarType"):link("graphDiagramType", diagram_type)
	end
	get_event_source():find("/vTableRow"):each(function(row)
		local tmp_table = {}
		if row:attr_e("deleted") ~= "true" then
			row:find("/vTableCell"):each(function(cell)
				cell = lQuery(cell)
				table.insert(tmp_table, cell:attr_e("value"))
			end)
			table.insert(toolbar_table, tmp_table)
		end
	end)
	for i, row in pairs(toolbar_table) do  
		lQuery.create("ToolbarElementType", {id = row[1], caption = row[1], picture = row[2], procedureName = row[3]}):link("toolbarType", toolbar)
	end
	make_toolbar(diagram_type)
	utilities.execute_cmd("OkCmd")
end

function make_toolbar(diagram_type)
	local diagrams = diagram_type:find("/graphDiagram")
	local toolbar = diagrams:find("/toolbar")
	toolbar:find("/toolbarElement"):delete()
	toolbar:delete()
	diagrams:each(function(diagram)	
		utilities.add_toolbar_to_diagram(diagram, diagram_type)
		utilities.execute_cmd("AfterConfigCmd", {graphDiagram = diagram})
	end)
end

function update_diagram_names_from_compart(compart)
	local value = compart:attr_e("input")
	local elem = utilities.get_element_from_compartment(compart)
	local diagram = elem:find("/target")
	if diagram:is_not_empty() then
		diagram:attr({caption = value})
		diagram:find("/target_type"):attr({id = value})
	end
end

function set_attribute_compart(elem)
	local attr_compart_type = elem:find("/elemType/compartType:has([id = 'AS#Attributes'])")
	local compart_table = {}
	elem:find("/compartment"):each(function(compart)
		if compart:find(":has(/compartType[id = 'AS#Attributes'])/element/elemType[id = 'Box']"):size() > 0 then
			local compart_style = compart:find("/compartStyle")
			local compart_type_caption = compart:find("/target_type"):attr_e("id")
			local value = get_compart_sub_tree(compart, "")
			compart:attr({input = compart_type_caption, value = compart_type_caption})
			compart:remove_link("element", elem)
		end
	end)
	local compart_table = {}
	make_compart_type_table(elem:find("/target_type"), "/compartType", compart_table)
	for i, compart in pairs(compart_table) do
		local compart_type = compart:find("/target_type")
		local val = ""
		local start, finish = string.find(compart_type:attr("id"), "ASFictitious")
		if start == 1 and finish == 12 then
			val = get_compart_sub_tree(compart_type, "")
		else
			val = compart_type:attr("id") .. get_compart_sub_tree(compart_type, "\n   ")
		end
		compart:link("element", elem)
		if compart:attr("isInvisible") == "true" then
			compart:attr({input = "", value = val})
		else
			compart:attr({input = val, value = val})
		end
	end
end

function get_compart_sub_tree(compart_type, distance)
	local tmp = ""
	compart_type:find("/subCompartType"):each(function(sub_compart_type)
		local start, finish = string.find(sub_compart_type:attr("id"), "ASFictitious")
		if start == 1 and finish == 12 then
			tmp = tmp .. get_compart_sub_tree(sub_compart_type, distance)
		else
			local new_distance = ""
			if distance == "" then
				new_distance = "\n" .. "   "
			else
				new_distance = distance .. "   "
			end
			tmp = tmp .. distance .. sub_compart_type:attr("id") .. get_compart_sub_tree(sub_compart_type, new_distance)
		end
	end)
	return  tmp
end

function make_compart_type_table(elem_type, path, compart_type_table)
	elem_type:find(path):each(function(compart_type)
		local compart = compart_type:find("/presentation")
		if compart:is_not_empty() then
			table.insert(compart_type_table, compart)
		end
	end)
end

function get_configurator_box_compart(id, elem, get_compart_func)
	local compart = get_compart_func(elem)
	if compart:size() == 0 then
		compart = elem:find("/elemType/compartType/compartment:has(/compartType[id = '" .. id .. "'])")
		compart:link("element", elem)
	end
return compart
end

function set_compart_names(parent, role, prefix)
	local attr_value = ""
	parent:find(role):each(function(compart_type)
		compart_type = lQuery(compart_type)
		attr_value = attr_value .. prefix .. concat_compartment_names(compart_type, attr_value) .. set_compart_names(compart_type, "/subCompartType", prefix .. "\t")
	end)
return attr_value
end

function concat_compartment_names(compart_type)
	local attr_value = ""
	local compart_name = compart_type:attr_e("caption")
	if compart_name ~= "" then
		return attr_value .. compart_name .. "\n"
	end
end

function add_diagram_style_field(container, label, field_id, object_type)
	add_input_field_event_function(container, label, field_id, object_type, {FocusLost = "lua.configurator.configurator.update_diagram_style_input_field", Change = "lua.configurator.configurator.check_field_value"})
end
	
function add_diagram_style_field_text(container, label, field_id, object_type)
	add_input_field_event_function(container, label, field_id, object_type, {FocusLost = "lua.configurator.configurator.update_diagram_style_input_field"})
end

function get_selected_diagram_style()
	return lQuery("D#ListBox[id = 'diagram_style_list_box']"):find("/selected/style")
end

function update_diagram_style_input_field()
	local attr, value = get_event_source_attrs("text")
	local diagram_style = get_selected_diagram_style()
	diagram_style:attr({[attr] = value})
	if attr == "id" then
		local list_box = lQuery("D#ListBox[id = 'diagram_style_list_box']")
		list_box:find("/selected"):attr({value = value})
		utilities.refresh_form_component(list_box)
	end
	delete_event()
end

function diagram_style()
	local form = d.add_form({id = "form", caption = "Diagram Styles", minimumWidth = 300, minimumHeight = 100})
	local row = d.add_component(form, {id = "list_box_edit_button_row", horizontalAlignment = 0, verticalAlignment = -1}, "D#HorizontalBox")
		local list_box = d.add_component(row, {id = "diagram_style_list_box", horizontalAlignment = 0, minimumWidth = 220, minimumHeight = 150}, "D#ListBox")
		--d.add_event_handlers(list_box, {Change = "lua.configurator.configurator.change_style()"})
		local vertical_row = d.add_component(row, {id = "vertical_box", verticalAlignment = -1}, "D#VerticalBox")
		local edit_button = d.add_button(vertical_row, {id = "edit_style_button", caption = "Style"}, {Click = "lua.configurator.configurator.edit_diagram_style()"})
		--local edit_name_button = d.add_button(vertical_row, {id = "edit_style_name_button", caption = "Rename"}, {Click = "lua.configurator.configurator.edit_diagram_style_name()"})
	local button_row = d.add_component(form, {id = "add_delete_buttons", horizontalAlignment = -1}, "D#HorizontalBox")
		local add_button = d.add_button(button_row, {id = "add_style_button", caption = "Add"}, {Click = "lua.configurator.configurator.add_diagram_style()"})
		local delete_button = d.add_button(button_row, {id = "delete_style_button", caption = "Delete"}, {Click = "lua.configurator.configurator.delete_diagram_style()"})
		local close_row = d.add_component(button_row, {id = "add_delete_buttons", horizontalAlignment = 1}, "D#HorizontalBox")
			local close_button = d.add_button(close_row, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"})
	fill_diagram_style_list_box(list_box)
	if list_box:find("/item"):size() == 1 then
		delete_button:attr({enabled = "false"})
	end
	d.show_form(form)
end

function fill_diagram_style_list_box(list_box)
	utilities.current_diagram():find("/target_type"):find("/graphDiagramStyle"):each(function(diagram_style)
		list_box:link("item", lQuery.create("D#Item", {value = diagram_style:attr("id")}):link("style", diagram_style))
	end)
	list_box:link("selected", list_box:find("/item:first()"))
end

function add_diagram_style()
	local diagram_type = utilities.current_diagram():find("/target_type")
	local name = cu.generate_unique_id("Style", diagram_type, "graphDiagramStyle")
	local diagram_style = u.add_default_graph_diagram_style(diagram_type)
	diagram_style:attr({id = name, caption = name})
	local form = d.add_form({id = "form", caption = "Diagram Style", minimumWidth = 300, minimumHeight = 200})
		add_diagram_style_field_text(form, "Name", "id", diagram_style)
		add_diagram_style_field(form, "Layout Mode", "layoutMode", diagram_style)
		add_diagram_style_field(form, "Layout Algorithm", "layoutAlgorithm", diagram_style)
		add_diagram_style_field(form, "Background Color", "bkgColor", diagram_style)
		add_diagram_style_field(form, "Screen Zoom", "screenZoom", diagram_style)
		add_diagram_style_field(form, "Print Zoom", "printZoom", diagram_style)
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_diagram_style_extra_form()"}):link("defaultButtonForm", form)
	local list_box = lQuery("D#ListBox[id = 'diagram_style_list_box']")
	local item = lQuery.create("D#Item", {value = name}):link("style", diagram_style)
	list_box:remove_link("selected")
		:link("item", item)
		:link("selected", item)
	utilities.refresh_form_component(list_box)
	if diagram_type:find("/graphDiagramStyle"):size() > 1 then
		utilities.refresh_form_component(d.get_component_by_id("delete_style_button"):attr({enabled = "true"}))
	end
	delete_event()
	d.show_form(form)
--vajag refresot delete pogu
end

function delete_diagram_style()
	local list_box = lQuery("D#ListBox[id = 'diagram_style_list_box']")
	local selected_item = list_box:find("/selected")
	local diagram_style = get_selected_diagram_style()
	local diagram_type = diagram_style:find("/graphDiagramType")
	diagram_style:delete()
	selected_item:delete()
	list_box:link("selected", list_box:find("/item:last()"))
	utilities.refresh_form_component(list_box)
	if diagram_type:find("/graphDiagramStyle"):size() == 1 then
		local delete_button = get_event_source()
		utilities.refresh_form_component(delete_button:attr({enabled = "false"}))	
	end
	delete_event()
end

function edit_diagram_style()
	local diagram_style = get_selected_diagram_style()
	local form = d.add_form({id = "form", caption = "Diagram Style", minimumWidth = 300, minimumHeight = 200})
		add_diagram_style_field_text(form, "Name", "id", diagram_style)
		add_diagram_style_field(form, "Layout Mode", "layoutMode", diagram_style)
		add_diagram_style_field(form, "Layout Algorithm", "layoutAlgorithm", diagram_style)
		add_diagram_style_field(form, "Background Color", "bkgColor", diagram_style)
		add_diagram_style_field(form, "Screen Zoom", "screenZoom", diagram_style)
		add_diagram_style_field(form, "Print Zoom", "printZoom", diagram_style)
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_diagram_style_extra_form()"}):link("defaultButtonForm", form)
	delete_event()
	d.show_form(form)
end

function add_style_box()
	local active_elem = utilities.active_elements()
	local diagram = utilities.current_diagram()
	local style_box = core.add_node(lQuery("NodeType[id = 'BoxStyle']"), diagram)
	local default_style = style_box:find("/elemStyle")
	default_style:remove_link("element")
	core.add_edge(lQuery("EdgeType[id = 'Box_Style_Line']"), active_elem, style_box, diagram)
	local new_style = lQuery.create("NodeStyle")
				:link("elemType", active_elem:find("/target_type"))
				:link("element", style_box)
				:copy_attrs_from(default_style)
	utilities.activate_element(style_box)	
end

function close_diagram_style_extra_form()
	d.close_form()
	delete_event()
end

function box_style_properties()
	box_style_properties_element(utilities.active_elements())
end

function box_style_properties_element(element)
	local form = d.add_form({id = "form", caption = "Box Style", minimumWidth = 70, minimumHeight = 50})
		add_input_field_function(form, "Name", "id", element:find("/elemStyle"), "lua.configurator.configurator.update_style_id")	
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local style_button = d.add_button(button_box, {id = "style_button", caption = "Style"}, {Click = "lua.configurator.configurator.open_style_form()"})
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	d.show_form(form)
end

function update_style_id()
	local _, value = get_event_source_attrs("text")
	utilities.active_elements():find("/elemStyle"):attr({id = value, caption = value})
end

function delete_style()
	utilities.active_elements():find("/elemStyle"):delete()
end

--compartstyle
function compartment_style(container, obj_type)
	local group_box = d.add_component(container, {id = "table_id", caption = "Styles"}, "D#GroupBox")
	local row = d.add_component(group_box, {id = "list_box_edit_button_row", horizontalAlignment = 0, verticalAlignment = -1}, "D#HorizontalBox")
		local list_box = d.add_component(row, {id = "compart_style_list_box", horizontalAlignment = 0, minimumWidth = 220, minimumHeight = 150}, "D#ListBox")
		local v_box = d.add_component(row, {id = "vertical_box", horizontalAlignment = 0, verticalAlignment = -1}, "D#VerticalBox")
			local edit_button = d.add_button(v_box, {id = "edit_style_button", caption = "Style"}, {Click = "lua.configurator.configurator.edit_compart_style"})
			local rename_button = d.add_button(v_box, {id = "rename_style_button", caption = "Rename"}, {Click = "lua.configurator.configurator.make_compart_style_form"})
	local add_delete_row = d.add_component(group_box, {id = "add_delete_buttons", horizontalAlignment = 0}, "D#HorizontalBox")
		local add_button = d.add_button(add_delete_row, {id = "add_compart_style_button", caption = "Add"}, {Click = "lua.configurator.configurator.add_compart_style()"})
		local delete_button = d.add_button(add_delete_row, {id = "delete_style_button", caption = "Delete"}, {Click = "lua.configurator.configurator.delete_compart_style()"})
	fill_compart_style_list_box(list_box)
	if list_box:find("/item"):size() == 0 then
		delete_button:attr({enabled = "false"})
		edit_button:attr({enabled = "false"})
	end
end

function make_compart_style_form()
	log_button_press("Rename")
	local list_box = d.get_component_by_id("compart_style_list_box")
	local selected_node = list_box:find("/selected")
	make_style_name_form(selected_node:attr("value"), "close_rename_compart_style", {}, "Rename")
end

function close_rename_compart_style()
	local value = d.get_component_by_id("style_name"):attr("text")
	local list_box = d.get_component_by_id("compart_style_list_box")
	local selected_node = list_box:find("/selected")
	selected_node:find("/style"):attr({id = value})
	selected_node:attr({value = value})
	utilities.refresh_form_component(list_box)
	close_called_form()
end

function get_compart_style_names()
	add_lQuery_configurator_comboBox(make_combo_box_item_table(get_selected_type():find("/compartStyle"), "caption"))
end

function update_compart_style()
	local id, val = get_event_source_attrs("text")
	log_configurator_field(id, {Name = val})
	get_compart_style_list_box():find("/selected/style"):attr(id)
	delete_event()
end

function add_compartment_style_field_text(container, object, field_name, id, handler_list)
	if handler_list == nil then
		add_compartment_style_field_table(container, object, field_name, id, {FocusLost = "lua.configurator.configurator.update_compart_style"})
	else
		add_compartment_style_field_table(container, object, field_name, id, handler_list)
	end
end

function add_compartment_style_field(container, object, field_name, id)
	add_compartment_style_field_table(container, object, field_name, id, {FocusLost = "lua.configurator.configurator.update_compart_style", Change = "lua.configurator.configurator.check_field_value"})
end

function add_compartment_style_field_table(container, object, field_name, id, table)
	add_input_field_event_function(container, field_name, id, object, table)
end

function fill_compart_style_list_box(listbox)
	fill_list_box(listbox, get_selected_type():find("/compartStyle"))
end

function fill_list_box(list_box, collection)
	collection:each(function(style)
		add_style_list_box_item(list_box, style)
	end)
	list_box:find("/item:first()"):link("parentListBox", list_box)
end

function add_style_list_box_item(list_box, style)
	local item = lQuery.create("D#Item", {value = style:attr_e("id"), style = style})
	list_box:link("item", item)
return item
end

function compart_style_form(compart_style)
	local form = d.add_form({id = "called_form", caption = "Compartment Style", minimumWidth = 70, minimumHeight = 50})
	add_compartment_style_field_text(form, compart_style, "Name", "id")	
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")
	local close_button = d.add_button(button_box, {id = "called_form_close_button", caption = "Close", enabled = "true"}, {Click = "lua.configurator.configurator.close_style_compart_form()"}):link("defaultButtonForm", form)
	d.show_form(form)
end

function check_compart_style()
	local _, value = get_event_source_attrs("text")
	local compart_type = get_selected_type()
	local tmp_compart_style = compart_type:find("/compartStyle[id = '" .. value .. "']")
	local list_box = get_compart_style_list_box()
	local selected_item = list_box:find("/selected")
	local style_name = selected_item:attr_e("value")
	local compart_style = compart_type:find("/compartStyle[id = '" .. style_name .. "']:last()")
	local close_button = d.get_component_by_id("called_form_close_button")
	local enabled = "true"
	if tmp_compart_style:is_not_empty() and style_name ~= value then
		enabled = "false"
	end
	compart_style:attr({id = value})
	selected_item:attr({value = value})
	if close_button:is_not_empty() then
		utilities.refresh_form_component(close_button:attr({enabled = enabled}))
	end
	utilities.refresh_form_component(list_box)
end

function edit_compart_style()
	log_button_press("Style")
	delete_event()
	local active_elem = utilities.active_elements()
	local selected_item = get_compart_style_list_box():find("/selected")
	local style_id = selected_item:attr_e("value")
	local compart_style = selected_item:find("/style")
	remove_box_compartments(active_elem)
	active_elem:link("compartment", lQuery.create("Compartment", {}):link("compartStyle", compart_style))
	utilities.refresh_element_without_diagram(active_elem)
	add_command_without_diagram(active_elem, "DefaultStyleCmd", {})
	add_command_without_diagram(active_elem, "StyleDialogCmd", {info = "COMPARTMENT;lua_engine#lua.configurator.configurator.ok_compart_style_dialog;lua_engine#lua.configurator.configurator.cancel_compart_style_dialog"})
end

function ok_compart_style_dialog()
	log_button_press({Button = "OK", Context = "Compartment Style Dialog"})
	local elem = utilities.active_elements()
	local dgr = elem:find("/graphDiagram")
	utilities.execute_cmd("SaveStylesCmd", {graphDiagram = dgr})
	utilities.execute_cmd("AfterConfigCmd", {graphDiagram = dgr})
	process_compart_style_dialog()
end

function cancel_compart_style_dialog()
	process_compart_style_dialog()
end

function process_compart_style_dialog()
	log_button_press({Button = "Cancel", Context = "Compartment Style Dialog"})
	local elem = utilities.active_elements()
	local name_compart = get_unlinked_box_freebox_compartments(elem)
	elem:find("/compartment"):delete()
	elem:link("compartment", name_compart)
end

function add_compart_style()
	log_button_press("Add")
	delete_event()
	local list_box = get_compart_style_list_box()
	d.add_list_comb_box(list_box, name)
	local selected_item = list_box:find("/selected")
	local name = cu.generate_unique_id("Style", get_selected_type(), "compartStyle")
	local compart_style = u.add_default_compart_style(name, name):link("compartType", get_selected_type())
									:link("item", selected_item)
	if list_box:find("/item"):is_not_empty() then
		set_edit_delete_button("true")
	end
	utilities.refresh_form_component(list_box)
	compart_style_form(compart_style)
end

function delete_compart_style()
	log_button_press("Delete")
	delete_style_from_list_box(get_compart_style_list_box(), get_selected_type(), 0, set_edit_delete_button)
end

function close_style_compart_form()
	local name = d.get_component_by_id_in_depth(lQuery("D#Form[id = 'called_form']"), "id"):attr_e("text")
	local list_box = get_compart_style_list_box()
	local item = list_box:find("/selected")
	item:attr({value = name})
	utilities.refresh_form_component(list_box)
	close_called_form()
	delete_event()
end

function list_of_components_from_container(container, field_list)
	local list_of_fields = {}
	for i, val in pairs(field_list) do
		container:find("/component[id = 'row_" .. val .. "']"):each(function(box)
			field = lQuery(box):find("/composition/composition[id = '" .. val .. "']")
			list_of_fields[val] = field
		end)
	end
return list_of_fields
end

function list_of_object_values(obj, attr_list)
	local res = {}
	for i, val in pairs(attr_list) do
		res[val] = obj:attr_e(val)
	end
return res
end

function get_compart_style_list_box()
	return lQuery("D#ListBox[id = 'compart_style_list_box']")
end

function set_edit_delete_button(val)
	local delete_button = d.get_component_by_id_in_depth(lQuery("D#Form[id = 'configurator_form']"), "delete_style_button"):attr({enabled = val})
	local edit_button = d.get_component_by_id_in_depth(lQuery("D#Form[id = 'configurator_form']"), "edit_style_button"):attr({enabled = val})
	utilities.refresh_form_component(delete_button)
	utilities.refresh_form_component(edit_button)
end

function check_field_value()
	d.check_field_value_int_and_chars({""})
end

function check_dialog_size()
	d.check_field_value_int_and_chars({""})
end

function check_multiplicity_field()
	d.check_field_value_int_and_chars({"*", ""})
end

--element style form
function add_new_style()
	log_button_press("Styles")
	local elem = utilities.active_elements()
	if elem:filter(".Edge"):is_not_empty() then
		add_style_form("Line Styles")
	elseif elem:filter(".Node"):is_not_empty() then
		add_style_form("Box Styles")
	elseif elem:filter(".Port"):is_not_empty() then
		add_style_form("Port Styles")
	elseif elem:filter(".FreeBox"):is_not_empty() then
		add_style_form("FreeBox Styles")
	elseif elem:filter(".FreeLine"):is_not_empty() then
		add_style_form("FreeLine Styles")
	end
end

function add_style_line()
	add_style_form("Line Styles")
end

function add_style_port()
	add_style_form("Port Styles")
end

function add_style_free_box()
	add_style_form("FreeBox Styles")
end

function add_style_free_line()
	add_style_form("FreeLine Styles")
end

function add_style_box()
	add_style_form("Box Styles")
end

function add_style_form(form_caption)
	log_button_press({Button = "Add", Context = "Add Style"})
	local form = d.add_form({id = "form", caption = form_caption, minimumWidth = 300, minimumHeight = 100})
	local row = d.add_component(form, {id = "list_box_edit_button_row", horizontalAlignment = 0, verticalAlignment = -1}, "D#HorizontalBox")
		local list_box = d.add_component(row, {id = "elem_style_list_box", horizontalAlignment = 0, minimumWidth = 220, minimumHeight = 150}, "D#ListBox")
		d.add_event_handlers(list_box, {Change = "lua.configurator.configurator.change_style()"})
		local vertical_row = d.add_component(row, {id = "vertical_box", verticalAlignment = -1}, "D#VerticalBox")
		local edit_button = d.add_button(vertical_row, {id = "edit_style_button", caption = "Style"}, {Click = "lua.configurator.configurator.edit_style()"})
		local edit_name_button = d.add_button(vertical_row, {id = "edit_style_name_button", caption = "Rename"}, {Click = "lua.configurator.configurator.edit_style_name()"})
	local button_row = d.add_component(form, {id = "add_delete_buttons", horizontalAlignment = -1}, "D#HorizontalBox")
		local add_button = d.add_button(button_row, {id = "add_style_button", caption = "Add"}, {Click = "lua.configurator.configurator.add_style_name()"})
		local delete_button = d.add_button(button_row, {id = "delete_style_button", caption = "Delete"}, {Click = "lua.configurator.configurator.delete_elem_style()"})
		local close_row = d.add_component(button_row, {id = "add_delete_buttons", horizontalAlignment = 1}, "D#HorizontalBox")
			local close_button = d.add_button(close_row, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_elem_style_form()"})
	fill_elem_style_list_box(list_box)
	if list_box:find("/item"):size() == 1 then
		delete_button:attr({enabled = "false"})
	end
	d.show_form(form)
end

function make_style_name_form(name, function_name, handler_list, form_name)
	local form = d.add_form({id = "called_form", caption = form_name, minimumWidth = 70, minimumHeight = 50})
	d.add_row_labeled_field(form, {caption = "Name"}, {id = "style_name", text = name}, {id = "row_rename"}, "D#InputField", handler_list)
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "called_form_close_button", caption = "Close"}, {Click = "lua.configurator.configurator." .. function_name}):link("defaultButtonForm", form)
	d.show_form(form)
end

function close_create_new_elem_style()
	local edge_name = d.get_component_by_id("style_name"):attr_e("text")
	local list_box = get_elem_style_list_box()
	local first_item_name = list_box:find("/item:first()"):attr_e("value")
	local element = utilities.active_elements()
	local target_type = element:find("/target_type")
	if target_type:find("/elemStyle[id = '" .. edge_name .. "']"):is_empty() then
		local elem_style = add_elem_style(target_type)
		local base_style = get_target_elem_style_by_id(element:find("/target_type"), first_item_name)
		elem_style:copy_attrs_from(base_style)
				:attr({id = edge_name, caption = edge_name})
		local new_item = add_style_list_box_item(list_box, elem_style)
		list_box:remove_link("selected")
			:link("selected", new_item)
		if target_type:find("/elemStyle"):size() == 2 then
			set_delete_button("true")	
		end
	else
		list_box:remove_link("selected")
			:link("selected", list_box:find("/item[value = '" .. edge_name .. "']"))
	end
	utilities.refresh_form_component(list_box)
	set_style(element, "item:first()")
	close_called_form()
end

function close_update_elem_style()
	local list_box = get_elem_style_list_box()
	local selected_item = list_box:find("/selected")
	local selected_name = selected_item:attr_e("value")
	local elem_name = d.get_component_by_id("style_name"):attr_e("text")
	local elem_style = selected_item:find("/style"):attr({id = elem_name})
	--local elem_style = get_target_elem_style_by_id(utilities.active_elements():find("/target_type"), selected_name):attr({id = elem_name})
	selected_item:attr({value = elem_name})
	utilities.refresh_form_component(list_box)
	local active_elem = utilities.active_elements()
	log_configurator_field("ElemStyle", {Name = elem_name})
	close_called_form()
end

--this function has to be changed to use links instead of ids
function delete_style_from_list_box(list_box, source_type, nr, func_name)
	local active_item = list_box:find("/selected")
	active_item:find("/style"):delete()
	active_item:delete()
	local last_item = list_box:find("/item:last()")
	last_item:link("parentListBox", list_box)
	utilities.refresh_form_component(list_box)
	if list_box:find("/item"):size() == nr then
		func_name("false")
	end
	set_style(utilities.active_elements(), "item:last()")
end

--the function how it should work
function delete_style_from_list_box_with_link(list_box, source_type, role)
	local active_item = list_box:find("/selected")
	source_type:find(role .. "/elemStyle"):delete()
	active_item:delete()
	list_box:find("/item:last()"):link("parentListBox", list_box)
	utilities.refresh_form_component(list_box)
	if source_type:find(role):size() == 0 then
		set_style_edit_delete_button("false")	
	end
end

function edit_style()
	log_button_press("Style")
	local active_elem = utilities.active_elements()
	local selected_item = get_elem_style_list_box():find("/selected")
	local style_name = selected_item:attr_e("value")
	local target_style = selected_item:find("/style")
	local elem_type = active_elem:find("/elemType")
	local elem_style = elem_type:find("/elemStyle")
	elem_type:link("elemStyle", elem_style)
	active_elem:remove_link("elemStyle", elem_style)
	active_elem:link("elemStyle", target_style)
	if active_elem:filter(".Node"):size() > 0 or active_elem:filter(".FreeBox"):size() > 0 then
		remove_box_compartments(active_elem)
	end
	add_command_without_diagram(active_elem, "OkCmd", {})
	add_command_without_diagram(active_elem, "DefaultStyleCmd", {})
	add_command_without_diagram(active_elem, "StyleDialogCmd", {info = "SHAPE;lua_engine#lua.configurator.configurator.ok_style_dialog;"})
end

function remove_box_compartments(elem)
	local name_copart elem:find("/compartment:has(/compartType[id = 'AS#Name'])"):log()
	--local attr_copart = elem:find("/compartment:has(/compartType[id = 'AS#Attributes'])")
	elem:remove_link("compartment", name_compart)
	--elem:remove_link("compartment", attr_compart)
end

function get_target_elem_style_by_id(target_type, style_name)
	return target_type:find("/elemStyle[id = '" .. style_name .. "']")
end

function close_elem_style_form()
	change_elem_style_from_list_box("item:first()")
	close_form()
end

function change_style()
	change_elem_style_from_list_box("selected")
end

function change_elem_style_from_list_box(path_to_item)
	set_style(utilities.active_elements(), path_to_item)
end

function set_style(active_elem, path_to_item)
	local elem_style = get_elem_style_list_box():find("/" .. path_to_item .. "/style")
	active_elem:remove_link("elemStyle")
	active_elem:link("elemStyle", elem_style)
	utilities.execute_cmd("OkCmd", {element = active_elem, graphDiagram = active_elem:find("/graphDiagram")})
end

function get_elem_style_list_box()
	return d.get_component_by_id("elem_style_list_box")
end

function delete_elem_style()
	log_button_press({Button = "Delete", Context = "Delete Style"})
	delete_style_from_list_box(get_elem_style_list_box(), utilities.active_elements():find("/target_type"), 1, set_delete_button)
end

function set_delete_button(val)
	utilities.refresh_form_component(d.get_component_by_id("delete_style_button"):attr({enabled = val}))
end

function fill_elem_style_list_box(list_box) 
	fill_list_box(list_box, utilities.active_elements():find("/target_type/elemStyle"))
end

function edit_style_name()
	log_button_press("Rename")
	make_style_name_form(get_elem_style_list_box():find("/selected"):attr_e("value"), "close_update_elem_style", {}, "Style")
end

function add_elem_style(elem_type, name)
	if elem_type:filter(".NodeType"):size() > 0 then 
		return u.add_default_node_style(name, name):link("elemType", elem_type)
	elseif elem_type:filter(".EdgeType"):size() > 0 then 
		return u.add_default_edge_style(name, name):link("elemType", elem_type)
	elseif elem_type:filter(".PortType"):size() > 0 then 
		return u.add_default_port_style(name, name):link("elemType", elem_type)
	end
end

function add_style_name()
	log_button_press({Button = "Add", Context = "Style Name"})
	local name = ""
	local elem = utilities.active_elements()
	if elem:filter(".Node"):size() > 0 then
		name = "NodeStyle"
	elseif elem:filter(".Edge"):size() > 0 then
		name = "EdgeStyle"
	elseif elem:filter(".FreeBox"):size() > 0 then
		name = "FreeBoxStyle"
	elseif elem:filter(".FreeLine"):size() > 0 then
		name = "FreeLineStyle"
	elseif elem:filter(".Port"):size() > 0 then
		name = "PortStyle"
	end
	local name = cu.generate_unique_id(name, elem:find("/target_type"), "elemStyle")
	make_style_name_form(name, "close_create_new_elem_style", {}, "Style")
end

function generate_instances(source_diagram_type)
	local instance_diagram_type = lQuery("GraphDiagramType[id = 'MMInstances']")
	--instance_diagram_type:find("/graphDiagram"):delete()
	local diagram = utilities.add_graph_diagram_to_graph_diagram_type("Instances", instance_diagram_type)
	--local diagram = cu.add_graph_diagram("Test"):link("graphDiagramType", instance_diagram_type)
	make_MM_instances(diagram, instance_diagram_type, source_diagram_type)
	utilities.execute_cmd("ActiveDgrCmd", {graphDiagram = diagram})
	utilities.execute_cmd("OkCmd")
end

function make_MM_instances(diagram, instance_diagram_type, source_dgr_type)
	local instance_table = {}
	instance_table["Node"] = {}
	instance_table["Edge"] = {}
	if source_dgr_type == nil then
		print("in if")
		source_dgr_type = utilities.current_diagram():find("/target_type")
	end
	--local source_dgr_type = source_diagram:find("/target_type")
		local diagram_type_node = add_MM_instance(source_dgr_type, diagram, instance_table["Node"])
		traverse_elem_childs_by_each_in_two_levels(source_dgr_type, "/rClickEmpty", "/popUpElementType", diagram, diagram_type_node, instance_table, "rClickEmpty", "popUpElementType")
		traverse_elem_childs_by_each_in_two_levels(source_dgr_type, "/rClickCollection", "/popUpElementType", diagram, diagram_type_node, instance_table, "rClickCollection", "popUpElementType")
		traverse_elem_childs_by_each_in_two_levels(source_dgr_type, "/toolbarType", "/toolbarElementType", diagram, diagram_type_node, instance_table, "toolbar", "tool")
		traverse_elem_childs_by_each(source_dgr_type, "/eKeyboardShortcut", diagram, diagram_type_node, add_MM_composition, instance_table, "eKeyboardShortcut")
		traverse_elem_childs_by_each(source_dgr_type, "/cKeyboardShortcut", diagram, diagram_type_node, add_MM_composition, instance_table, "cKeyboardShortcut")
		traverse_elem_childs_by_each(source_dgr_type, "/graphDiagramStyle", diagram, diagram_type_node, add_MM_link, instance_table, "graphDiagramStyle", "graphDiagramType")
		local palette_node = process_palette(source_dgr_type, diagram, diagram_type_node, instance_table)
		process_elem_types(source_dgr_type, diagram_type_node, palette_node, diagram, instance_table)
		for _, edge in pairs(instance_table["Edge"]) do
			local edge_type = edge["link"]
			local edge1 = core.add_edge(edge_type, edge["source"], edge["target"], diagram)
			core.add_compartment(edge_type:find("/compartType[id = 'DirectRole']"), edge1, edge["inverseRole"])
			core.add_compartment(edge_type:find("/compartType[id = 'InverseRole']"), edge1, edge["directRole"])
		end
end

function process_palette(source_dgr_type, diagram, diagram_type_node, instance_table)
	local palette = source_dgr_type:find("/paletteType")
	if palette:size() > 0 then
		local palette_node = add_MM_instance(palette, diagram, instance_table["Node"])
		add_MM_link(diagram_type_node, palette_node, diagram, instance_table["Edge"], "paletteElement")
		return palette_node
	end
end

function process_elem_types(source_dgr_type, diagram_type_node, palette_node, diagram, instance_table)
	source_dgr_type:find("/elemType"):each(function(elem_type)
		local elem_type_node = add_MM_instance(elem_type, diagram, instance_table["Node"])
		add_MM_composition(elem_type_node, diagram_type_node, diagram, instance_table["Edge"], "elemType")
		traverse_elem_childs_by_each(elem_type, "/elemStyle", diagram, elem_type_node, add_MM_link, instance_table, "elemStyle", "elemType")
		traverse_compart_types(elem_type, diagram, elem_type_node, instance_table)
		traverse_elem_childs_by_each_in_two_levels(elem_type, "/popUpDiagramType", "/popUpElementType", diagram, elem_type_node, instance_table, "popUpDiagramType", "popUpElementType")
		traverse_elem_childs_by_each(elem_type, "/keyboardShortcut", diagram, elem_type_node, add_MM_composition, instance_table, "keyboardShortcut")
		traverse_elem_childs_by_each(elem_type, "/translet", diagram, elem_type_node, add_MM_composition, instance_table, "translet")
		process_palette_element(elem_type, palette_node, elem_type_node, diagram, instance_table)
		process_property_diagram(elem_type, elem_type_node, diagtram, instance_table)
		elem_type:find("/subtype"):each(function(sub_type)
			--print("in each supertype")
			add_MM_link(elem_type_node, instance_table["Node"][sub_type:id()], diagram, instance_table["Edge"], "supertype", "subtype")

			--traverse_elem_childs_by_each(elem_type, "/supertype", diagram, elem_type_node, add_MM_link, instance_table, "supertype", "subtype")
		end)
		if elem_type:filter(".EdgeType"):is_not_empty() then
			local start = elem_type:find("/start")
			local end_ = elem_type:find("/end")
			add_MM_link(elem_type_node, instance_table["Node"][start:id()], diagram, instance_table["Edge"], "eStart", "start")
			add_MM_link(elem_type_node, instance_table["Node"][end_:id()], diagram, instance_table["Edge"], "eEnd", "end")
		else

		end
		


	end)
end

function process_property_diagram(elem_type, elem_type_node, diagram, instance_table)
	local prop_diagram = elem_type:find("/propertyDiagram")
	if prop_diagram:size() > 0 then
		local prop_dgr_node = add_MM_instance(prop_diagram, diagram, instance_table["Node"])
		add_MM_link(elem_type_node, prop_dgr_node, diagram, instance_table["Edge"], "elemType", "propertyDiagram")
		process_property_diagram_childs(prop_diagram, prop_dgr_node, diagram, instance_table)
	end
end

function process_property_diagram_childs(prop_diagram, prop_dgr_node, diagram, instance_table)
	process_row_from_parent(prop_diagram, prop_dgr_node, diagram, instance_table)
end

function process_row_from_parent(row_parent, parent_node, diagram, instance_table)
	local row = row_parent:find("/propertyRow")
	if row:size() > 0 then
		process_child(row, parent_node, diagram, instance_table)
	else
		local tab = row_parent:find("/propertyTab")
		if tab:size() > 0 then		
			tab:each(function(obj)
				local tab_node = add_MM_instance(obj, diagram, instance_table["Node"])
				add_MM_composition(tab_node, parent_node, diagram, instance_table["Edge"])
				process_row_from_parent(obj, tab_node, diagram, instance_table)
			end)
		end
	end
end

function process_child(child, start_node, diagram, instance_table)
	child:each(function(obj)
		local obj_node = add_MM_instance(obj, diagram, instance_table["Node"])
		local compart_type_node = instance_table["Node"][obj:find("/compartType"):id()]
		add_MM_composition(obj_node, start_node, diagram, instance_table["Edge"], "propertyRow")
		add_MM_link(compart_type_node, obj_node, diagram, instance_table["Edge"], "compartType", "propertyRow")
	end)
end

function process_palette_element(elem_type, palette_node, elem_type_node, diagram, instance_table)
	local palette_elem = elem_type:find("/paletteElementType")
--vajaga parbaudi, vai viens paletes elements neatbilst vairakiem elementa tipiem(EdgeType gadîjums)
	if palette_elem:size() > 0 then
		local palette_elem_node = add_MM_instance(palette_elem, diagram, instance_table["Node"])
		add_MM_link(elem_type_node, palette_elem_node, diagram, instance_table["Edge"], "elemType", "paletteElementType")
		add_MM_composition(palette_elem_node, palette_node, diagram, instance_table["Edge"], "paletteElementType")
	end
end

function traverse_compart_types(elem_type, diagram, elem_type_node, instance_table, role1)
	local instance_type, name_compart_type, value_compart_type = get_MM_instance_types()
	if elem_type:filter(".CompartType"):size() > 0 then
		elem_type:find("/subCompartType"):each(function(compart_type)
			process_compart_types(compart_type, diagram, elem_type_node, instance_table, role1)
		end)
	else
		elem_type:find("/compartType"):each(function(compart_type)
			process_compart_types(compart_type, diagram, elem_type_node, instance_table, role1)
		end)
	end
end

function process_compart_types(compart_type, diagram, elem_type_node, instance_table)
	local compart_node = add_MM_instance(compart_type, diagram, instance_table["Node"])
	add_MM_composition(compart_node, elem_type_node, diagram, instance_table["Edge"], "compartType")
	traverse_compart_types(compart_type, diagram, compart_node, instance_table, "subCompartType")
	traverse_elem_childs_by_each(compart_type, "/compartStyle", diagram, compart_node, add_MM_link, instance_table, "compartStyle", "compartType")
	process_choice_items(compart_node, compart_type, diagram, instance_table)
end

function process_choice_items(compart_node, compart_type, diagram, instance_table)
	compart_type:find("/choiceItem"):each(function(choice_item)
		local choice_item_node = add_MM_instance(choice_item, diagram, instance_table["Node"])
		add_MM_composition(choice_item_node, compart_node, diagram, instance_table["Edge"], "choiceItem")
		local notation = choice_item:find("/notation")
		if notation:is_not_empty() then
			local notation_node = add_MM_instance(notation, diagram, instance_table["Node"])
			add_MM_link(choice_item_node, notation_node, diagram, instance_table["Edge"], "choiceItem", "notation")
		end
		choice_item:find("/tag"):each(function(tag_compart)
			add_MM_composition(instance_table["Node"][tag_compart:id()], choice_item_node, diagram, instance_table["Edge"], "tag")
		end)
		choice_item:find("/compartStyleByChoiceItem"):each(function(compart_style)
			add_MM_link(instance_table["Node"][compart_style:id()], choice_item_node, diagram, instance_table["Edge"], "compartStyleByChoiceItem")
		end)
		choice_item:find("/elemStyleByChoiceItem"):each(function(elem_style)
			add_MM_link(instance_table["Node"][elem_style:id()], choice_item_node, diagram, instance_table["Edge"], "elemStyleByChoiceItem", "choiceItem")
		end)
	end)
end

function traverse_elem_childs_by_each_in_two_levels(elem_type, path, path_to_child, diagram, start_node, instance_table, role1, role2)
	elem_type:find(path):each(function(item)
		local middle_node = add_MM_instance(item, diagram, instance_table["Node"])
		add_MM_composition(middle_node, start_node, diagram, instance_table["Edge"], role1)
		traverse_elem_childs_by_each(item, path_to_child, diagram, middle_node, add_MM_composition, instance_table, role2)
	end)
end

function traverse_elem_childs_by_each(elem_type, path, diagram, start_node, link_function, instance_table, role1, role2)
	elem_type:find(path):each(function(item)
		local end_node = add_MM_instance(item, diagram, instance_table["Node"])
		link_function(end_node, start_node, diagram, instance_table["Edge"], role1, role2)
	end)
end

function add_MM_instance(source_dgr_type, diagram, node_instance_table)
	local instance_type, name_compart_type, value_compart_type = get_MM_instance_types()
	local node = core.add_node(instance_type, diagram)
		local obj_type_value = source_dgr_type:get(1):class().name
		add_compartment(name_compart_type, node, obj_type_value)
		local list = utilities.get_lQuery_object_attribute_list(source_dgr_type)[1]
		process_instance_attributes(list)
		add_compartment(value_compart_type, node, utilities.concat_attr_dictionary(list, "\n"))
		node_instance_table[source_dgr_type:id()] = node
	return node
end

function process_instance_attributes(list)
	for i, item in pairs(list) do
		list[i] = '"' .. item .. '"'
	end
end

function get_MM_instance_types()
	local source_type = lQuery("GraphDiagramType[id = 'MMInstances']")
	local instance_type = source_type:find("/elemType[id = 'Instance']")
	local name_compart_type = instance_type:find("/compartType[id = 'Name']")
	local value_compart_type = instance_type:find("/compartType[id = 'Value']")
return instance_type, name_compart_type, value_compart_type
end

function get_MM_link_types(type_name)
	local link = lQuery("GraphDiagramType[id = 'MMInstances']")
	local link_type = link:find("/elemType[id = '" .. type_name .. "']")
return link_type
end

function add_MM_link(source, target, diagram, link_instance_table, direct_role, inverse_role)
	return add_MM_line_by_type("Link", source, target, diagram, link_instance_table, direct_role, inverse_role)
end

function add_MM_composition(source, target, diagram, line_instance_table, direct_role, inverse_role)
	return add_MM_line_by_type("Composition", source, target, diagram, line_instance_table, direct_role, inverse_role)
end

function add_MM_line_by_type(type_name, source, target, diagram, line_instance_table, direct_role, inverse_role)
	local link_type = get_MM_link_types(type_name)
	--local edge = core.add_edge(link_type, source, target, diagram)
		table.insert(line_instance_table, {source = source, target = target, link = link_type, directRole = direct_role, inverseRole = inverse_role})
		--local obj_type_value = ":" .. source_dgr_type:get(1):class().name
		--add_compartment(name_compart_type, node, obj_type_value)
		--local list = get_lQuery_object_attribute_list(source_dgr_type)
		--add_compartment(value_compart_type, node, utilities.concat_attr_dictionary(list[1], "\n"))
	return edge
end

function add_compartment(compartment_type, parent, value)
	local input = core.build_input_from_value(value, compartment_type)
	local compartment = lQuery.create("Compartment", {
				input = input,
				value = value,
				compartType = compartment_type,
				compartStyle = compartment_type:find("/compartStyle")
				})
	if parent:filter(".Compartment"):size() > 0 then
		compartment:link("parentCompartment", parent)
	else
		compartment:link("element", parent)
	end
end

function delete_elem_type_from_configurator(element)
	local elem_type = element:find("/target_type")
	delete_elem_type(elem_type)
end

function delete_elem_type(elem_type)
	elem_type:find("/compartType"):each(function(compart_type)
		compart_type:find("/compartment"):delete()
		compart_type:find("/compartStyle"):delete()
		delete_sub_compart_types(compart_type)
		delete_choice_items(compart_type)
		compart_type:delete()
	end)
	
	elem_type:find("/elemStyle"):delete()
	elem_type:find("/keyboardShortcut"):delete()
	delete_palette_from_elem_type(elem_type)
	delete_propety_diagram(elem_type:find("/propertyDiagram"))

	local pop_up_diagram = elem_type:find("/popUpDiagram")
	pop_up_diagram:find("/popUpElement"):delete()
	pop_up_diagram:delete()

	local elements = elem_type:find("/element")
	local diagrams = elements:find("/graphDiagram")
	delete_target_diagrams(elements:find("/target"))
	delete_target_diagrams(elements:find("/child"))
	
	elements:delete()
	diagrams:each(function(dgr)
		utilities.execute_cmd("OkCmd", {graphDiagram = dgr})
	end)

	local element = elem_type:find("/presentation")
	local target_diagram = element:find("/child")
	if target_diagram:is_empty() then
		target_diagram = element:find("/target")
	end
	delete_configurator_target_diagrams(target_diagram)
	elem_type:delete()
end

function delete_configurator_target_diagrams(target_diagram)
	target_diagram:find("/element"):each(function(element)
		delete_elem_type_from_configurator(element)
	end)
	utilities.close_diagram(target_diagram)
	delete_diagram_type(target_diagram:find("/target_type"))
	target_diagram:delete()
end

function delete_diagram_type(diagram_type)
	diagram_type:find("/paletteType"):delete()
	diagram_type:find("/rClickEmpty"):delete()
	diagram_type:find("/rClickCollection"):delete()
	diagram_type:find("/eKeyboardShortcut"):delete()
	diagram_type:find("/cKeyboardShortcut"):delete()
	diagram_type:find("/toolbarType"):delete()
	diagram_type:find("/graphDiagram"):delete()
	diagram_type:delete()
end

function delete_target_diagrams(target_diagrams)
	delete_configurator_diagrams(target_diagrams)
end

function delete_configurator_diagrams(diagrams)
	diagrams:find("/element"):each(function(elem)
		delete_elem_type_from_configurator(elem)
	end)
	local list = {}
	--utilities.close_diagram(diagrams)
	diagrams:each(function(diagram)
		--utilities.close_diagram(diagram)
		table.insert(list, diagram)
	end)
	delete.delete_diagrams_from_table(list)
end

function delete_choice_items(compart_type)
	compart_type:find("/choiceItem"):each(function(choice_item)
		choice_item:find("/notation"):delete()
		choice_item:delete()
	end)
end

function delete_propety_diagram(prop_diagrams)
	prop_diagrams:each(function(prop_dgr)
		local tabs = prop_dgr:find("/propertyTab")
		delete_prop_rows(tabs)
		delete_prop_rows(prop_dgr)
	end)
end

function delete_prop_rows(source)
	local rows = source:find("/propertyRow")
	local called_dgrs = rows:find("/calledDiagram")
	if called_dgrs:size() > 0 then
		delete_propety_diagram(called_dgrs)
	end
	rows:delete()
	source:delete()
end

function delete_palette_from_elem_type(elem_type)
	elem_type:find("/paletteElementType"):each(function(palette_elem_type)
		if palette_elem_type:find("/elemType"):size() < 2 then
			local palette_type = palette_elem_type:find("/paletteType")
			palette_elem_type:find("/presentationElement"):delete()
			palette_elem_type:delete()
			if palette_type:find("/paletteElementType"):is_empty() then
				palette_type:find("/presentationElement"):delete()
				palette_type:delete()
			end
			local dgr = elem_type:find("/graphDiagramType/graphDiagram")
			utilities.execute_cmd("AfterConfigCmd", {graphDiagram = dgr})
		end
	end)
end

function delete_sub_compart_types(compart_type)
	compart_type:find("/subCompartType"):each(function(sub_compart_type)
		delete_choice_items(sub_compart_type)
		delete_sub_compart_types(sub_compart_type)
		sub_compart_type:delete()
	end)
end

function delete_specialization(elem)
	local start_type = elem:find("/start/target_type")
	local end_type = elem:find("/end/target_type")
	start_type:remove_link("supertype", end_type)
end

function move_line_type(edge, new_elem, old_elem)
	local old_elem_type = old_elem:find("/target_type")
	local new_elem_type = new_elem:find("/target_type")
	local edge_type = edge:find("/target_type")
	if edge:find("/start"):id() == new_elem:id() then
		process_move_line_pairs(edge_type, new_elem_type, old_elem_type, "start")	--start moved
	elseif edge:find("/end"):id() == new_elem:id() then
		process_move_line_pairs(edge_type, new_elem_type, old_elem_type, "end")		--end moved
	else
		print("Error in move line")
	end
end

function process_move_line_pairs(edge_type, new_type, old_type, role)
	local buls = "false"
	edge_type:remove_link(role, old_type)
		:link(role, new_type)
end

function move_specialization(edge, new_elem, old_elem)
	local old_type = old_elem:find("/target_type")
	local new_type = new_elem:find("/target_type")
	local start_elem = edge:find("/start")
	local end_elem = edge:find("/end")
	local start_type = start_elem:find("/target_type")
	local end_type = end_elem:find("/target_type")
	if start_elem:id() == new_elem:id() then	--start moved
		old_type:remove_link("supertype", end_type)
		new_type:link("supertype", end_type)
	elseif end_elem:id() == new_elem:id() then	--end moved
		old_type:remove_link("subtype", start_type)
		start_type:link("supertype", new_type)		
	else
		print("Error in move specialization")
	end
end

function copy_element_compartments(original, copy)
	local elem_type = copy:find("/target_type")
	original:find("/compartment"):each(function(compart)
		local compart_type = compart:find("/target_type")
		if compart_type:is_not_empty() then
			local new_compart_type = lQuery.create("CompartType"):copy_attrs_from(compart_type)										
										:link("elemType", elem_type)
			local new_compart = lQuery.create("Compartment"):copy_attrs_from(compart)
									:link("target_type", new_compart_type)
									:link("element", copy)
									:link("compartType", compart:find("/compartType"))
			compart_type:find("/compartStyle"):each(function(compart_style)
				local new_compart_style = lQuery.create("CompartStyle"):copy_attrs_from(compart_style)
				new_compart_type:link("compartStyle", new_compart_style)
				if compart:find("/compartStyle"):id() == compart_style:id() then
					new_compart:link("compartStyle", new_compart_style)
				end
			end)
			copy_prop_diagram_to_obj_type(compart_type, new_compart_type, "compartType")
			copy_compart_type_row(compart_type, new_compart_type)
			copy_choice_item(compart_type, new_compart_type)
			copy_sub_compart_types(compart_type, new_compart_type)
		end
	end)
	copy:find("/compartment:has(/compartType[id = 'AS#Attributes']):not(:has(/target_type))"):delete()
end

function copy_choice_item(old_compart_type, new_compart_type)
	old_compart_type:find("/choiceItem"):each(function(choice_item)
		local new_choice_item = lQuery.create("ChoiceItem"):copy_attrs_from(choice_item)
									:link("compartType", new_compart_type)
		local compart_style = choice_item:find("/compartStyleByChoiceItem")
		if compart_style:is_not_empty() then
			new_compart_type:find("/compartStyle[id = '" .. compart_style:attr("id") .. "']"):link("choiceItem", choice_item)
		end
		local elem_style = choice_item:find("/elemStyleByChoiceItem")
		if elem_style:is_not_empty() then
			u.get_elem_type_from_compartment(new_compart_type):find("/elemStyle[id = '" .. elem_style:attr("id") .. "']"):link("choiceItem", choice_item)
		end
		local old_notation = choice_item:find("/notation")
		if old_notation:is_not_empty() then
			lQuery.create("Notation"):copy_attrs_from(old_notation)
						:link("choiceItem", choice_item)
		end
		local tag_compart_type = choice_item:find("/tag")
		if tag_compart_type:is_not_empty() then
			local tag_prop_row = tag_compart_type:find("/propertyRow")
			local compart_style = tag_compart_type:find("/compartStyle")
			lQuery.create("CompartType"):copy_attrs_from(tag_compart_type)
							:link("stereotype", new_choice_item)
							:link("propertyRow", lQuery.create("PropertyRow"):copy_attrs_from(tag_prop_row))
							:link("compartStyle", lQuery.create("CompartStyle"):copy_attrs_from(compart_style))
		end
	end)
end

function copy_sub_compart_types(compart_type, new_compart_type)
	compart_type:find("/subCompartType"):each(function(sub_compart_type)
		local new_sub_compart_type = lQuery.create("CompartType"):copy_attrs_from(sub_compart_type)
									:link("parentCompartType", new_compart_type)
		copy_prop_diagram_to_obj_type(sub_compart_type, new_sub_compart_type, "compartType")
		copy_compart_type_row(sub_compart_type, new_sub_compart_type)
		copy_choice_item(sub_compart_type, new_sub_compart_type)
		copy_sub_compart_types(sub_compart_type, new_sub_compart_type)	
	end)
end

function copy_prop_diagram_to_obj_type(old_type, obj_type, role)
	local prop_diagram = old_type:find("/propertyDiagram")
	if prop_diagram:is_not_empty() then
		local new_prop_diagram = lQuery.create("PropertyDiagram"):copy_attrs_from(prop_diagram)
									:link(role, obj_type)
									:link("original", prop_diagram)
		copy_prop_row_event_handler(prop_diagram, new_prop_diagram)
	end
	return  prop_diagram
end

function copy_compart_type_row(compart_type, new_compart_type)
	compart_type:find("/propertyRow"):each(function(prop_row)
		local new_prop_row = lQuery.create("PropertyRow"):copy_attrs_from(prop_row)
								:link("compartType", new_compart_type)
								:link("original", prop_row)
		copy_prop_row_event_handler(prop_row, new_prop_row)
	end)
end

function copy_property_row_links(prop_diagram)
	local new_prop_diagram = prop_diagram:find("/copy")
	if new_prop_diagram:is_not_empty() then
		prop_diagram:find("/propertyTab"):each(function(tab)
			local new_tab = lQuery.create("PropertyTab"):copy_attrs_from(tab)
									:link("propertyDiagram", new_prop_diagram)
			copy_prop_row_event_handler(tab, new_tab)
			tab:find("/propertyRow"):each(function(prop_row)
				copy_property_row(prop_row, new_tab, "propertyTab")
			end)
		end)
		prop_diagram:find("/propertyRow"):each(function(prop_row)
			copy_property_row(prop_row, new_prop_diagram, "propertyDiagram")
		end)
		prop_diagram:remove_link("copy", new_prop_diagram)
	end
end

function copy_property_row(prop_row, new_parent, role)
	local new_prop_row = prop_row:find("/copy"):link(role, new_parent)
							:remove_link("original", prop_row)
	local called_diagram = prop_row:find("/calledDiagram")
	if called_diagram:is_not_empty() then
		lQuery.create("PropertyDiagram"):copy_attrs_from(called_diagram)
						:link("calledPropertyRow", new_prop_row)
						:link("original", called_diagram)
		copy_property_row_links(called_diagram)
	end
end

function copy_prop_row_event_handler(prop_row, new_prop_row)
	local handler = prop_row:find("/propertyEventHandler")
	if handler:is_not_empty() then
		local new_handler = lQuery.create("PropertyEventHandler"):copy_attrs_from(handler):link("propertyElement", new_prop_row)
	end
end

function hide_show_attributes()
	local elem = utilities.active_elements()
	if elem:find("/compartment[isInvisible = 'true']"):is_not_empty() then
		show_comparts(elem)
	else
		hide_comparts(elem)
	end
	add_command_without_diagram(elem, "OkCmd", {})
end

function hide_comparts(elem)
	elem:find("/compartment:has(/compartType[id = 'AS#Attributes'])"):each(function(compart)
		compart:attr({isInvisible = "true", input = ""})
	end)
end

function show_comparts(elem)
	elem:find("/compartment:has(/compartType[id = 'AS#Attributes'])"):each(function(compart)
		compart:attr({isInvisible = "false", input = compart:attr("value")})
	end)
end

function check_id_field_syntax()
	local _, value = get_event_source_attrs("text")
	local field, _ = get_event_source()
	local grammer = re.compile[[grammer <- ({[a-zA-Z0-9_]*})]]
	local res = re.match(value, lpeg.Ct(grammer) * -1)
	if type(res) == "table" then
		
		local bool, hint = check_ID_uniqness(value)
		if bool then
			set_elem_style_id()
			update_ID_field()
			d.set_field_ok(field)
		else
			field:attr({outlineColor = "255", hint = hint})
		end
	else
		field:attr({outlineColor = "255", hint = "Error: ID field may contain only characters from range [a-zA-Z0-9_]"})
	end
	utilities.refresh_form_component(field)
end

function check_ID_uniqness(id)
	local obj_type = get_selected_obj_type()
	local role_to_parent = "graphDiagramType"
	local role_to_child = "elemType"
	if obj_type:filter(".CompartType"):is_not_empty() then
		role_to_parent = "elemType"
		role_to_child = "compartType"
	end
	local tmp_type = obj_type:find("/" .. role_to_parent .. "/" .. role_to_child .. "[id = " .. id .. "]")
	if tmp_type:is_not_empty() and tmp_type:id() ~= obj_type:id() then
		return false, "Error: Violated unique ID constraint"
	else
		return true
	end
end

function copy_target_diagram(diagram)
	return delta.copy_target_diagram_type(diagram)
end

function configurator_seed_copied(elem)
	return configurator_elem_copied(elem)
end

function configurator_elem_copied(elem)
	return copy_configurator_element(elem)
end

function copy_configurator_element(elem, is_unique)
	local list_of_code = {}
	if elem:find("/elemType[id = 'Specialization']"):is_empty() then
		table.insert(list_of_code, delta.process_target_elem_type(elem))
		return table.concat(list_of_code)
	else
		return copy_specialization(elem)
	end
end

function copy_specialization(elem)
	if elem:find("/start"):is_not_empty() and elem:find("/end"):is_not_empty() then
		local list_of_code = {}
		table.insert(list_of_code, delta.process_specialization_element(elem))	
		return table.concat(list_of_code)
	else
		return ""
	end
end

function copy_name_compartment(elem, is_unique_needed)
	local code = ""
	local elem_type = elem:find("/target_type")
	local elem_type_name = elem_type:attr("id")
	local elem_type_code = utilities.make_obj_to_var(elem_type)
	--if is_unique_needed then
		code = code .. 'id = cu.generate_unique_id(' .. elem_type_code .. ':attr("id"), ' .. elem_type_code .. ':find("/graphDiagramType"), "elemType")\n'
		local name_code = elem_type_code .. ':attr({id = id, caption = id})\n'
		code = code .. name_code
	--end
	local compart = elem:find("/compartment:has(/compartType[id = 'AS#Name'])")
	code = code .. utilities.make_obj_to_var(compart) .. ':attr({input = id, value = id})\n'
	local diagram = elem:find("/target")
	if diagram:is_not_empty() then
		code = code .. utilities.make_obj_to_var(diagram) .. ':attr({caption = id})\n'
	end
	local palette_elem_type = elem_type:find("/paletteElementType")
	if palette_elem_type:is_not_empty() then
		code = code .. utilities.make_obj_to_var(palette_elem_type) .. ':attr({id = id, caption = id})\n'
	end
	return code
end

function configurator_seed_pasted(elem)
	local target_type = configurator_elem_pasted(elem)
	--copy_target_diagram(elem, target_type, configurator_elem_pasted)
end

function copy_target_diagram1(elem, target_type, function_name)
	local original = elem:find("/original")
	local target_diagram = original:find("/target")
	local target_diagram_type = target_diagram:find("/target_type")
	local target_diagram_copy = lQuery.create("GraphDiagram"):copy_attrs_from(target_diagram)
								:link("source", elem)
								:link("graphDiagramType", target_diagram:find("/graphDiagramType"))
	local new_diagram_type = lQuery.create("GraphDiagramType"):copy_attrs_from(target_diagram_type)
									:link("source", target_type)
									:link("presentation", target_diagram_copy)
	copy_paste.copy_diagram_elements(target_diagram, target_diagram_copy)
end

function add_pattern()
	add_pattern_form("lua.configurator.configurator.close_pattern_form()")
end

function add_pattern_form(close_function_name)
	local form = d.add_form({id = "form", caption = "Pattern", minimumWidth = 70, minimumHeight = 50})
	local field_id = "pattern_name"
	local _, name_field = d.add_row_labeled_field(form, {caption = "Name"}, {id = field_id, text = ""}, {id = "row_" .. field_id}, "D#InputField", {})
	field_id = "pattern_nr"
	local _, nr_field = d.add_row_labeled_field(form, {caption = "Nr"}, {id = field_id, text = ""}, {id = "row_" .. field_id}, "D#InputField", {Change = "lua.configurator.configurator.check_field_value"})
	field_id = "pattern_picture"
	local _, image_field = d.add_row_labeled_field(form, {caption = "Image"}, {id = "pattern_picture", fileName = "", editable = "true", minimumWidth = 50, minimumHeight = 50, maximumWidth = 50, maximumHeight = 50}, {id = "row_" .. field_id}, "D#Image", {})
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = close_function_name}):link("defaultButtonForm", form)
	d.show_form(form)	
	return {name = name_field, nr = nr_field, picture = image_field}
end

function fill_pattern_form(fields)
	local palette_box = get_selected_pattern()
	fields["name"]:attr({text = palette_box:attr("caption")})
	fields["nr"]:attr({text = palette_box:attr("nr")})
	fields["picture"]:attr({fileName = palette_box:attr("picture")})
end

function get_pattern_values()
	local name = d.get_component_by_id("pattern_name"):attr("text")
	local nr = d.get_component_by_id("pattern_nr"):attr("text")
	local fileName = d.get_component_by_id("pattern_picture"):attr("fileName")
	local fileName_reverse = string.reverse(fileName)
	local reverse_slash_index = string.find(fileName_reverse, "\\")
	if reverse_slash_index ~= nil then
		fileName = string.reverse(string.sub(fileName_reverse, 1, reverse_slash_index - 1))
	end
	return {caption = name, picture = fileName, nr = nr}
end

function make_pattern()
	local values = get_pattern_values()
	if values["caption"] ~= "" then
		local diagram = utilities.current_diagram()
		local palette_type = diagram:find("/target_type/paletteType")
		local palette_elem_type = lQuery.create("PaletteElementType", {id = "pattern", 
									paletteType = palette_type}):attr(values)
		local collection = diagram:find("/collection/element/target_type")
							:link("paletteElementType", palette_elem_type)
		relink_palette_from_palette_elem_type(palette_elem_type)
	end
end

function update_pattern()
	local values = get_pattern_values()
	local palette_box, selected_item, list_box = get_selected_pattern()
	palette_box:attr(values)
	selected_item:attr({value = values["caption"]})
	utilities.refresh_form_component(list_box)
end

function close_pattern_form()
	make_pattern()
	close_form()
end

function edit_patterns()
	local form = d.add_form({id = "form", caption = "Edit Patterns", minimumWidth = 300, minimumHeight = 100})
	local row = d.add_component(form, {id = "list_box_edit_button_row", horizontalAlignment = 0, verticalAlignment = -1}, "D#HorizontalBox")
		local list_box = d.add_component(row, {id = "pattern_list_box", horizontalAlignment = 0, minimumWidth = 220, minimumHeight = 150}, "D#ListBox")
		d.add_event_handlers(list_box, {Change = "lua.configurator.configurator.select_pattern_collection()"})
		local vertical_row = d.add_component(row, {id = "vertical_box", verticalAlignment = -1}, "D#VerticalBox")
		local edit_button = d.add_button(vertical_row, {id = "edit_button", caption = "Edit"}, {Click = "lua.configurator.configurator.edit_pattern()"})
		local delete_button = d.add_button(vertical_row, {id = "delete_button", caption = "Delete"}, {Click = "lua.configurator.configurator.delete_pattern()"})
	local close_row = d.add_component(form, {id = "close_row", horizontalAlignment = 1}, "D#HorizontalBox")
		local close_button = d.add_button(close_row, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_edit_patterns_form()"})
	fill_pattern_list_box(list_box, edit_button, delete_button)
	d.show_form(form)
end

function close_edit_patterns_form()
	--utilities.current_diagram():find("/collection"):remove_link("element")
	local palette_elem_type = d.get_component_by_id("pattern_list_box"):find("/selected/type")
	relink_palette_from_palette_elem_type(palette_elem_type)
	close_form()
end

function select_pattern_collection()
	local elements = get_selected_pattern():find("/elemType/presentation")
	local diagram = utilities.current_diagram()
	diagram:find("/collection"):link("element", elements)
	utilities.activate_element(elements)
end

function fill_pattern_list_box(list_box, edit_button, delete_button)
	utilities.current_diagram():find("/target_type/paletteType/paletteElementType[id = 'pattern']"):each(function(palette_box)
		list_box:link("item", lQuery.create("D#Item", {value = palette_box:attr("caption")}):link("type", palette_box))
	end)
	local first_item = list_box:find("/item:first()")
	if first_item:is_not_empty() then
		list_box:link("selected", first_item)
	else
		edit_button:attr({enabled = "false"})
		delete_button:attr({enabled = "false"})
	end
end

function delete_pattern()
	local palette_box, selected_item, list_box = get_selected_pattern()
	palette_box:delete()
	selected_item:delete()
	local first_item = list_box:find("/item:first()")
	if first_item:is_not_empty() then
		list_box:link("selected", first_item)
	else
		local edit_button = d.get_component_by_id("edit_button"):attr({enabled = "false"})
		local delete_button = d.get_component_by_id("delete_button"):attr({enabled = "false"})
		utilities.refresh_form_component(edit_button)
		utilities.refresh_form_component(delete_button)
	end
	utilities.refresh_form_component(list_box)
end

function get_selected_pattern()
	local list_box = d.get_component_by_id("pattern_list_box")
	local selected_item = list_box:find("/selected")
	local pattern_name = selected_item:attr("value")
	return utilities.current_diagram():find("/target_type/paletteType/paletteElementType[id = 'pattern'][caption = '" .. pattern_name  .. "']"), selected_item, list_box
end

function edit_pattern()
	local field_table = add_pattern_form("lua.configurator.configurator.close_edit_pattern_form")
	fill_pattern_form(field_table)
end

function close_edit_pattern_form()
	local values = get_pattern_values()
	local palette_box, selected_item, list_box = get_selected_pattern()
	palette_box:attr(values)
	selected_item:attr({value = values["caption"]})
	utilities.refresh_form_component(list_box)
	d.close_form()
end



function edit_head_engine()
	edit_engine("GraphDiagramEngine", "Graph Diagram Engine", "lua.configurator.configurator.update_graph_engine")
end

function edit_engine(engine_name, form_caption, func_name)
	local form = d.add_form({id = "form", caption = form_caption, minimumWidth = 670, minimumHeight = 50})
	local graph_engine = lQuery(engine_name)
	local list = utilities.get_lQuery_object_attribute_list(graph_engine)
	for index, value in pairs(list[1]) do
		add_input_field_function(form, index, index, graph_engine, func_name)
	end
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	d.show_form(form)
end

function edit_tree_engine()
	edit_engine("TreeEngine", "Tree Engine",  "lua.configurator.configurator.update_tree_engine")
end

function update_engine(engine_name)
	local attr, value = get_event_source_attrs("text")
	local graph_engine = lQuery(engine_name):attr({[attr] = value})
	d.delete_event()
end

function update_tree_engine()
	update_engine("TreeEngine")	
end

function update_graph_engine()
	update_engine("GraphDiagramEngine")
end

function edit_project_object()
	local form = d.add_form({id = "form", caption = "Project Properties", minimumWidth = 200, minimumHeight = 50})	
	local tool_type = lQuery("ToolType")
	local project = tool_type:find("/presentationElement")
	d.add_row_labeled_field(form, {caption = "Name"}, {id = "name", text = project:attr("name")}, {id = "row_name"}, "D#InputField", {FocusLost = "lua.configurator.configurator.update_project_attribute"})
	d.add_row_labeled_field(form, {caption = "Version"}, {id = "version", text = project:attr("version")}, {id = "row_version"}, "D#InputField", {FocusLost = "lua.configurator.configurator.update_project_attribute"})
	add_transformation_field_with_events(form, "On Open", "procOnOpen", tool_type, {FocusLost = "lua.configurator.configurator.update_project_obj"})
	add_transformation_field_with_events(form, "On Close", "procOnClose", tool_type, {FocusLost = "lua.configurator.configurator.update_project_obj"})
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	d.show_form(form)
end

function update_project_obj()
	local attr, value = get_event_source_attrs("text")
	local tool_type = lQuery("ToolType")
	add_translet_to_source(tool_type, attr, value)
	d.delete_event()
end

function update_project_attribute()
	local attr, value = get_event_source_attrs("text")
	local project = lQuery("Project")
	project:attr({[attr] = value})
	d.delete_event()
end

function update_project_version()
	local project = lQuery("Project")
	local version = project:attr("version")
	version = version + 1
	project:attr({version = version})
end

function make_repozitory_class_diagram()
	local repo_diagram_type = lQuery("GraphDiagramType[id = 'Repository']")
	--repo_diagram_type:find("/graphDiagram"):delete()
	local count = repo_diagram_type:find("/graphDiagram"):size()
	count = count + 1

	--utilities.add_graph_diagram_to_graph_diagram_type("Class Diagram", repo_diagram_type)
	local diagram = utilities.add_graph_diagram_to_graph_diagram_type("Metamodel" .. count, repo_diagram_type)
	make_repository_classes(diagram, repo_diagram_type)
	utilities.execute_cmd("ActiveDgrCmd", {graphDiagram = diagram})
	utilities.execute_cmd("OkCmd")
end

function make_repository_classes(diagram, diagram_type)
--kompozicijas, visparinasanas, vajag tikt vala no mantotajam asociacijam un atributiem
	local diagram_list = {}
	diagram_list["Classes"] = {}
	local class_list = repo.class_list()
	for _, class in ipairs(class_list) do
		local class_name = class.name
		if string.sub(class_name, 1, 2) ~= "D#" then 
			local class_id = rep.GetObjectTypeIdByName(class_name)
			local attr_list = class:property_list()
			generate_attr_types(attr_list)
			local dictionary = transform_attr_list_to_dictionary(attr_list)
			local classes = {}
			local elem_type = diagram_type:find("/elemType[id = 'Class']")	 
			diagram_list["Classes"][class_id] = {class = add_class(class_name, diagram), attrs = dictionary}
		end
	end
	local links = lQuery.foldr(lQuery.map(class_list, function(x) return rep.GetLinkTypeIdList(x.id) end), {}, function(accumulator, link_list) 		
		for _, link_id in ipairs(link_list) do
			local inv_link_id = rep.GetInverseLinkTypeId(link_id)
			if accumulator[inv_link_id] == nil then
				accumulator[link_id] = link_id	
			end
		end
		return	accumulator
	end)
	for link_id, link in pairs(links) do
		local association = {}
		local role_list = rep.GetLinkTypeAttributes(link_id)
		make_repository_line(diagram, role_list, diagram_list["Classes"])
	end
	for class_id, class_entity in pairs(diagram_list["Classes"]) do
		local sub_class_list = rep.GetExtensionIdList(class_id)
		for _, sub_class_id in ipairs(sub_class_list) do
			local sub_class_entity = diagram_list["Classes"][sub_class_id]
			if sub_class_entity ~= nil then
				remove_dublicate_attributes(sub_class_entity, class_entity)
				make_repository_generalization(sub_class_entity["class"], class_entity["class"], diagram)
			end
		end
	end
	for _, class_entity in pairs(diagram_list["Classes"]) do
		local class = class_entity["class"]
		local attr_list = class_entity["attrs"]
		local attrs = utilities.concat_dictionary(attr_list, "\n")
		add_class_attributes(class, attrs)
	end
end

function generate_attr_types(attr_list)
--hacks, vajag nemt tipus no repozitorija
	for i, attr in ipairs(attr_list) do
		local data_type = ":String"
		if string.find(attr, "is", 1) == 1 then
			data_type = ":Boolean"
		end
		attr_list[i] = attr .. data_type
	end
end

function transform_attr_list_to_dictionary(attr_list)
	local dictionary = {}
	for _, id in ipairs(attr_list) do
		dictionary[id] = id
	end
return dictionary
end

function remove_dublicate_attributes(sub_class_entity, super_class_entity)
	local super_class_attr_list = super_class_entity["attrs"]
	local sub_class_attr_list = sub_class_entity["attrs"]
	for _, attr in pairs(super_class_attr_list) do
		if sub_class_attr_list[attr] ~= nil then
			sub_class_attr_list[attr] = nil
		end
	end
end

function make_repository_generalization(sub_class, super_class, diagram)
	local edge_type = lQuery("GraphDiagramType[id = 'Repository']/elemType[id = 'Generalization']")
	local edge = core.add_edge(edge_type, sub_class, super_class, diagram)
	
end

function get_repository_line_types(line_type_name)
	local source_type = lQuery("GraphDiagramType[id = 'Repository']")
	local line_type = source_type:find("/elemType[id = '" .. line_type_name .. "']")
	local direct_role_type = line_type:find("/compartType[id = 'DirectRole']")
	local inverse_role_type = line_type:find("/compartType[id = 'InverseRole']")
	local direct_cardinality = line_type:find("/compartType[id = 'DirectCardinality']")
	local inverse_cardinality = line_type:find("/compartType[id = 'InverseCardinality']")
return line_type, direct_role_type, inverse_role_type, direct_cardinality, inverse_cardinality
end

function make_repository_line(diagram, role_list, class_list)
print(dumptable(role_list))
	local line_type_name = "Association"
	if role_list.role ~= 4 or role_list.inv_role ~= 4 then
		line_type_name = "Composition"
	end
	local role_id = role_list.link_type_id
	local inv_role_id = role_list.inv_link_type_id
	local card_id = role_list.cardinality
	local inv_card_id = role_list.inv_cardinality
	
	local direct_role = rep.GetTypeName(role_id)
	local inverse_role = rep.GetTypeName(inv_role_id)

	print(direct_role)
	print(inverse_role)

	local direct_cardinality = get_cardinality(card_id)
	local inverse_cardinality = get_cardinality(inv_card_id)

 	local direct_class_id = role_list.object_type_id
	local inverse_class_id = role_list.inv_object_type_id
	local start_element = class_list[direct_class_id]
	local end_element = class_list[inverse_class_id]
	if start_element ~= nil and end_element ~= nil then
		local edge_type, direct_role_type, inverse_role_type, direct_cardinality_type, inverse_cardinality_type = get_repository_line_types(line_type_name)
		local edge = core.add_edge(edge_type, end_element["class"], start_element["class"], diagram)
			if line_type_name == "Composition" then
				inverse_role = ""
				inverse_cardinality = ""
			end
			add_compartment(direct_role_type, edge, direct_role)
			add_compartment(inverse_role_type, edge, inverse_role)
			add_compartment(direct_cardinality_type, edge, direct_cardinality)
			add_compartment(inverse_cardinality_type, edge, inverse_cardinality)
			
		return edge
	end
	
end

function get_cardinality(val)
--Card_01 = 1,
--Card_0N = 2,
--Card_1 = 3,
--Card_1N = 4,
	if val == 1 then
		return "0..1"
	elseif val == 2 then
		return "*"
	elseif val == 3 then
		return "1"
	elseif val == 4 then
		return "1..*"
	end
end

function get_repository_types()
	local source_type = lQuery("GraphDiagramType[id = 'Repository']")
	local instance_type = source_type:find("/elemType[id = 'Class']")
	local name_compart_type = instance_type:find("/compartType[id = 'Name']")
	local value_compart_type = instance_type:find("/compartType[id = 'Value']")
return instance_type, name_compart_type, value_compart_type
end

function add_class(class_name, diagram)
	local class_type, name_compart_type = get_repository_types()
	local node = core.add_node(class_type, diagram)
		add_compartment(name_compart_type, node, class_name)
return node
end

function add_class_attributes(node, attributes)
	local _, _, value_compart_type = get_repository_types()
		add_compartment(value_compart_type, node, attributes)
end

function add_diagram_translets()
	local form = d.add_form({id = "form", caption = "Diagram Translets", minimumWidth = 70, minimumHeight = 50})
	local diagram_type = utilities.current_diagram():find("/target_type")
	add_diagram_type_translet_field(form, "Create Diagram", "procCreateDiagram", diagram_type)
	add_diagram_type_translet_field(form, "Delete Diagram", "procDeleteDiagram", diagram_type)
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	d.show_form(form)
end

function add_diagram_type_translet_field(container, label, field_id, diagram_type)
	local translet_name = diagram_type:find("/translet[extensionPoint = " .. field_id .. "]"):attr_e("procedureName")
	local row = d.add_row_labeled_field(container, {caption = label}, {id = field_id, text = translet_name}, {id = "row_" .. field_id}, "D#InputField", {FocusLost = "lua.configurator.configurator.set_diagram_translets"})
end

function set_diagram_translets()
	local attr, value = get_event_source_attrs("text")
	local diagram_type = utilities.current_diagram():find("/target_type")
	local translet = diagram_type:find("/translet[extensionPoint = '" .. attr .. "']")
	if value == "" then
		translet:delete()
	else
		if translet:is_empty() then
			cu.add_translet_to_obj_type(diagram_type, attr, value)
		else	
			translet:attr({procedureName = value})
		end
	end
end

function add_translet_to_source(source, extension_point, value)
	local translet_name, translet, _ = utilities.get_translet_by_name(source, extension_point)
	if value == "" then
		translet:delete()
	else
		if translet:is_empty() then
			cu.add_translet_to_obj_type(source, extension_point, value)
		else	
			translet:attr({procedureName = value})
		end
	end
end

function set_model_diagram_name()
	local form = d.add_form({id = "form", caption = "Diagram Name", minimumWidth = 120})
	local diagram = utilities.current_diagram()
	add_input_field_function(form, "Name", "caption", diagram, "lua.configurator.configurator.update_model_diagram_caption")
	local button_box = d.add_component(form, {id = "button_box", horizontalAlignment = 1}, "D#HorizontalBox")	
	local close_button = d.add_button(button_box, {id = "close_button", caption = "Close"}, {Click = "lua.configurator.configurator.close_form()"}):link("defaultButtonForm", form)
	d.show_form(form)
end

function update_model_diagram_caption()
	local diagram = utilities.current_diagram()
	local _, value = get_event_source_attrs("text")
	utilities.set_diagram_caption(diagram, value)
	d.delete_event()	
end



--Loggging functions

function log_button_press(param)
	local event = "Button"
	if type(param) == "string" then
		report.event(event, {
			Button = param
		})
	else
		report.event(event, param)
	end
end

function log_configurator_field(name, list)
	report.event("Field " .. name, list)
end

function log_table(list)
	report.event("Table", list)
end

function log_list_box(list)
	report.event("ListBox", list)
end

function remove_diagram_type_with_elem_types(diagram_type)
	diagram_type:find("/elemType"):each(function(elem_type)
		delete_elem_type(elem_type)	
	end)
	delete_diagram_type(diagram_type)
end

