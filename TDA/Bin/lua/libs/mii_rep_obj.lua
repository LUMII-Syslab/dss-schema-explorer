module(..., package.seeall)

mii_rep = require("lua_mii_rep")

lQuery = require "lQuery"

local class_cache = {} -- cache for classes
setmetatable(class_cache, {__mode = "v"})

local object_cache = {} -- cache for objects
setmetatable(object_cache, {__mode = "v"})

objects = {}
function objects.filter_by_type(_, type_name)
  local cl = class_by_name(type_name)
  return cl:objects()
end

function objects.filter_by_attribute(_, name, value, relation)
  local classes = class_list()
  local results, result_count = {}, 0
  
  for _, cl in ipairs(classes) do
    if cl:has_property(name) then
      local object_count = mii_rep.GetObjectNum(cl.id)

      for i = 0, object_count - 1 do
        local obj = object.new(mii_rep.GetObjectIdByIndex(cl.id, i))
        if relation then -- paarbaude uz veertiibu
          if obj:get_property(name) == value then
            result_count = result_count + 1
            results[result_count] = obj
          end
        else
          result_count = result_count + 1
          results[result_count] = obj
        end
      end
    end
  end
  -- log(result_count)
  return results
end

function objects.navigate(self, role_name)
  local navig_start = {}
  

  local classes = class_list()
  local result_count = 0
  
  for _, cl in ipairs(classes) do
    if cl:has_link(role_name) then
      local object_count = mii_rep.GetObjectNum(cl.id)

      for i = 0, object_count - 1 do
        local obj = object.new(mii_rep.GetObjectIdByIndex(cl.id, i))
        local linked_objects = obj:get_linked_by(role_name)
        for j, o in ipairs(linked_objects) do
          result_count = result_count + 1
          navig_start[result_count] = obj
        end
      end
    end
  end

  
  local navig_res = lQuery.foldr(lQuery.map(navig_start, function(obj) return obj:get_linked_by(role_name) end),
                                {},
                                lQuery.merge)
  
  return navig_res
end

function objects.intersect_selectors(self, selector_array)
  local results = lQuery.eval(selector_array[1], self)
  
  for i, selector in ipairs(selector_array) do
    if i ~= 1 then
      results = lQuery.eval(selector, lQuery.new(results, self))
    end
  end
  return results
end

function objects.union_selectors(self, selector_array)
  local res = lQuery.foldr(lQuery.map(selector_array, function(selector) return lQuery.eval(selector, self) end),
                          {},
                          lQuery.merge)
  return res
end

function objects.filter_with_function(self, arg)
  local res = {}
  return res
end


function class_by_name(name)
  local id = mii_rep.GetObjectTypeIdByName(name)
  assert(id ~= 0, "there is no class " .. name)
  return class.new(id)
end

local class_list_mt = {
  __tostring = function(list)
    local name_list = {}
    for i, class in ipairs(list) do
      name_list[i] = class.name
    end
    return table.concat(name_list, ", ") 
  end
}

function class_list (abbrev)
  local class_list = {}
  local id_list = mii_rep.GetObjectTypeIdList()
  for _, id in ipairs(id_list) do
    table.insert(class_list, class.new(id))
  end
  
  setmetatable(class_list, class_list_mt)
  
  return class_list
end

class = {}
class.proto = {
  objects = function(self)
    local object_count = mii_rep.GetObjectNum(self.id)
    local objects = {}
    
    for i = 0, object_count - 1 do
      objects[i+1] = object.new(mii_rep.GetObjectIdByIndex(self.id, i))
    end
    
    return objects
  end
  
  ,first_object_id_with_attr_val = function(self, property_name, value)
    local property_id = self:property_id_by_name(property_name)
    return mii_rep.GetObjectIdByPropertyValue(self.id, property_id, value)
  end

  ,has_property = function(self, property_name)
    if self.properties[property_name] then
      return true
    else
      return mii_rep.GetPropertyTypeIdByName(self.id, property_name) ~= 0
    end
  end
  
  ,property_id_by_name = function(self, property_name)
    if self.properties[property_name] then
      return self.properties[property_name]
    else
      local property_type_id = mii_rep.GetPropertyTypeIdByName(self.id, property_name)
      assert(property_type_id ~= 0, tostring(self.name) .. " doesn't have a property " .. property_name)
      self.properties[property_name] = property_type_id
      return property_type_id
    end
  end
  
  ,has_link = function(self, link_name, target_class_name)
    local result = false
    local link_type_id = 0
    
    if self.links[link_name] then
      link_type_id = self.links[link_name]
      result = true
    else
      link_type_id = mii_rep.GetLinkTypeIdByName(self.id, link_name)
      result = (link_type_id ~= 0)
    end
    
    -- TODO if speed problems, consider adding cache for link to target class existence
    if result == true and target_class_name then
      local target_class = class.new(mii_rep.GetLinkTypeAttributes(link_type_id).object_type_id)
      result = class.create(target_class_name):is_subtype_of(target_class)
    end
    
    return result
  end
  
  ,link_id_by_name = function(self, link_name)
    if self.links[link_name] then
      return self.links[link_name]
    else
      local link_type_id = mii_rep.GetLinkTypeIdByName(self.id, link_name)
      assert(link_type_id ~= 0, tostring(self.name) .. " doesn't have a link " .. link_name)
      self.links[link_name] = link_type_id
      return link_type_id
    end
  end
  
  ,property_list = function(self)
    local property_type_id_list = mii_rep.GetPropertyTypeIdList(self.id)
    local property_name_list = {}
    setmetatable(property_name_list, {__tostring = function(list) return table.concat(list, ", ") end})
    for i, id in ipairs(property_type_id_list) do
      property_name_list[i] = mii_rep.GetTypeName(id)
    end
    return property_name_list
  end
  
	,link_list = function(self)
	  local link_type_id_list = mii_rep.GetLinkTypeIdList(self.id)
	  local link_name_list = {}
	  setmetatable(link_name_list, {__tostring = function(list) return table.concat(list, ", ") end})
	  for i, id in ipairs(link_type_id_list) do
	    link_name_list[i] = mii_rep.GetTypeName(id)
	  end
	  return link_name_list
	end

  ,is_subtype_of = function(self, supertype)
    return (self.id == supertype.id) or mii_rep.ExtendsExtends(self.id, supertype.id)
  end
  
  ,reset_link_cache = function(self)
    self.links = {}
    for _, subclass_id in ipairs(mii_rep.GetExtensionIdList(self.id)) do
      class.new(subclass_id):reset_link_cache()
    end
  end
  
  ,reset_property_cache = function(self)
    self.properties = {}
    for _, subclass_id in ipairs(mii_rep.GetExtensionIdList(self.id)) do
      class.new(subclass_id):reset_property_cache()
    end
  end
}

class.proto.__index = class.proto
class.new = function(id)
  if class_cache[id] then
    return class_cache[id]
  else
    local type_name = mii_rep.GetTypeName(id)
    assert(type_name ~= "", "class with id " .. id .. " doesn't exist")

    local cl = {}
    cl.id = id
    cl.name = type_name
    cl.properties = {}
    cl.links = {}
    setmetatable(cl, class.proto)
  
    class_cache[id] = cl
    return class_cache[id]
  end
end

class.create = function(class_name)
  local class_id = mii_rep.GetObjectTypeIdByName(class_name)
  if  class_id == 0 then
    class_id = mii_rep.CreateObjectType(0, class_name, "")
  end
  return class.new(class_id)
end

local function construct_memoized_fn(fn)
  local cache = {}
  setmetatable(cache, {__mode = "v"})
  return function(o)
    if cache[o] then
      return cache[o]
    else
      local v = fn(o)
      cache[o] = v
      return v
    end
  end
end

object = {}
object.proto = {
  class = construct_memoized_fn(function(self)
    return class.new(mii_rep.GetObjectTypeId(self.id))
  end)
  
  ,get_property_table = function(self)
    local result = {}
    local class = self:class()
    local class_property_list = class:property_list()
    for _, property_name in ipairs(class_property_list) do
      local value = self:get_property(property_name)
      if value ~= "" then
        result[property_name] = value
      end
    end
    return result
  end

  ,get_property = function(self, property_name)
    local value
    
    if mii_rep.ObjectExists(self.id) and self:class():has_property(property_name) then
      local property_type_id = self:class():property_id_by_name(property_name)
      value = mii_rep.GetPropertyValue(self.id, property_type_id)
    end
    
    return value
  end
  
  ,set_property = function(self, property_name, property_value)
    if mii_rep.ObjectExists(self.id) then
      if not self:class():has_property(property_name) then
        -- create property type if it does not exist
        property_type_id = mii_rep.CreatePropertyType1(property_name, "Automaticaly created by lua", 0, 3, "")
        assert(property_type_id ~= 0, tostring(self.id) .. " failed to create a property " .. property_name)
        mii_rep.AddPropertyType(self:class().id, property_type_id)
      end
      local property_type_id =  self:class():property_id_by_name(property_name)
      mii_rep.AddProperty(self.id, property_type_id, tostring(property_value))
    end
    return self
  end
  
  ,get_linked_by = function(self, link_name)
    if mii_rep.ObjectExists(self.id) then
      if not self:class():has_link(link_name) then
        return {}
      else
        local link_type_id = self:class():link_id_by_name(link_name)
      
        local linked_object_count = mii_rep.GetLinkedObjectNum(self.id, link_type_id)
        local linked_objects = {}
      
        for i = 0, linked_object_count - 1 do
          linked_objects[i+1] = object.new(mii_rep.GetLinkedObjectIdByIndex(self.id, link_type_id, i))
        end
      
        return linked_objects
      end
    else
      return {}
    end
  end
  
	,get_inv_linked_by = function(self, inv_link_name)
		local results = {}

    if mii_rep.ObjectExists(self.id) then

  		local obj_class = self:class()
  		
  		local outgoing_link_type_id_list = mii_rep.GetLinkTypeIdList(obj_class.id)
  		
  		for _, link_type_id in ipairs(outgoing_link_type_id_list) do
  			local inv_link_type_id = mii_rep.GetInverseLinkTypeId(link_type_id)
  			local inv_link_type_name = mii_rep.GetTypeName(inv_link_type_id)
  			
  			if (inv_link_name == inv_link_type_name) then
  				local linked_object_count = mii_rep.GetLinkedObjectNum(self.id, link_type_id)
  	      
  				for i = 0, linked_object_count - 1 do
  					table.insert(results, object.new(mii_rep.GetLinkedObjectIdByIndex(self.id, link_type_id, i)))
  	      end
  			end
  		end
		end

		return results
  end

  ,add_link = function(self, link_name, obj, after_obj)
    -- NOTE if speed problems you can add extra cache in has_link
    if mii_rep.ObjectExists(self.id) and self:class():has_link(link_name, obj:class().name) then

      local link_type_id = self:class():link_id_by_name(link_name)
      
  		if after_obj and self:exists_link(link_name, after_obj) then
  			local currently_linked = self:get_linked_by(link_name)
  			
  			mii_rep.DeleteLink(link_type_id, self.id, 0) --remove all links
  			
  			for _, o in ipairs(currently_linked) do
  				mii_rep.CreateLink(link_type_id, self.id, o.id)
  				if after_obj == o then
  					mii_rep.CreateLink(link_type_id, self.id, obj.id)
  				end
  			end
  		else
  			mii_rep.CreateLink(link_type_id, self.id, obj.id)
  		end
    end

    return self
  end
	
	,exists_link = function(self, link_name, obj)
    if mii_rep.ObjectExists(self.id) and self:class():has_link(link_name) then
  		local link_type_id = self:class():link_id_by_name(link_name)
  		return mii_rep.AlreadyConnected(link_type_id, self.id, obj.id)
    else
      return false
    end
	end
  
  ,remove_link = function(self, link_name, obj)
    if mii_rep.ObjectExists(self.id) then
      local link_type_id = self:class():link_id_by_name(link_name)
      
      if obj then
        obj_id = obj.id
      else
        obj_id = 0
      end
      
      mii_rep.DeleteLink(link_type_id, self.id, obj_id)
    end

    return self
  end
  
  ,has_type = function (self, type_name)
    if mii_rep.ObjectExists(self.id) then
      return self:class():is_subtype_of(class_by_name(type_name))
    else
      return false
    end
  end
  
  ,delete = function (self)
    object_cache[self.id] = nil -- delete object from cache
    mii_rep.DeleteObjectHard(self.id)
  end

	,attr = function (self, attr_name)
    if mii_rep.ObjectExists(self.id) then
		  return lQuery.new(self):attr(attr_name)
    end
	end
	
	,get_property_table = function(self)
    local result = {}

    if mii_rep.ObjectExists(self.id) then
      local class = self:class()
      local class_property_list = class:property_list()
      for _, property_name in ipairs(class_property_list) do
        local value = self:get_property(property_name)
        if value ~= "" then
          result[property_name] = value
        end
      end
    end

    return result
  end

  ,property_key_val_pairs = function(self)
    return coroutine.wrap(function ()
      local property_list = {}
      if mii_rep.ObjectExists(self.id) then property_list = self:class():property_list() end
      for _, property_name in ipairs(property_list) do
        coroutine.yield(property_name, self:get_property(property_name) or "")
      end
    end)
  end
}
object.proto.__index = function(self, index)
	if object.proto[index] then
		return object.proto[index]
	end

	local obj_wrapped_in_lQuery = lQuery.new(self)
	local tmp_lQuery_proto_fn = obj_wrapped_in_lQuery[index]
	if tmp_lQuery_proto_fn then
		return function(_, ...)
			return tmp_lQuery_proto_fn(obj_wrapped_in_lQuery, ...)
		end
	end
end
object.new = function(id)
  if object_cache[id] then
    return object_cache[id]
  else
    assert(mii_rep.ObjectExists(id), "object " .. id .. " doesn't exist")
    local obj = {}
    obj.id = id
  
    setmetatable(obj, object.proto)
    object_cache[id] = obj
    return object_cache[id]
  end
end

function exists_object_with_repo_id (repo_id)
  return mii_rep.ObjectExists(repo_id)
end

function create_object (class_name)
  local class_id = mii_rep.GetObjectTypeIdByName(class_name)
  assert(class_id ~= 0, "class " .. class_name .. " dosn't exists")
  return object.new(mii_rep.CreateObject(class_id))
end


-- functions for creating types
function add_class(class_name)
	local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	if class_id == 0 then
		class_id = mii_rep.CreateObjectType(0, class_name, "")
	end
	assert(class_id ~= 0, "couldnt't create class " .. class_name)
end

function table_to_occurence_table(t)
  local result = {}
  for k, v in pairs(t) do
    result[v] = true
  end
  return result
end

function get_direct_link_type_ids(type_id)
  local link_ids = mii_rep.GetLinkTypeIdList(type_id)
  
  local super_id = mii_rep.GetExtendsId(type_id)
  local super_link_ids = (super_id ~= 0) and mii_rep.GetLinkTypeIdList(super_id) or {}
  
  local occurence_table = table_to_occurence_table(super_link_ids)
  
  local results = {}
  for _, link_id in ipairs(link_ids) do
    if not occurence_table[link_id] then
      table.insert(results, link_id)
    end
  end
  
  return results
end

function delete_direct_link_types(type_id)
  local link_type_ids = get_direct_link_type_ids(type_id)
  
  for _, link_type_id in ipairs(link_type_ids) do
    local status = mii_rep.DeleteLinkType(link_type_id)
    log("-----", status)
    -- assert(status ~= 0, "failed to delete link type " .. link_type_id .. " : " .. mii_rep.GetTypeName(link_type_id))
    -- status = mii_rep.DeleteLinkType(mii_rep.GetInverseLinkTypeId(link_type_id))
    -- assert(status == 0, "failed to delete inverse link type " .. link_type_id)
  end
end

function delete_instances(type_id)
  local objects = class.new(type_id):objects()
  for _, o in ipairs(objects) do
    o:delete()
  end
end

function delete_class(class_name, with_subclasses)
  local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	if class_id ~= 0 then
	  local function delete_type_with_subtypes(type_id)
			if with_subclasses then
	      local subclass_ids = mii_rep.GetExtensionIdList(type_id)
	      for _, sub_id in ipairs(subclass_ids) do
	        delete_type_with_subtypes(sub_id)
	      end
			else
				local subclass_ids = mii_rep.GetExtensionIdList(type_id)
	      for _, sub_id in ipairs(subclass_ids) do
	        remove_super_class(mii_rep.GetTypeName(sub_id))
	      end
			end
		
			delete_instances(type_id)
			delete_direct_link_types(type_id)
      
			status = mii_rep.DeleteObjectType(type_id)
			assert(status ~= 0, "couldnt't delete class " .. class_name)
      
			class_cache[type_id] = nil
		end
    
    delete_type_with_subtypes(class_id)
	end
end

function set_super_class(class_name, super_class_name)
	local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	assert(class_id ~= 0, "class " .. class_name .. " dosn't exists")
	
	local super_class_id = mii_rep.GetObjectTypeIdByName(super_class_name)
	assert(super_class_id ~= 0, "class " .. super_class_name .. " dosn't exists")
	
	local status, details = mii_rep.GetObjectTypeAttributes1(class_id)
	assert(status ~= 0, "couldn't get class details")
	status = mii_rep.UpdateObjectType1(super_class_id, class_id, details.name, details.description)
	assert(status ~= 0, "couldn't change class parent")
end

function remove_super_class(class_name)
	local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	assert(class_id ~= 0, "class " .. class_name .. " dosn't exists")
	
	local super_class_id = mii_rep.GetExtendsId(class_id)
	if super_class_id ~= 0 then
	  local status, details = mii_rep.GetObjectTypeAttributes1(class_id)
	  assert(status ~= 0, "couldn't get class details")
	  status = mii_rep.UpdateObjectType1(0, class_id, details.name, details.description)
	  assert(status ~= 0, "couldn't change class parent")
	end
end

property_base_type = {
        string = 0,
       integer = 1,
         float = 2,
       boolean = 3,
    hyper_text = 4,
     date_time = 5,
    expression = 6,
   enumeration = 7,
  resource_ref = 99
}

function add_property(class_name, property_name, property_type)
  property_type = property_type or property_base_type.string
	local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	assert(class_id ~= 0, "class " .. class_name .. " dosn't exists")
	local property_type_id = mii_rep.GetPropertyTypeIdByName(class_id, property_name)
	if property_type_id == 0 then
		-- create property type if it does not exist
		property_type_id = mii_rep.CreatePropertyType1(property_name, "", property_type, 3, "")
		assert(property_type_id ~= 0, "couldn't create a property " .. property_name .. " for class " .. class_name)
		assert(mii_rep.AddPropertyType(class_id, property_type_id), "failed to add property " .. property_name .. " to class " .. class_name)
	end
end

function delete_property(class_name, property_name)
	local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	assert(class_id ~= 0, "class " .. class_name .. " dosn't exists")
	
	local property_type_id = mii_rep.GetPropertyTypeIdByName(class_id, property_name)
  if property_type_id ~= 0 then
    local c = class.new(class_id)
    c:reset_property_cache()
    --delete property from all instances
    local objects = c:objects()
    for _, o in ipairs(objects) do
      mii_rep.AddProperty(o["id"], property_type_id, "")
    end
    
    status = mii_rep.RemovePropertyType(class_id, property_type_id)
    assert(status ~= 0, "couldn't delete a property " .. property_name .. " from class " .. class_name)
	end
end

local link_type_constants = {
  Card_01 = 1,
  Card_0N = 2,
   Card_1 = 3,
  Card_1N = 4,
  
               Role_Group = 1,
              Role_Member = 11,
           Role_Aggregate = 2,
                Role_Part = 12,
    Role_DependentPartner = 3,
  Role_IndependentPartner = 4
}

function CreateLinkType(params)
  local description = params.description or ""
  
  local start_class_name = assert(params.start_class_name)
  local start_role_name = assert(params.start_role_name)
  local start_cardinality = params.start_cardinality or link_type_constants.Card_0N
  local start_role = params.start_role or link_type_constants.Role_IndependentPartner
  local start_is_ordered = params.start_is_ordered
  
  local end_class_name = assert(params.end_class_name)
  local end_role_name = assert(params.end_role_name)
  local end_cardinality = params.end_cardinality or link_type_constants.Card_0N
  local end_role = params.end_role or link_type_constants.Role_IndependentPartner
  local end_is_ordered = params.end_is_ordered
  
  
  
  local start_class_id = mii_rep.GetObjectTypeIdByName(start_class_name)
	assert(start_class_id ~= 0, "failed to create link type: class " .. start_class_name .. " dosn't exists")
  
  local end_class_id = mii_rep.GetObjectTypeIdByName(end_class_name)
	assert(end_class_id ~= 0, "failed to create link type: class " .. end_class_name .. " dosn't exists")
  
  local link_type_id = mii_rep.GetLinkTypeIdByName(start_class_id, end_role_name)
	local inv_link_type_id = mii_rep.GetLinkTypeIdByName(end_class_id, start_role_name)
  
  
  if link_type_id == 0 and inv_link_type_id == 0 then
    -- create property type if it does not exist
    local link_type_id = mii_rep.CreateLinkType(start_role_name, description, end_role_name,
  	                                          start_class_id, start_cardinality, start_role, start_is_ordered,
  	                                          end_class_id,   end_cardinality,   end_role,   end_is_ordered)
    
		assert(link_type_id ~= 0, "failed to create link type: " .. start_class_name .. "." .. start_role_name .. "/".. end_role_name .. "." .. end_class_name)
	elseif link_type_id ~= 0 and inv_link_type_id ~= 0 then
		if link_type_id ~= mii_rep.GetInverseLinkTypeId(inv_link_type_id) or 
			 inv_link_type_id ~= mii_rep.GetInverseLinkTypeId(link_type_id) then
			error("failed to create link type: there already is a link type " .. start_class_name .. "." .. start_role_name .. "/".. end_role_name .. "." .. end_class_name)
		end
		-- link already exists
	elseif link_type_id ~= 0 then
		error("failed to create link type " .. start_class_name .. "." .. end_role_name .. ":" .. end_class_name ..
		        " , because there is a link type " .. start_class_name .. "." .. end_role_name .. ":" .. mii_rep.GetTypeName(link_type_id))
	elseif inv_link_type_id ~= 0 then
		error("failed to create link type " .. end_class_name .. "." .. start_role_name .. ":" .. start_class_name ..
		        " , because there is a link type " .. end_class_name .. "." .. start_role_name .. ":" .. mii_rep.GetTypeName(inv_link_type_id))
	else
		error("failed to create link type: couldn't create link type " .. start_class_name .. "." .. start_role_name .. "/".. end_role_name .. "." .. end_class_name)
	end
end

function add_link(start_class_name, start_role_name, end_role_name, end_class_name)
  CreateLinkType({
    start_class_name = start_class_name,
    start_role_name = start_role_name,
    start_is_ordered = true,
    
    end_role_name = end_role_name,
    end_class_name = end_class_name,
    -- end_is_ordered = true
  })
end

function add_composition(start_class_name, start_role_name, end_role_name, end_class_name)
  CreateLinkType({
    start_class_name = start_class_name,
    start_role_name = start_role_name,
    start_is_ordered = true,
    
    end_role_name = end_role_name,
    end_class_name = end_class_name,
    -- end_is_ordered = true,
    end_role = link_type_constants.Role_Aggregate,
  })
end

function delete_link(start_class_name, end_role_name)
	local start_class_id = mii_rep.GetObjectTypeIdByName(start_class_name)
	assert(start_class_id ~= 0, "failed to delete link type: class " .. start_class_name .. " dosn't exists")
	local link_type_id = mii_rep.GetLinkTypeIdByName(start_class_id, end_role_name)
	local inv_link_type_id = mii_rep.GetInverseLinkTypeId(link_type_id)
	if link_type_id ~= 0 then
	  --delete property from all instances
	  local c = class.new(start_class_id)
	  c:reset_link_cache()
	  class.new(mii_rep.GetLinkTypeAttributes(link_type_id).object_type_id):reset_link_cache()
	  
	  
		local objects = c:objects()
		for _, o in ipairs(objects) do
			mii_rep.DeleteLink(link_type_id, o.id, 0)
		end
		status = mii_rep.DeleteLinkType(link_type_id)
		
		assert(status ~= 0, "failed to delete link type: " .. start_class_name .. "/" .. end_role_name)
	end
end

function class_exists(class_name)
	local class_id = mii_rep.GetObjectTypeIdByName(class_name)
	if class_id == 0 then
		return false
	else
		return true
	end
end
