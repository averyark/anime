--	// FileName: ChatServiceRunner.lua
--	// Written by: Xsitsu
--	// Description: Main script to initialize ChatService and run ChatModules.

local EventFolderName = "DefaultChatSystemChatEvents"
local EventFolderParent = game:GetService("ReplicatedStorage")
local modulesFolder = script

local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")

local ChatService = require(modulesFolder:WaitForChild("ChatService"))

local ReplicatedModules = Chat:WaitForChild("ClientChatModules")
local ChatSettings = require(ReplicatedModules:WaitForChild("ChatSettings"))

local ChatLocalization = nil
pcall(function()
	ChatLocalization = require(Chat.ClientChatModules.ChatLocalization :: any)
end)
ChatLocalization = ChatLocalization or {}

local MAX_CHANNEL_NAME_LENGTH = ChatSettings.MaxChannelNameCheckLength or 50
local MAX_MESSAGE_LENGTH = ChatSettings.MaximumMessageLength
local MAX_BYTES_PER_CODEPOINT = 6

if not ChatLocalization.FormatMessageToSend or not ChatLocalization.LocalizeFormattedMessage then
	function ChatLocalization:FormatMessageToSend(key, default)
		return default
	end
end

local MAX_BLOCKED_SPEAKERS_PER_REQ = 50

local useEvents = {}

local EventFolder = EventFolderParent:FindFirstChild(EventFolderName)
if not EventFolder then
	EventFolder = Instance.new("Folder")
	EventFolder.Name = EventFolderName
	EventFolder.Archivable = false
	EventFolder.Parent = EventFolderParent
end

local function validateMessageLength(msg)
	if msg:len() > MAX_MESSAGE_LENGTH * MAX_BYTES_PER_CODEPOINT then
		return false
	end

	if utf8.len(msg) == nil then
		return false
	end

	if utf8.len(utf8.nfcnormalize(msg)) > MAX_MESSAGE_LENGTH then
		return false
	end

	return true
end

local function validateChannelNameLength(channelName)
	if channelName:len() > MAX_CHANNEL_NAME_LENGTH * MAX_BYTES_PER_CODEPOINT then
		return false
	end

	if utf8.len(channelName) == nil then
		return false
	end

	if utf8.len(utf8.nfcnormalize(channelName)) > MAX_CHANNEL_NAME_LENGTH then
		return false
	end

	return true
end

--// No-opt connect Server>Client RemoteEvents to ensure they cannot be called
--// to fill the remote event queue.
local function emptyFunction()
	--intentially empty
end

local function GetObjectWithNameAndType(parentObject, objectName, objectType)
	for _, child in pairs(parentObject:GetChildren()) do
		if child:IsA(objectType) and child.Name == objectName then
			return child
		end
	end

	return nil
end

local function CreateIfDoesntExist(parentObject, objectName, objectType)
	local obj = GetObjectWithNameAndType(parentObject, objectName, objectType)
	if not obj then
		obj = Instance.new(objectType)
		obj.Name = objectName
		obj.Parent = parentObject
	end
	useEvents[objectName] = obj

	return obj
end

--// All remote events will have a no-opt OnServerEvent connecdted on construction
local function CreateEventIfItDoesntExist(parentObject, objectName)
	local obj = CreateIfDoesntExist(parentObject, objectName, "RemoteEvent")
	obj.OnServerEvent:Connect(emptyFunction)
	return obj
end

CreateEventIfItDoesntExist(EventFolder, "OnNewMessage")
CreateEventIfItDoesntExist(EventFolder, "OnMessageDoneFiltering")
CreateEventIfItDoesntExist(EventFolder, "OnNewSystemMessage")
CreateEventIfItDoesntExist(EventFolder, "OnChannelJoined")
CreateEventIfItDoesntExist(EventFolder, "OnChannelLeft")
CreateEventIfItDoesntExist(EventFolder, "OnMuted")
CreateEventIfItDoesntExist(EventFolder, "OnUnmuted")
CreateEventIfItDoesntExist(EventFolder, "OnMainChannelSet")
CreateEventIfItDoesntExist(EventFolder, "ChannelNameColorUpdated")

CreateEventIfItDoesntExist(EventFolder, "SayMessageRequest")
CreateEventIfItDoesntExist(EventFolder, "SetBlockedUserIdsRequest")
CreateIfDoesntExist(EventFolder, "GetInitDataRequest", "RemoteFunction")
CreateIfDoesntExist(EventFolder, "MutePlayerRequest", "RemoteFunction")
CreateIfDoesntExist(EventFolder, "UnMutePlayerRequest", "RemoteFunction")

EventFolder = useEvents

local function CreatePlayerSpeakerObject(playerObj)
	--// If a developer already created a speaker object with the
	--// name of a player and then a player joins and tries to
	--// take that name, we first need to remove the old speaker object
	local speaker = ChatService:GetSpeaker(playerObj.Name)
	if speaker then
		ChatService:RemoveSpeaker(playerObj.Name)
	end

	speaker = ChatService:InternalAddSpeakerWithPlayerObject(playerObj.Name, playerObj, false)

	for _, channel in pairs(ChatService:GetAutoJoinChannelList()) do
		speaker:JoinChannel(channel.Name)
	end

	speaker:InternalAssignEventFolder(EventFolder)

	speaker.ChannelJoined:connect(function(channel, welcomeMessage)
		local log = nil
		local channelNameColor = nil

		local channelObject = ChatService:GetChannel(channel)
		if channelObject then
			log = channelObject:GetHistoryLogForSpeaker(speaker)
			channelNameColor = channelObject.ChannelNameColor
		end
		EventFolder.OnChannelJoined:FireClient(playerObj, channel, welcomeMessage, log, channelNameColor)
	end)

	speaker.Muted:connect(function(channel, reason, length)
		EventFolder.OnMuted:FireClient(playerObj, channel, reason, length)
	end)

	speaker.Unmuted:connect(function(channel)
		EventFolder.OnUnmuted:FireClient(playerObj, channel)
	end)

	ChatService:InternalFireSpeakerAdded(speaker.Name)
end

EventFolder.SayMessageRequest.OnServerEvent:connect(function(playerObj, message, channel)
	if type(message) ~= "string" then
		return
	elseif not validateMessageLength(message) then
		return
	end

	if type(channel) ~= "string" then
		return
	elseif not validateChannelNameLength(channel) then
		return
	end

	local speaker = ChatService:GetSpeaker(playerObj.Name)
	if speaker then
		return speaker:SayMessage(message, channel)
	end

	return nil
end)

EventFolder.MutePlayerRequest.OnServerInvoke = function(playerObj, muteSpeakerName)
	if type(muteSpeakerName) ~= "string" then
		return
	end

	local speaker = ChatService:GetSpeaker(playerObj.Name)
	if speaker then
		local muteSpeaker = ChatService:GetSpeaker(muteSpeakerName)
		if muteSpeaker then
			speaker:AddMutedSpeaker(muteSpeaker.Name)
			return true
		end
	end
	return false
end

EventFolder.UnMutePlayerRequest.OnServerInvoke = function(playerObj, unmuteSpeakerName)
	if type(unmuteSpeakerName) ~= "string" then
		return
	end

	local speaker = ChatService:GetSpeaker(playerObj.Name)
	if speaker then
		local unmuteSpeaker = ChatService:GetSpeaker(unmuteSpeakerName)
		if unmuteSpeaker then
			speaker:RemoveMutedSpeaker(unmuteSpeaker.Name)
			return true
		end
	end
	return false
end

-- Map storing Player -> Blocked user Ids.
local BlockedUserIdsMap = {}

PlayersService.PlayerAdded:connect(function(newPlayer)
	for player, blockedUsers in pairs(BlockedUserIdsMap) do
		local speaker = ChatService:GetSpeaker(player.Name)
		if speaker then
			for i = 1, #blockedUsers do
				local blockedUserId = blockedUsers[i]
				if blockedUserId == newPlayer.UserId then
					speaker:AddMutedSpeaker(newPlayer.Name)
				end
			end
		end
	end
end)

PlayersService.PlayerRemoving:connect(function(removingPlayer)
	BlockedUserIdsMap[removingPlayer] = nil
end)

EventFolder.SetBlockedUserIdsRequest.OnServerEvent:Connect(function(player, blockedUserIdsList)
	if type(blockedUserIdsList) ~= "table" then
		return
	end

	local prunedBlockedUserIdsList = {}
	local speaker = ChatService:GetSpeaker(player.Name)
	if speaker then
		for i = 1, math.min(#blockedUserIdsList, MAX_BLOCKED_SPEAKERS_PER_REQ) do
			if type(blockedUserIdsList[i]) == "number" then
				table.insert(prunedBlockedUserIdsList, blockedUserIdsList[i])

				local blockedPlayer = PlayersService:GetPlayerByUserId(blockedUserIdsList[i])
				if blockedPlayer then
					speaker:AddMutedSpeaker(blockedPlayer.Name)
				end
			end
		end

		-- We only want to store the first
		-- MAX_BLOCKED_SPEAKERS_PER_REQ number of ids as needed
		BlockedUserIdsMap[player] = prunedBlockedUserIdsList
	end
end)

EventFolder.GetInitDataRequest.OnServerInvoke = function(playerObj)
	local speaker = ChatService:GetSpeaker(playerObj.Name)
	if not (speaker and speaker:GetPlayer()) then
		CreatePlayerSpeakerObject(playerObj)
		speaker = ChatService:GetSpeaker(playerObj.Name)
	end

	local data = {}
	data.Channels = {}
	data.SpeakerExtraData = {}

	for _, channelName in pairs(speaker:GetChannelList()) do
		local channelObj = ChatService:GetChannel(channelName)
		if channelObj then
			local channelData = {
				channelName,
				channelObj:GetWelcomeMessageForSpeaker(speaker),
				channelObj:GetHistoryLogForSpeaker(speaker),
				channelObj.ChannelNameColor,
			}

			table.insert(data.Channels, channelData)
		end
	end

	for _, oSpeakerName in pairs(ChatService:GetSpeakerList()) do
		local oSpeaker = ChatService:GetSpeaker(oSpeakerName)
		data.SpeakerExtraData[oSpeakerName] = oSpeaker.ExtraData
	end

	return data
end

local function DoJoinCommand(speakerName, channelName, fromChannelName)
	local speaker = ChatService:GetSpeaker(speakerName)
	local channel = ChatService:GetChannel(channelName)

	if speaker then
		if channel then
			if channel.Joinable then
				if not speaker:IsInChannel(channel.Name) then
					speaker:JoinChannel(channel.Name)
				else
					speaker:SetMainChannel(channel.Name)
					local msg = ChatLocalization:FormatMessageToSend(
						"GameChat_SwitchChannel_NowInChannel",
						string.format("You are now chatting in channel: '%s'", channel.Name),
						"RBX_NAME",
						channel.Name
					)
					speaker:SendSystemMessage(msg, channel.Name)
				end
			else
				local msg = ChatLocalization:FormatMessageToSend(
					"GameChat_ChatServiceRunner_YouCannotJoinChannel",
					"You cannot join channel '" .. channelName .. "'.",
					"RBX_NAME",
					channelName
				)
				speaker:SendSystemMessage(msg, fromChannelName)
			end
		else
			local msg = ChatLocalization:FormatMessageToSend(
				"GameChat_ChatServiceRunner_ChannelDoesNotExist",
				"Channel '" .. channelName .. "' does not exist.",
				"RBX_NAME",
				channelName
			)
			speaker:SendSystemMessage(msg, fromChannelName)
		end
	end
end

local function DoLeaveCommand(speakerName, channelName, fromChannelName)
	local speaker = ChatService:GetSpeaker(speakerName)
	local channel = ChatService:GetChannel(channelName)

	if speaker then
		if speaker:IsInChannel(channelName) then
			if channel.Leavable then
				speaker:LeaveChannel(channel.Name)
				local msg = ChatLocalization:FormatMessageToSend(
					"GameChat_ChatService_YouHaveLeftChannel",
					string.format("You have left channel '%s'", channelName),
					"RBX_NAME",
					channel.Name
				)
				speaker:SendSystemMessage(msg, "System")
			else
				local msg = ChatLocalization:FormatMessageToSend(
					"GameChat_ChatServiceRunner_YouCannotLeaveChannel",
					("You cannot leave channel '" .. channelName .. "'."),
					"RBX_NAME",
					channelName
				)
				speaker:SendSystemMessage(msg, fromChannelName)
			end
		else
			local msg = ChatLocalization:FormatMessageToSend(
				"GameChat_ChatServiceRunner_YouAreNotInChannel",
				("You are not in channel '" .. channelName .. "'."),
				"RBX_NAME",
				channelName
			)
			speaker:SendSystemMessage(msg, fromChannelName)
		end
	end
end

ChatService:RegisterProcessCommandsFunction("default_commands", function(fromSpeaker, message, channel)
	if string.sub(message, 1, 6):lower() == "/join " then
		DoJoinCommand(fromSpeaker, string.sub(message, 7), channel)
		return true
	elseif string.sub(message, 1, 3):lower() == "/j " then
		DoJoinCommand(fromSpeaker, string.sub(message, 4), channel)
		return true
	elseif string.sub(message, 1, 7):lower() == "/leave " then
		DoLeaveCommand(fromSpeaker, string.sub(message, 8), channel)
		return true
	elseif string.sub(message, 1, 3):lower() == "/l " then
		DoLeaveCommand(fromSpeaker, string.sub(message, 4), channel)
		return true
	end

	return false
end)

if ChatSettings.GeneralChannelName and ChatSettings.GeneralChannelName ~= "" then
	local allChannel = ChatService:AddChannel(ChatSettings.GeneralChannelName)

	allChannel.Leavable = false
	allChannel.AutoJoin = true

	allChannel:RegisterGetWelcomeMessageFunction(function(speaker)
		if RunService:IsStudio() then
			return nil
		end
		local player = speaker:GetPlayer()
		if player then
			local success, canChat = pcall(function()
				return Chat:CanUserChatAsync(player.UserId)
			end)
			if success and not canChat then
				return ""
			end
		end
	end)
end

local systemChannel = ChatService:AddChannel("System")
systemChannel.Leavable = false
systemChannel.AutoJoin = true
systemChannel.WelcomeMessage = ChatLocalization:FormatMessageToSend(
	"GameChat_ChatServiceRunner_SystemChannelWelcomeMessage",
	"This channel is for system and game notifications."
)

systemChannel.SpeakerJoined:connect(function(speakerName)
	systemChannel:MuteSpeaker(speakerName)
end)

local function TryRunModule(module)
	if module:IsA("ModuleScript") then
		local ret = require(module)
		if type(ret) == "function" then
			ret(ChatService)
		end
	end
end

local modules = Chat:WaitForChild("ChatModules")
modules.ChildAdded:connect(function(child)
	local success, returnval = pcall(TryRunModule, child)
	if not success and returnval then
		print("Error running module " .. child.Name .. ": " .. returnval)
	end
end)

for _, module in pairs(modules:GetChildren()) do
	local success, returnval = pcall(TryRunModule, module)
	if not success and returnval then
		print("Error running module " .. module.Name .. ": " .. returnval)
	end
end

PlayersService.PlayerRemoving:connect(function(playerObj)
	if ChatService:GetSpeaker(playerObj.Name) then
		ChatService:RemoveSpeaker(playerObj.Name)
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local util = require(ReplicatedStorage.src.util)
util.ChatService = ChatService
