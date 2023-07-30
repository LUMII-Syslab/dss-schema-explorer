module(..., package.seeall)
require("utilities")

function L2Click()
	--print("L2Click")
	--local ev = lQuery("L2ClickEvent"):log
	local ev = lQuery("Event")--:log()
	utilities.call_element_proc_thru_type(ev:find("/element"), "l2ClickEvent")
	ev:delete()
end
