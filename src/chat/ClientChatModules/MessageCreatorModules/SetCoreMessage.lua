--	// FileName: SetCoreMessage.lua
--	// Written by: TheGamer101
--	// Description: Create a message label for a message created with SetCore(ChatMakeSystemMessage).

local clientChatModules = script.Parent.Parent
local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
local ChatConstants = require(clientChatModules:WaitForChild("ChatConstants"))
local util = require(script.Parent:WaitForChild("Util"))



function CreateSetCoreMessageLabel(messageData, channelName)
	local message = messageData.Message
	local extraData = messageData.ExtraData or {}
	local useFont = extraData.Font or ChatSettings.DefaultFont
	local useTextSize = extraData.TextSize or ChatSettings.ChatWindowTextSize
	local useColor = extraData.Color or ChatSettings.DefaultMessageColor
	local nice = messageData.Message ~= "Welcome to Degasi!" and true or false
	local formatUseName = nice and "[Server]:" or ""
	local speakerNameSize = util:GetStringTextBounds(formatUseName, useFont, useTextSize)
	local numNeededSpaces = util:GetNumberOfSpaces(formatUseName, useFont, useTextSize) + (nice and 1 or 0)

	local BaseFrame, BaseMessage = util:CreateBaseMessage(string.rep(" ", numNeededSpaces) .. message, useFont, useTextSize, useColor)
	local Button
	BaseMessage.RichText = true
	if nice then
		Button = util:AddNameButtonToBaseMessage(BaseMessage, Color3.fromRGB(255, 0, 0), "[Server]:", "Server")
	end
	
	local function GetHeightFunction(xSize)
		return util:GetMessageHeight(BaseMessage, BaseFrame, xSize, true)
	end

	local FadeParmaters = {}
	FadeParmaters[BaseMessage] = {
		TextTransparency = {FadedIn = 0, FadedOut = 1},
		TextStrokeTransparency = {FadedIn = 0, FadedOut = 1}
	}
	if Button then
		FadeParmaters[Button] = {
			TextTransparency = {FadedIn = 0, FadedOut = 1},
			TextStrokeTransparency = {FadedIn = 0, FadedOut = 1}
		}
	end
	
	local FadeInFunction, FadeOutFunction, UpdateAnimFunction = util:CreateFadeFunctions(FadeParmaters)

	return {
		[util.KEY_BASE_FRAME] = BaseFrame,
		[util.KEY_BASE_MESSAGE] = BaseMessage,
		[util.KEY_UPDATE_TEXT_FUNC] = nil,
		[util.KEY_GET_HEIGHT] = GetHeightFunction,
		[util.KEY_FADE_IN] = FadeInFunction,
		[util.KEY_FADE_OUT] = FadeOutFunction,
		[util.KEY_UPDATE_ANIMATION] = UpdateAnimFunction
	}
end

return {
	[util.KEY_MESSAGE_TYPE] = ChatConstants.MessageTypeSetCore,
	[util.KEY_CREATOR_FUNCTION] = CreateSetCoreMessageLabel
}
