local State = require "libraries.llove.state_machine".State

local EntityIdleState = setmetatable({}, State)
EntityIdleState.__index = EntityIdleState

return EntityIdleState