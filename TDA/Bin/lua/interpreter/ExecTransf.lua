module(..., package.seeall)
require("utilities")

function ExecTransf()
	log("start exec transf")
	local ev = lQuery("ExecTransfEvent")
	local proc_name = ev:attr_e("info")
	if proc_name ~= "" then
		utilities.execute_translet(proc_name)
	end
	ev:delete()
	log("end exec taransf")
end
