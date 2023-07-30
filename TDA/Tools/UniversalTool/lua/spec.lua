module(..., package.seeall)

require "utilities"
require "core"
prop = require("interpreter.Properties")
local report = require("reporter.report")

function get_compartment(element, cc)
  return element:find("/compartment:has(/compartType[id='"..cc.."'])")
end

function get_comp_value(element, cc)
  if element then
    return get_compartment(element, cc):attr("value") or ""
  else
    print("!!! Nebija elementa !!!", cc)
    return ""
  end	
end

function set_student()
  local element =  lQuery("Element"):filter(":has(/elemType[id='Students'])")
  local stud = get_comp_value(element, "AplNum")
  if stud == "" then
    utilities.activate_element(element)
    prop.Properties()
	report.event("MMD1 first time" )
  else
    report.event("MMD1 not first time", {Stud = stud} )
  end	
end

function close_stud()
  local element = utilities.active_elements()
  local stud = get_comp_value(element, "AplNum")
  report.event("MMD1 first time add Student name", {Stud = stud} )
end

