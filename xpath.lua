-----------------------------------------------------------------------------
-- XPath module based on LuaExpat
-- Description: Module that provides xpath capabilities to xmls.
-- Author: Gal Dubitski
-- Version: 0.1
-- Date: 2008-01-15
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Declare module and import dependencies
-----------------------------------------------------------------------------

module(..., package.seeall)

local resultTable,option = {},nil

-----------------------------------------------------------------------------
-- Supported functions
-----------------------------------------------------------------------------

local function insertToTable(leaf)
	if type(leaf) == "table" then
		if option == nil then
			table.insert(resultTable,leaf)
		elseif option == "text()" then
			table.insert(resultTable,leaf[1])
		elseif option == "node()" then
			table.insert(resultTable,leaf.tag)
		elseif option:find("@") == 1 then
			table.insert(resultTable,leaf.attr[option:sub(2)])
		end
	end
end


local function match(tag,tagAttr,tagExpr,nextTag)
	
	local expression,evalTag
	
	-- check if its a wild card
	if tagExpr == "*" then
		return true
	end
	
	-- check if its empty
	if tagExpr == "" then
		if tag == nextTag then
			return false,1
		else
			return false,0
		end
	end
	
	-- check if there is an expression to evaluate
	if tagExpr:find("[[]") ~= nil and tagExpr:find("[]]") ~= nil then
		evalTag = tagExpr:sub(1,tagExpr:find("[[]")-1)
		expression = tagExpr:sub(tagExpr:find("[[]")+1,tagExpr:find("[]]")-1)
		if evalTag ~= tag then
			return false
		end
	else
		return (tag == tagExpr)
	end
	
	-- check if the expression is an attribute
	if expression:find("@") ~= nil then
		local evalAttr,evalValue
		evalAttr = expression:sub(expression:find("[@]")+1,expression:find("[=]")-1)
		evalValue = string.gsub(expression:sub(expression:find("[=]")+1),"'","")
		evalValue = evalValue:gsub("\"","")
		if tagAttr[evalAttr] ~= evalValue then
			return false
		else
			return true
		end
	end
	
end

local function parseNodes(tags,xmlTable,counter)
	if counter > #tags then
		return nil
	end
	local currentTag = tags[counter]
	local nextTag
	if #tags > counter then
		nextTag = tags[counter+1]
	end
	for i,value in ipairs(xmlTable) do
		if type(value) == "table" then
			if value.tag ~= nil and value.attr ~= nil then
				local x,y = match(value.tag,value.attr,currentTag,nextTag)
				if x then
					if #tags == counter then
						insertToTable(value)
					else
						parseNodes(tags,value,counter+1)
					end
				else
					if y ~= nil then
						if y == 1 then
							if counter+1 == #tags then
								insertToTable(value)
							else
								parseNodes(tags,value,counter+2)
							end
						else
							parseNodes(tags,value,counter)
						end
					end
				end
			end
		end
	end
end

function selectNodes(xml,xpath)
	assert(type(xml) == "table")
	assert(type(xpath) == "string")
	
	resultTable = {}
	local xmlTree = {}
	table.insert(xmlTree,xml)
	assert(type(xpath) == "string")
	
	tags = split(xpath,'[\\/]+')
	
	local lastTag = tags[#tags] 
	if lastTag == "text()" or lastTag == "node()" or lastTag:find("@") == 1 then
		option = tags[#tags]
		table.remove(tags,#tags)
	else
		option = nil
	end
	
	if xpath:find("//") == 1 then
		table.insert(tags,1,"")
	end
	
	parseNodes(tags,xmlTree,1)
	return resultTable
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 	table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end