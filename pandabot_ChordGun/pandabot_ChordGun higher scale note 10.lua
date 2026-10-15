-- @noindex

chords = {
  {
    name = 'major',
    code = 'major',
    display = '',
    pattern = '10001001'
  },
  {
    name = 'minor',
    code = 'minor',
    display = 'm',
    pattern = '10010001'
  },
  {
    name = 'power chord',
    code = 'power',
    display = '5',
    pattern = '10000001'
  },
  {
    name = 'suspended second',
    code = 'sus2',
    display = 'sus2',
    pattern = '10100001'
  },
  {
    name = 'suspended fourth',
    code = 'sus4',
    display = 'sus4',
    pattern = '10000101'
  },
  {
    name = 'diminished',
    code = 'dim',
    display = 'dim',
    pattern = '1001001'
  },  
  {
    name = 'augmented',
    code = 'aug',
    display = 'aug',
    pattern = '100010001'
  },
  {
    name = 'major sixth',
    code = 'maj6',
    display = '6',
    pattern = '1000100101'
  },
  {
    name = 'minor sixth',
    code = 'min6',
    display = 'm6',
    pattern = '1001000101'
  },
  {
    name = 'dominant seventh',
    code = '7',
    display = '7',
    pattern = '10001001001'
  },
  {
    name = 'major seventh',
    code = 'maj7',
    display = 'maj7',
    pattern = '100010010001'
  },
  {
    name = 'minor seventh',
    code = 'min7',
    display = 'm7',
    pattern = '10010001001'
  },
  {
    name = 'flat fifth',
    code = 'flat5',
    display = '5-',
    pattern = '10000010'
  },
}

function mouseIsHoveringOver(element)

	local x = gfx.mouse_x
	local y = gfx.mouse_y

	local isInHorizontalRegion = (x >= element.x and x < element.x+element.width)
	local isInVerticalRegion = (y >= element.y and y < element.y+element.height)
	return isInHorizontalRegion and isInVerticalRegion
end

function setPositionAtMouseCursor()

  gfx.x = gfx.mouse_x
  gfx.y = gfx.mouse_y
end

function leftMouseButtonIsHeldDown()
  return gfx.mouse_cap & 1 == 1
end

function leftMouseButtonIsNotHeldDown()
  return gfx.mouse_cap & 1 ~= 1
end

function rightMouseButtonIsHeldDown()
  return gfx.mouse_cap & 2 == 2
end

function clearConsoleWindow()
  reaper.ShowConsoleMsg("")
end

function print(arg)
  reaper.ShowConsoleMsg(tostring(arg) .. "\n")
end

function getScreenWidth()
	local _, _, screenWidth, _ = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)
	return screenWidth
end

function getScreenHeight()
	local _, _, _, screenHeight = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)
	return screenHeight
end

function windowIsDocked()
	return gfx.dock(-1) > 0
end

function windowIsNotDocked()
	return not windowIsDocked()
end

function notesAreSelected()

	local activeMidiEditor = reaper.MIDIEditor_GetActive()
	local activeTake = reaper.MIDIEditor_GetTake(activeMidiEditor)

	local noteIndex = 0
	local noteExists = true
	local noteIsSelected = false

	while noteExists do

		noteExists, noteIsSelected = reaper.MIDI_GetNote(activeTake, noteIndex)

		if noteIsSelected then
			return true
		end
	
		noteIndex = noteIndex + 1
	end

	return false
end

function startUndoBlock()
	reaper.Undo_BeginBlock()
end

function endUndoBlock(actionDescription)
	reaper.Undo_OnStateChange(actionDescription)
	reaper.Undo_EndBlock(actionDescription, -1)
end

function emptyFunctionToPreventAutomaticCreationOfUndoPoint()
end


local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

-- Exact tonic-option index, not pitch class.  1 = C.
defaultScaleTonicOptionValue = 1
defaultScaleTonicNoteValue = 1 -- legacy migration fallback
defaultScaleTypeValue = 1
defaultScaleNotesTextValue = ""
defaultChordTextValue = ""
defaultSelectedScaleNote = 1
defaultOctave = 3
defaultVoiceLeadingMode = 1
defaultVoicingMode = 1

numberOfChromaticDegrees = 12

defaultSelectedChordTypes = {}
for i = 1, numberOfChromaticDegrees do
  defaultSelectedChordTypes[i] = 1
end

defaultInversionStates = {}
for i = 1, numberOfChromaticDegrees do
  defaultInversionStates[i] = 0
end

defaultScaleNoteNames = {'C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'}
defaultScaleDegreeHeaders = {'1', 'b2', '2', 'b3', '3', '4', '#4/b5', '5', 'b6', '6', 'b7', '7'}

defaultNotesThatArePlaying = {}
defaultDockState = 0x0201
defaultWindowShouldBeDocked = tostring(false)

-- Compact enough for docking, while still fitting twelve columns comfortably.
interfaceWidth = 820
interfaceHeight = 500

function defaultInterfaceXPosition()
  local screenWidth = getScreenWidth()
  return screenWidth/2 - interfaceWidth/2
end

function defaultInterfaceYPosition()
  local screenHeight = getScreenHeight()
  return screenHeight/2 - interfaceHeight/2
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local activeProjectIndex = 0
local sectionName = "com.pandabot.ChordGun"

local scaleTonicNoteKey = "scaleTonicNote" -- legacy pitch-class key
local scaleTonicOptionKey = "scaleTonicOption"
local scaleTypeKey = "scaleType"
local scaleNotesTextKey = "scaleNotesText"
local chordTextKey = "chordText"
local chordInversionStatesKey = "chordInversionStates"
local selectedScaleNoteKey = "selectedScaleNote"
local octaveKey = "octave"
local selectedChordTypesKey = "selectedChordTypes"
local scaleNoteNamesKey = "scaleNoteNames"
local scaleDegreeHeadersKey = "scaleDegreeHeaders"
local notesThatArePlayingKey = "notesThatArePlaying"
local dockStateKey = "dockState"
local windowShouldBeDockedKey = "shouldBeDocked"
local interfaceXPositionKey = "interfaceXPosition"
local interfaceYPositionKey = "interfaceYPosition"
local voiceLeadingModeKey = "voiceLeadingMode"
local voicingModeKey = "voicingMode"

--

local function setValue(key, value)
  reaper.SetProjExtState(activeProjectIndex, sectionName, key, value)
end

local function getValue(key, defaultValue)

  local valueExists, value = reaper.GetProjExtState(activeProjectIndex, sectionName, key)

  if valueExists == 0 then
    setValue(key, defaultValue)
    return defaultValue
  end

  return value
end

--

local function getTableFromString(arg)

  local output = {}

  for match in arg:gmatch("([^,%s]+)") do
    output[#output + 1] = match
  end

  return output
end

local function setTableValue(key, value)
  reaper.SetProjExtState(activeProjectIndex, sectionName, key, table.concat(value, ","))
end

local function getTableValue(key, defaultValue)

  local valueExists, value = reaper.GetProjExtState(activeProjectIndex, sectionName, key)

  if valueExists == 0 then
    setTableValue(key, defaultValue)
    return defaultValue
  end

  local result = getTableFromString(value)
  local changed = false

  -- Older ChordGun projects store seven scale-degree entries.  Pad those
  -- tables to the new twelve-degree chromatic layout without discarding the
  -- existing first seven values.
  for i = 1, #defaultValue do
    if result[i] == nil then
      result[i] = defaultValue[i]
      changed = true
    end
  end

  while #result > #defaultValue and #defaultValue > 0 do
    table.remove(result)
    changed = true
  end

  if changed then
    setTableValue(key, result)
  end

  return result
end

--[[ ]]--

local legacyPitchClassToTonicOption = {
  1,  -- C
  2,  -- C#
  4,  -- D
  5,  -- D#
  7,  -- E
  8,  -- F
  9,  -- F#
  11, -- G
  12, -- G#
  14, -- A
  15, -- A#
  17  -- B
}

function getScaleTonicOption()
  local valueExists, value = reaper.GetProjExtState(activeProjectIndex, sectionName, scaleTonicOptionKey)

  if valueExists == 0 then
    local legacyExists, legacyValue = reaper.GetProjExtState(activeProjectIndex, sectionName, scaleTonicNoteKey)
    local legacyPitchClass = legacyExists ~= 0 and tonumber(legacyValue) or defaultScaleTonicNoteValue
    local option = legacyPitchClassToTonicOption[legacyPitchClass] or defaultScaleTonicOptionValue
    setValue(scaleTonicOptionKey, option)
    return option
  end

  local option = tonumber(value) or defaultScaleTonicOptionValue
  if option < 1 or option > 17 then
    option = defaultScaleTonicOptionValue
    setValue(scaleTonicOptionKey, option)
  end
  return option
end

function setScaleTonicOption(arg)
  local option = tonumber(arg) or defaultScaleTonicOptionValue
  option = math.max(1, math.min(17, option))
  setValue(scaleTonicOptionKey, option)
end

-- Legacy compatibility.  New code should select exact spellings with
-- setScaleTonicOption().
function setScaleTonicNote(arg)
  local pitchClass = tonumber(arg) or defaultScaleTonicNoteValue
  setScaleTonicOption(legacyPitchClassToTonicOption[pitchClass] or defaultScaleTonicOptionValue)
end

--

function getScaleType()
  local scaleType = tonumber(getValue(scaleTypeKey, defaultScaleTypeValue)) or 1
  if scaleType ~= 1 then
    scaleType = 1
    setValue(scaleTypeKey, scaleType)
  end
  return scaleType
end

function setScaleType(arg)
  setValue(scaleTypeKey, 1)
end

--

function getScaleNotesText()
  return getValue(scaleNotesTextKey, defaultScaleNotesTextValue)
end

function setScaleNotesText(arg)
  setValue(scaleNotesTextKey, arg)
end

--

function getChordText()
  return getValue(chordTextKey, defaultChordTextValue)
end

function setChordText(arg)
  setValue(chordTextKey, arg)
end

--

function getChordInversionMin()
  return -8
end

--

function getChordInversionMax()
  return 8
end

--

function getSelectedScaleNote()
  return tonumber(getValue(selectedScaleNoteKey, defaultSelectedScaleNote))
end

function setSelectedScaleNote(arg)
  setValue(selectedScaleNoteKey, arg)
end

--

function getOctave()
  return tonumber(getValue(octaveKey, defaultOctave))
end

function setOctave(arg)
  setValue(octaveKey, arg)
end

--

function getVoiceLeadingMode()
  local mode = tonumber(getValue(voiceLeadingModeKey, defaultVoiceLeadingMode))

  if mode == nil or mode < 1 or mode > 3 then
    mode = defaultVoiceLeadingMode
    setValue(voiceLeadingModeKey, mode)
  end

  return mode
end

function setVoiceLeadingMode(arg)
  local mode = tonumber(arg) or defaultVoiceLeadingMode
  mode = math.max(1, math.min(3, mode))
  setValue(voiceLeadingModeKey, mode)
end

function getVoiceLeadingModeOptions()
  return {"Off", "Closest tones", "Closest inversion"}
end

function cycleVoiceLeadingMode()
  local mode = getVoiceLeadingMode() + 1

  if mode > 3 then
    mode = 1
  end

  setVoiceLeadingMode(mode)
  return mode
end

--

function getVoicingMode()
  local mode = tonumber(getValue(voicingModeKey, defaultVoicingMode))

  if mode == nil or mode < 1 or mode > 3 then
    mode = defaultVoicingMode
    setValue(voicingModeKey, mode)
  end

  return mode
end

function setVoicingMode(arg)
  local mode = tonumber(arg) or defaultVoicingMode
  mode = math.max(1, math.min(3, mode))
  setValue(voicingModeKey, mode)
end

function getVoicingModeOptions()
  return {"Close", "Drop-2", "Wide + low root"}
end

function cycleVoicingMode()
  local mode = getVoicingMode() + 1

  if mode > 3 then
    mode = 1
  end

  setVoicingMode(mode)
  return mode
end

--

function getOctaveMin()
  return -1
end

--

function getOctaveMax()
  return 8
end

--

function getSelectedChordTypes()

  return getTableValue(selectedChordTypesKey, defaultSelectedChordTypes)
end

function getSelectedChordType(index)

  local temp = getTableValue(selectedChordTypesKey, defaultSelectedChordTypes)
  return tonumber(temp[index])
end

function setSelectedChordType(index, arg)

  local temp = getSelectedChordTypes()
  temp[index] = arg
  setTableValue(selectedChordTypesKey, temp)
end

--

function getScaleNoteNames()
  return getTableValue(scaleNoteNamesKey, defaultScaleNoteNames)
end

function getScaleNoteName(index)
  local temp = getTableValue(scaleNoteNamesKey, defaultScaleNoteNames)
  return temp[index]
end

function setScaleNoteName(index, arg)

  local temp = getScaleNoteNames()
  temp[index] = arg
  setTableValue(scaleNoteNamesKey, temp)
end

--

function getScaleDegreeHeaders()
  return getTableValue(scaleDegreeHeadersKey, defaultScaleDegreeHeaders)
end

function getScaleDegreeHeader(index)
  local temp = getTableValue(scaleDegreeHeadersKey, defaultScaleDegreeHeaders)
  return temp[index]
end

function setScaleDegreeHeader(index, arg)

  local temp = getScaleDegreeHeaders()
  temp[index] = arg
  setTableValue(scaleDegreeHeadersKey, temp)
end

--

function getChordInversionStates()
  return getTableValue(chordInversionStatesKey, defaultInversionStates)
end

function getChordInversionState(index)

  local temp = getTableValue(chordInversionStatesKey, defaultInversionStates)
  return tonumber(temp[index])
end

function setChordInversionState(index, arg)

  local temp = getChordInversionStates()
  temp[index] = arg
  setTableValue(chordInversionStatesKey, temp)
end

--

function resetSelectedChordTypes()
  for i = 1, numberOfChromaticDegrees do
    setSelectedChordType(i, 1)
  end
end

function resetChordInversionStates()
  for i = 1, numberOfChromaticDegrees do
    setChordInversionState(i, 0)
  end
end

--

function getNotesThatArePlaying()
  return getTableValue(notesThatArePlayingKey, defaultNotesThatArePlaying)
end

function setNotesThatArePlaying(arg)
  setTableValue(notesThatArePlayingKey, arg)
end

--

function getDockState()
  return getValue(dockStateKey, defaultDockState)
end

function setDockState(arg)
  setValue(dockStateKey, arg)
end

function windowShouldBeDocked()
  return getValue(windowShouldBeDockedKey, defaultWindowShouldBeDocked) == tostring(true)
end

function setWindowShouldBeDocked(arg)
  setValue(windowShouldBeDockedKey, tostring(arg))
end

function getInterfaceXPosition()
  return getValue(interfaceXPositionKey, defaultInterfaceXPosition())
end

function setInterfaceXPosition(arg)
  setValue(interfaceXPositionKey, arg)
end

function getInterfaceYPosition()
  return getValue(interfaceYPositionKey, defaultInterfaceYPosition())
end

function setInterfaceYPosition(arg)
  setValue(interfaceYPositionKey, arg)
end

Timer = {}
Timer.__index = Timer

function Timer:new(numberOfSeconds)

  local self = {}
  setmetatable(self, Timer)

  self.startingTime = reaper.time_precise()
  self.numberOfSeconds = numberOfSeconds
  self.timerIsStopped = true

  return self
end

function Timer:start()

	self.timerIsStopped = false
	self.startingTime = reaper.time_precise()
end

function Timer:stop()

	self.timerIsStopped = true
end

function Timer:timeHasElapsed()

	local currentTime = reaper.time_precise()

	if self.timerIsStopped then
		return false
	end

	if currentTime - self.startingTime > self.numberOfSeconds then
		return true
	else
		return false
	end
end

function Timer:timeHasNotElapsed()
	return not self:timeHasElapsed()
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

mouseButtonIsNotPressedDown = true

currentWidth = 0
currentHeight = 0

scaleTonicOption = getScaleTonicOption()
scaleType = getScaleType()
voiceLeadingMode = getVoiceLeadingMode()
voicingMode = getVoicingMode()

guiShouldBeUpdated = false

-- ChordGun now exposes one chromatic palette.  The tonic selection controls
-- both the pitch-class origin and the enharmonic spelling used throughout the
-- interface.
scales = {
  { name = "Chromatic", pattern = "111111111111" }
}

tonicOptions = {
  { name = "C",  pitchClass = 1,  spelling = "mixed" },
  { name = "C#", pitchClass = 2,  spelling = "sharp" },
  { name = "Db", pitchClass = 2,  spelling = "flat" },
  { name = "D",  pitchClass = 3,  spelling = "sharp" },
  { name = "D#", pitchClass = 4,  spelling = "sharp" },
  { name = "Eb", pitchClass = 4,  spelling = "flat" },
  { name = "E",  pitchClass = 5,  spelling = "sharp" },
  { name = "F",  pitchClass = 6,  spelling = "flat" },
  { name = "F#", pitchClass = 7,  spelling = "sharp" },
  { name = "Gb", pitchClass = 7,  spelling = "flat" },
  { name = "G",  pitchClass = 8,  spelling = "sharp" },
  { name = "G#", pitchClass = 9,  spelling = "sharp" },
  { name = "Ab", pitchClass = 9,  spelling = "flat" },
  { name = "A",  pitchClass = 10, spelling = "sharp" },
  { name = "A#", pitchClass = 11, spelling = "sharp" },
  { name = "Bb", pitchClass = 11, spelling = "flat" },
  { name = "B",  pitchClass = 12, spelling = "sharp" }
}

chromaticDegreeHeaders = {
  "1", "b2", "2", "b3", "3", "4", "#4/b5", "5", "b6", "6", "b7", "7"
}
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

notes = { 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' }
flatNotes = { 'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B' }
mixedNotes = { 'C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B' }

function getTonicOptionNames()
  local result = {}
  for i, option in ipairs(tonicOptions) do
    result[i] = option.name
  end
  return result
end

function getNumberOfTonicOptions()
  return #tonicOptions
end

function getScaleTonicPitchClass()
  local option = tonicOptions[getScaleTonicOption()] or tonicOptions[1]
  return option.pitchClass
end

-- Kept for compatibility with the existing musical code.  It now returns the
-- selected tonic's pitch class, while getScaleTonicOption() identifies the
-- exact enharmonic spelling selected in the GUI.
function getScaleTonicNote()
  return getScaleTonicPitchClass()
end

function getScaleTonicName()
  local option = tonicOptions[getScaleTonicOption()] or tonicOptions[1]
  return option.name
end

function getScaleSpellingFamily()
  local option = tonicOptions[getScaleTonicOption()] or tonicOptions[1]
  return option.spelling
end

function getScalePattern(scaleTonicNote, scale)
  local scalePatternString = scale['pattern']
  local scalePattern = {false,false,false,false,false,false,false,false,false,false,false,false}

  for i = 0, #scalePatternString - 1 do
    local note = getNotesIndex(scaleTonicNote+i)
    if scalePatternString:sub(i+1, i+1) == '1' then
      scalePattern[note] = true
    end
  end
  return scalePattern
end

function getNotesIndex(note)
  return ((note - 1) % 12) + 1
end

function getNoteName(note)
  local notesIndex = getNotesIndex(note)
  local spelling = getScaleSpellingFamily()

  if spelling == "flat" then
    return flatNotes[notesIndex]
  elseif spelling == "mixed" then
    return mixedNotes[notesIndex]
  end

  return notes[notesIndex]
end

function getSharpNoteName(note)
  return notes[getNotesIndex(note)]
end

function getFlatNoteName(note)
  return flatNotes[getNotesIndex(note)]
end

function chordIsNotAlreadyIncluded(scaleChordsForRootNote, chordCode)
  for _, chord in ipairs(scaleChordsForRootNote) do
    if chord.code == chordCode then
      return false
    end
  end
  return true
end

function getNumberOfScaleChordsForScaleNoteIndex(scaleNoteIndex)
  return #chords
end

function getScaleChordsForRootNote(rootNote)
  local result = {}
  for i, chord in ipairs(chords) do
    result[i] = chord
  end
  return result
end

function noteIsInScale(note)
  return true
end

function noteIsNotInScale(note)
  return false
end

function chordIsInScale(rootNote, chordIndex)
  return true
end

function noteIsInModalMixtureScale(note)
  return true
end

function noteIsNotInModalMixtureScale(note)
  return false
end

function chordIsInModalMixtureScale(rootNote, chordIndex)
  return true
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

function updateScaleDegreeHeaders()
  for i = 1, #chromaticDegreeHeaders do
    setScaleDegreeHeader(i, chromaticDegreeHeaders[i])
  end
end

local tolerance = 0.000001

function activeMidiEditor()
  return reaper.MIDIEditor_GetActive()
end

function activeTake()
  return reaper.MIDIEditor_GetTake(activeMidiEditor())
end

function activeMediaItem()
  return reaper.GetMediaItemTake_Item(activeTake())
end

function activeTrack()
  return reaper.GetMediaItemTake_Track(activeTake())
end

function mediaItemStartPosition()
  return reaper.GetMediaItemInfo_Value(activeMediaItem(), "D_POSITION")
end

function mediaItemStartPositionPPQ()
  return reaper.MIDI_GetPPQPosFromProjTime(activeTake(), mediaItemStartPosition())
end

function mediaItemStartPositionQN()
  return reaper.MIDI_GetProjQNFromPPQPos(activeTake(), mediaItemStartPositionPPQ())
end

local function mediaItemLength()
  return reaper.GetMediaItemInfo_Value(activeMediaItem(), "D_LENGTH")
end

local function mediaItemEndPosition()
  return mediaItemStartPosition() + mediaItemLength()
end

local function cursorPosition()
  return reaper.GetCursorPosition()
end

local function loopStartPosition()

  local loopStartPosition, _ = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  return loopStartPosition
end

local function loopEndPosition()

  local _, loopEndPosition = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  return loopEndPosition
end

local function noteLengthOld()

  local noteLengthQN = getNoteLengthQN()
  local noteLengthPPQ = reaper.MIDI_GetPPQPosFromProjQN(activeTake(), noteLengthQN)
  return reaper.MIDI_GetProjTimeFromPPQPos(activeTake(), noteLengthPPQ)
end

local function noteLength()

  return gridUnitLength()
end


function notCurrentlyRecording()
  
  local activeProjectIndex = 0
  return reaper.GetPlayStateEx(activeProjectIndex) & 4 ~= 4
end

function setEditCursorPosition(arg)

  local activeProjectIndex = 0
  local moveView = false
  local seekPlay = false
  reaper.SetEditCurPos2(activeProjectIndex, arg, moveView, seekPlay)
end

local function moveEditCursorPosition(arg)

  local moveTimeSelection = false
  reaper.MoveEditCursor(arg, moveTimeSelection)
end

local function repeatIsNotOn()
  return reaper.GetSetRepeat(-1) == 0
end

local function loopIsActive()

  if repeatIsNotOn() then
    return false
  end

  if loopStartPosition() < mediaItemStartPosition() and loopEndPosition() < mediaItemStartPosition() then
    return false
  end

  if loopStartPosition() > mediaItemEndPosition() and loopEndPosition() > mediaItemEndPosition() then
    return false
  end

  if loopStartPosition() == loopEndPosition() then
    return false
  else
    return true
  end
end

function moveCursor(keepNotesSelected, selectedChord)

  if keepNotesSelected then

    local noteEndPositionInProjTime = reaper.MIDI_GetProjTimeFromPPQPos(activeTake(), selectedChord.longestEndPosition)
    local noteLengthOfSelectedNote = noteEndPositionInProjTime-cursorPosition()

    if loopIsActive() and loopEndPosition() < mediaItemEndPosition() then

      if cursorPosition() + noteLengthOfSelectedNote >= loopEndPosition() - tolerance then

        if loopStartPosition() > mediaItemStartPosition() then
          setEditCursorPosition(loopStartPosition())
        else
          setEditCursorPosition(mediaItemStartPosition())
        end

      else
        
        moveEditCursorPosition(noteLengthOfSelectedNote)  
      end

    elseif loopIsActive() and mediaItemEndPosition() <= loopEndPosition() then 

      if cursorPosition() + noteLengthOfSelectedNote >= mediaItemEndPosition() - tolerance then

        if loopStartPosition() > mediaItemStartPosition() then
          setEditCursorPosition(loopStartPosition())
        else
          setEditCursorPosition(mediaItemStartPosition())
        end

      else
      
        moveEditCursorPosition(noteLengthOfSelectedNote)
      end

    elseif cursorPosition() + noteLengthOfSelectedNote >= mediaItemEndPosition() - tolerance then
      setEditCursorPosition(mediaItemStartPosition())
    else

      moveEditCursorPosition(noteLengthOfSelectedNote)
    end

  else

    if loopIsActive() and loopEndPosition() < mediaItemEndPosition() then

      if cursorPosition() + noteLength() >= loopEndPosition() - tolerance then

        if loopStartPosition() > mediaItemStartPosition() then
          setEditCursorPosition(loopStartPosition())
        else
          setEditCursorPosition(mediaItemStartPosition())
        end

      else
        moveEditCursorPosition(noteLength())
      end

    elseif loopIsActive() and mediaItemEndPosition() <= loopEndPosition() then 

      if cursorPosition() + noteLength() >= mediaItemEndPosition() - tolerance then

        if loopStartPosition() > mediaItemStartPosition() then
          setEditCursorPosition(loopStartPosition())
        else
          setEditCursorPosition(mediaItemStartPosition())
        end

      else
        moveEditCursorPosition(noteLength())
      end

    elseif cursorPosition() + noteLength() >= mediaItemEndPosition() - tolerance then
        setEditCursorPosition(mediaItemStartPosition())
    else

      moveEditCursorPosition(noteLength())
    end

  end

end

--

function getCursorPositionPPQ()
  return reaper.MIDI_GetPPQPosFromProjTime(activeTake(), cursorPosition())
end

local function getCursorPositionQN()
  return reaper.MIDI_GetProjQNFromPPQPos(activeTake(), getCursorPositionPPQ())
end

function getNoteLengthQN()

  local gridLength = reaper.MIDI_GetGrid(activeTake())
  return gridLength
end

function gridUnitLength()

  local gridLengthQN = reaper.MIDI_GetGrid(activeTake())
  local mediaItemPlusGridLengthPPQ = reaper.MIDI_GetPPQPosFromProjQN(activeTake(), mediaItemStartPositionQN() + gridLengthQN)
  local mediaItemPlusGridLength = reaper.MIDI_GetProjTimeFromPPQPos(activeTake(), mediaItemPlusGridLengthPPQ)
  return mediaItemPlusGridLength - mediaItemStartPosition()
end

function getMidiEndPositionPPQ()

  local startPosition = reaper.GetCursorPosition()
  local startPositionPPQ = reaper.MIDI_GetPPQPosFromProjTime(activeTake(), startPosition)
  local endPositionPPQ = reaper.MIDI_GetPPQPosFromProjTime(activeTake(), startPosition+gridUnitLength())
  return endPositionPPQ
end

function deselectAllNotes()

  local selectAllNotes = false
  reaper.MIDI_SelectAll(activeTake(), selectAllNotes)
end

function getCurrentNoteChannel(channelArg)

  if channelArg ~= nil then
    return channelArg
  end

  if activeMidiEditor() == nil then
    return 0
  end

  return reaper.MIDIEditor_GetSetting_int(activeMidiEditor(), "default_note_chan")
end

function getCurrentVelocity()

  if activeMidiEditor() == nil then
    return 96
  end

  return reaper.MIDIEditor_GetSetting_int(activeMidiEditor(), "default_note_vel")
end

function getNumberOfNotes()

  local _, numberOfNotes = reaper.MIDI_CountEvts(activeTake())
  return numberOfNotes
end

function deleteNote(noteIndex)

  reaper.MIDI_DeleteNote(activeTake(), noteIndex)
end

function thereAreNotesSelected()

  if activeTake() == nil then
    return false
  end

  local numberOfNotes = getNumberOfNotes()

  for noteIndex = 0, numberOfNotes-1 do

    local _, noteIsSelected = reaper.MIDI_GetNote(activeTake(), noteIndex)

    if noteIsSelected then
      return true
    end
  end

  return false
end

function halveGridSize()

  if activeTake() == nil then
    return
  end

  local gridSize = reaper.MIDI_GetGrid(activeTake())/4

  if gridSize <= 1/1024 then
    return
  end

  local activeProjectIndex = 0
  reaper.SetMIDIEditorGrid(activeProjectIndex, gridSize/2)
end

function doubleGridSize()

  if activeTake() == nil then
    return
  end

  local gridSize = reaper.MIDI_GetGrid(activeTake())/4

  if gridSize >= 1024 then
    return
  end

  local activeProjectIndex = 0
  reaper.SetMIDIEditorGrid(activeProjectIndex, gridSize*2)
end

--

function deleteExistingNotesInNextInsertionTimePeriod(keepNotesSelected, selectedChord)

  local insertionStartTime = cursorPosition()

  local insertionEndTime = nil
  
  if keepNotesSelected then
    insertionEndTime = reaper.MIDI_GetProjTimeFromPPQPos(activeTake(), selectedChord.longestEndPosition)
  else
    insertionEndTime = insertionStartTime + noteLength()
  end

  local numberOfNotes = getNumberOfNotes()

  for noteIndex = numberOfNotes-1, 0, -1 do

    local _, _, _, noteStartPositionPPQ = reaper.MIDI_GetNote(activeTake(), noteIndex)
    local noteStartTime = reaper.MIDI_GetProjTimeFromPPQPos(activeTake(), noteStartPositionPPQ)

    if noteStartTime + tolerance >= insertionStartTime and noteStartTime + tolerance <= insertionEndTime then
      deleteNote(noteIndex)
    end
  end
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

function playMidiNote(midiNote)

  local virtualKeyboardMode = 0
  local channel = getCurrentNoteChannel()
  local noteOnCommand = 0x90 + channel
  local velocity = getCurrentVelocity()

  reaper.StuffMIDIMessage(virtualKeyboardMode, noteOnCommand, midiNote, velocity)
end

function stopAllNotesFromPlaying()

  for midiNote = 0, 127 do

    local virtualKeyboardMode = 0
    local channel = getCurrentNoteChannel()
    local noteOffCommand = 0x80 + channel
    local velocity = 0

    reaper.StuffMIDIMessage(virtualKeyboardMode, noteOffCommand, midiNote, velocity)
  end
end

function stopNoteFromPlaying(midiNote)

  local virtualKeyboardMode = 0
  local channel = getCurrentNoteChannel()
  local noteOffCommand = 0x80 + channel
  local velocity = 0

  reaper.StuffMIDIMessage(virtualKeyboardMode, noteOffCommand, midiNote, velocity)
end

function stopNotesFromPlaying()

  local notesThatArePlaying = getNotesThatArePlaying()

  for noteIndex = 1, #notesThatArePlaying do
    stopNoteFromPlaying(notesThatArePlaying[noteIndex])
  end

  setNotesThatArePlaying({})
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

function applyInversion(chord)
  
  local chordLength = #chord

  local selectedScaleNote = getSelectedScaleNote()
  local chordInversionValue = getChordInversionState(selectedScaleNote)
  local chord_ = chord
  local oct = 0  
  
  if chordInversionValue < 0 then
    oct = math.floor(chordInversionValue / chordLength)
    chordInversionValue = chordInversionValue + (math.abs(oct) * chordLength)
  end
  
  for i = 1, chordInversionValue do
    local r = table.remove(chord_, 1)
    r = r + 12
    table.insert(chord_, #chord_ + 1, r )
  end
    
  for i = 1, #chord_ do
    chord_[i] = chord_[i] + (oct * 12)
  end

  return chord_
end

function getChordNotesArray(root, chord, octave)

  local chordLength = 0
  local chordNotesArray = {}
  local chordPattern = chord["pattern"]
  for n = 0, #chordPattern-1 do
    if chordPattern:sub(n+1, n+1) == '1' then
      chordLength = chordLength + 1
      
      local noteValue = root + n + ((octave+1) * 12) - 1
      table.insert(chordNotesArray, noteValue)
    end
  end
  
  if getVoiceLeadingMode() == 1 then
    chordNotesArray = applyInversion(chordNotesArray)
  end
  
  return chordNotesArray
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local MIDI_NOTE_MIN = 0
local MIDI_NOTE_MAX = 127
local ONSET_TOLERANCE_PPQ = 0.5
local REGISTER_RADIUS_SEMITONES = 24

local function copyNumberArray(values)
  local output = {}

  for i = 1, #values do
    local value = tonumber(values[i])
    if value ~= nil then
      output[#output + 1] = value
    end
  end

  return output
end

local function sortAndRemoveDuplicates(values)
  local sorted = copyNumberArray(values)
  table.sort(sorted)

  local output = {}
  local previousValue = nil

  for i = 1, #sorted do
    local value = sorted[i]

    if previousValue == nil or value ~= previousValue then
      output[#output + 1] = value
      previousValue = value
    end
  end

  return output
end

local function averagePitch(values)
  if #values == 0 then
    return 60
  end

  local total = 0

  for i = 1, #values do
    total = total + values[i]
  end

  return total / #values
end

local function pitchClass(note)
  return ((note % 12) + 12) % 12
end

local function getUniquePitchClasses(notes)
  local pitchClasses = {}
  local pitchClassExists = {}

  for i = 1, #notes do
    local pc = pitchClass(notes[i])

    if not pitchClassExists[pc] then
      pitchClassExists[pc] = true
      pitchClasses[#pitchClasses + 1] = pc
    end
  end

  table.sort(pitchClasses)
  return pitchClasses
end

local function getRegisterBounds(targetNotes)
  local centre = averagePitch(targetNotes)
  local low = math.max(MIDI_NOTE_MIN, math.floor(centre - REGISTER_RADIUS_SEMITONES))
  local high = math.min(MIDI_NOTE_MAX, math.ceil(centre + REGISTER_RADIUS_SEMITONES))

  return centre, low, high
end

local function nearestDistance(note, notes)
  local distance = math.huge

  for i = 1, #notes do
    distance = math.min(distance, math.abs(note - notes[i]))
  end

  return distance
end

local function getActiveTakeSafely()
  local editor = reaper.MIDIEditor_GetActive()

  if editor == nil then
    return nil
  end

  return reaper.MIDIEditor_GetTake(editor)
end

function getPreviousChordNotes(referencePositionPPQ)
  local take = getActiveTakeSafely()

  if take == nil then
    return {}
  end

  local _, numberOfNotes = reaper.MIDI_CountEvts(take)
  local latestStartPosition = nil
  local notes = {}

  for noteIndex = 0, numberOfNotes - 1 do
    local noteExists, _, muted, startPositionPPQ, _, _, pitch =
      reaper.MIDI_GetNote(take, noteIndex)

    if noteExists and not muted and
       startPositionPPQ < referencePositionPPQ - ONSET_TOLERANCE_PPQ then

      if latestStartPosition == nil or
         startPositionPPQ > latestStartPosition + ONSET_TOLERANCE_PPQ then

        latestStartPosition = startPositionPPQ
        notes = {pitch}

      elseif math.abs(startPositionPPQ - latestStartPosition) <= ONSET_TOLERANCE_PPQ then
        notes[#notes + 1] = pitch
      end
    end
  end

  return sortAndRemoveDuplicates(notes)
end

local function getLastPreviewedChordNotes()
  return sortAndRemoveDuplicates(getNotesThatArePlaying())
end

function getVoiceLeadingReferenceNotes()
  local take = getActiveTakeSafely()

  if take ~= nil then
    local cursorPosition = reaper.GetCursorPosition()
    local cursorPositionPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorPosition)
    local previousChord = getPreviousChordNotes(cursorPositionPPQ)

    if #previousChord > 0 then
      return previousChord
    end
  end

  return getLastPreviewedChordNotes()
end

local function closestTonesVoiceLeading(targetNotes, previousNotes)
  local targetPitchClasses = getUniquePitchClasses(targetNotes)

  if #targetPitchClasses == 0 or #previousNotes == 0 then
    return copyNumberArray(targetNotes)
  end

  local centre, low, high = getRegisterBounds(targetNotes)
  local output = {}

  for i = 1, #targetPitchClasses do
    local pc = targetPitchClasses[i]
    local candidate = pc

    while candidate < low do
      candidate = candidate + 12
    end

    local bestPitch = nil
    local bestScore = math.huge

    while candidate <= high do
      local movementDistance = nearestDistance(candidate, previousNotes)
      local score = movementDistance * 1000 + math.abs(candidate - centre)

      if score < bestScore then
        bestScore = score
        bestPitch = candidate
      end

      candidate = candidate + 12
    end

    if bestPitch ~= nil then
      output[#output + 1] = bestPitch
    end
  end

  table.sort(output)

  if #output == 0 then
    return copyNumberArray(targetNotes)
  end

  return output
end

local function makeInversion(baseChord, inversion)
  local output = {}
  local chordLength = #baseChord

  for i = 1, chordLength do
    local sourceIndex = ((i + inversion - 1) % chordLength) + 1
    local note = baseChord[sourceIndex]

    if sourceIndex <= inversion then
      note = note + 12
    end

    output[#output + 1] = note
  end

  table.sort(output)
  return output
end

local function symmetricNearestMovementScore(candidate, previous)
  local score = 0

  for i = 1, #candidate do
    score = score + nearestDistance(candidate[i], previous)
  end

  for i = 1, #previous do
    score = score + nearestDistance(previous[i], candidate)
  end

  return score / 2
end

local function inversionMovementScore(candidate, previous, targetCentre)
  local score = 0

  if #candidate == #previous then
    for i = 1, #candidate do
      local distance = math.abs(candidate[i] - previous[i])
      score = score + distance

      if distance > 12 then
        score = score + (distance - 12) * 0.5
      end
    end
  else
    score = symmetricNearestMovementScore(candidate, previous)
    score = score + math.abs(#candidate - #previous) * 3
  end

  score = score + math.abs(candidate[1] - previous[1]) * 0.2
  score = score + math.abs(candidate[#candidate] - previous[#previous]) * 0.2
  score = score + math.abs(averagePitch(candidate) - targetCentre) * 0.05

  return score
end

local function closestInversionVoiceLeading(targetNotes, previousNotes)
  local baseChord = sortAndRemoveDuplicates(targetNotes)

  if #baseChord == 0 or #previousNotes == 0 then
    return copyNumberArray(targetNotes)
  end

  local targetCentre, low, high = getRegisterBounds(targetNotes)
  local bestChord = nil
  local bestScore = math.huge
  local candidateKeys = {}

  for inversion = 0, #baseChord - 1 do
    local inversionChord = makeInversion(baseChord, inversion)

    for octaveShift = -8, 8 do
      local candidate = {}
      local candidateIsInRange = true

      for i = 1, #inversionChord do
        local note = inversionChord[i] + octaveShift * 12

        if note < low or note > high or note < MIDI_NOTE_MIN or note > MIDI_NOTE_MAX then
          candidateIsInRange = false
          break
        end

        candidate[#candidate + 1] = note
      end

      if candidateIsInRange then
        local candidateKey = table.concat(candidate, ",")

        if not candidateKeys[candidateKey] then
          candidateKeys[candidateKey] = true
          local score = inversionMovementScore(candidate, previousNotes, targetCentre)

          if score < bestScore then
            bestScore = score
            bestChord = candidate
          end
        end
      end
    end
  end

  if bestChord == nil then
    return closestTonesVoiceLeading(targetNotes, previousNotes)
  end

  return bestChord
end

function applyVoiceLeading(chordNotesArray, referenceNotes)
  local targetNotes = sortAndRemoveDuplicates(chordNotesArray)
  local previousNotes = sortAndRemoveDuplicates(referenceNotes or {})
  local mode = getVoiceLeadingMode()

  if mode == 1 or #previousNotes == 0 then
    return targetNotes
  end

  if mode == 2 then
    return closestTonesVoiceLeading(targetNotes, previousNotes)
  end

  if mode == 3 then
    return closestInversionVoiceLeading(targetNotes, previousNotes)
  end

  return targetNotes
end

function applyVoiceLeadingFromCurrentPosition(chordNotesArray)
  return applyVoiceLeading(chordNotesArray, getVoiceLeadingReferenceNotes())
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local MIDI_NOTE_MIN = 0
local MIDI_NOTE_MAX = 127

local function copyAndSortNotes(notes)
  local output = {}

  for i = 1, #notes do
    local note = tonumber(notes[i])

    if note ~= nil and note >= MIDI_NOTE_MIN and note <= MIDI_NOTE_MAX then
      output[#output + 1] = note
    end
  end

  table.sort(output)
  return output
end

local function removeDuplicateNotes(notes)
  local sorted = copyAndSortNotes(notes)
  local output = {}
  local previous = nil

  for i = 1, #sorted do
    local note = sorted[i]

    if previous == nil or note ~= previous then
      output[#output + 1] = note
      previous = note
    end
  end

  return output
end

local function applyDropTwo(notes)
  local output = copyAndSortNotes(notes)

  if #output < 3 then
    return output
  end

  local dropIndex = #output - 1
  local droppedPitch = output[dropIndex] - 12

  -- Avoid generating invalid MIDI notes at the bottom of the range.
  if droppedPitch >= MIDI_NOTE_MIN then
    output[dropIndex] = droppedPitch
    table.sort(output)
  end

  return output
end

local function rootPitchClassFromChordGunRoot(rootNote)
  -- ChordGun stores chromatic roots as 1..12 (C=1, B=12), while MIDI
  -- pitch classes are 0..11.
  return ((rootNote - 1) % 12 + 12) % 12
end

local function addLowRoot(notes, rootNote)
  local output = copyAndSortNotes(notes)

  if #output == 0 or rootNote == nil then
    return output
  end

  local lowestNote = output[1]
  local rootPitchClass = rootPitchClassFromChordGunRoot(rootNote)
  local lowRoot = rootPitchClass

  -- Find the highest instance of the root strictly below the current bass.
  while lowRoot + 12 < lowestNote do
    lowRoot = lowRoot + 12
  end

  if lowRoot >= lowestNote then
    lowRoot = lowRoot - 12
  end

  if lowRoot >= MIDI_NOTE_MIN and lowRoot <= MIDI_NOTE_MAX then
    output[#output + 1] = lowRoot
  end

  return removeDuplicateNotes(output)
end

function applyChordVoicing(chordNotesArray, rootNote)
  local mode = getVoicingMode()
  local output = copyAndSortNotes(chordNotesArray)

  if mode == 1 then
    return output
  end

  if mode == 2 then
    return applyDropTwo(output)
  end

  if mode == 3 then
    return addLowRoot(applyDropTwo(output), rootNote)
  end

  return output
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

function insertMidiNote(note, keepNotesSelected, selectedChord, noteIndex)

	local startPosition = getCursorPositionPPQ()

	local endPosition = nil
	local velocity = nil
	local channel = nil
	local muteState = nil
	
	if keepNotesSelected then

		local numberOfSelectedNotes = #selectedChord.selectedNotes

		if noteIndex > numberOfSelectedNotes then
			endPosition = selectedChord.selectedNotes[numberOfSelectedNotes].endPosition
			velocity = selectedChord.selectedNotes[numberOfSelectedNotes].velocity
			channel = selectedChord.selectedNotes[numberOfSelectedNotes].channel
			muteState = selectedChord.selectedNotes[numberOfSelectedNotes].muteState
		else
			endPosition = selectedChord.selectedNotes[noteIndex].endPosition
			velocity = selectedChord.selectedNotes[noteIndex].velocity
			channel = selectedChord.selectedNotes[noteIndex].channel
			muteState = selectedChord.selectedNotes[noteIndex].muteState
		end
		
	else
		endPosition = getMidiEndPositionPPQ()
		velocity = getCurrentVelocity()
		channel = getCurrentNoteChannel()
		muteState = false
	end

	local noSort = false

	reaper.MIDI_InsertNote(activeTake(), keepNotesSelected, muteState, startPosition, endPosition, channel, note, velocity, noSort)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local function playScaleChord(chordNotesArray)

  stopNotesFromPlaying()

  for noteIndex = 1, #chordNotesArray do
    playMidiNote(chordNotesArray[noteIndex])
  end

  setNotesThatArePlaying(chordNotesArray) 
end

function previewScaleChord()

  local scaleNoteIndex = getSelectedScaleNote()
  local chordTypeIndex = getSelectedChordType(scaleNoteIndex)

  local root = scaleNotes[scaleNoteIndex]
  local chord = scaleChords[scaleNoteIndex][chordTypeIndex]
  local octave = getOctave()

  local chordNotesArray = getChordNotesArray(root, chord, octave)
  chordNotesArray = applyVoiceLeadingFromCurrentPosition(chordNotesArray)
  chordNotesArray = applyChordVoicing(chordNotesArray, root)

  playScaleChord(chordNotesArray)
  updateChordText(root, chord, chordNotesArray)
end

function insertScaleChord(chordNotesArray, keepNotesSelected, selectedChord)

  deleteExistingNotesInNextInsertionTimePeriod(keepNotesSelected, selectedChord)

  for noteIndex = 1, #chordNotesArray do
    insertMidiNote(chordNotesArray[noteIndex], keepNotesSelected, selectedChord, noteIndex)
  end

  moveCursor(keepNotesSelected, selectedChord)
end

function playOrInsertScaleChord(actionDescription)

  local scaleNoteIndex = getSelectedScaleNote()
  local chordTypeIndex = getSelectedChordType(scaleNoteIndex)

  local root = scaleNotes[scaleNoteIndex]
  local chord = scaleChords[scaleNoteIndex][chordTypeIndex]
  local octave = getOctave()

  local baseChordNotesArray = getChordNotesArray(root, chord, octave)
  local chordNotesArray = applyVoiceLeadingFromCurrentPosition(baseChordNotesArray)
  chordNotesArray = applyChordVoicing(chordNotesArray, root)

  if activeTake() ~= nil and notCurrentlyRecording() then

    startUndoBlock()

      if thereAreNotesSelected() then 
        local finalChangedChord = changeSelectedNotesToScaleChords(baseChordNotesArray, root)

        if finalChangedChord ~= nil and #finalChangedChord > 0 then
          chordNotesArray = finalChangedChord
        end
      else
        insertScaleChord(chordNotesArray, false)
      end

    endUndoBlock(actionDescription)
  end

  playScaleChord(chordNotesArray)
  updateChordText(root, chord, chordNotesArray)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"


local function playScaleNote(noteValue)

  stopNotesFromPlaying()
  playMidiNote(noteValue)
  setNotesThatArePlaying({noteValue})
  setChordText("")
end


function insertScaleNote(noteValue, keepNotesSelected, selectedChord)

	deleteExistingNotesInNextInsertionTimePeriod(keepNotesSelected, selectedChord)

	local noteIndex = 1
	insertMidiNote(noteValue, keepNotesSelected, selectedChord, noteIndex)
	moveCursor(keepNotesSelected, selectedChord)
end

function previewScaleNote(octaveAdjustment)

  local scaleNoteIndex = getSelectedScaleNote()

  local root = scaleNotes[scaleNoteIndex]
  local octave = getOctave()
  local noteValue = root + ((octave+1+octaveAdjustment) * 12) - 1

  playScaleNote(noteValue)
end

function playOrInsertScaleNote(octaveAdjustment, actionDescription)

	local scaleNoteIndex = getSelectedScaleNote()

  local root = scaleNotes[scaleNoteIndex]
  local octave = getOctave()
  local noteValue = root + ((octave+1+octaveAdjustment) * 12) - 1

  if activeTake() ~= nil and notCurrentlyRecording() then

  	startUndoBlock()

		  if thereAreNotesSelected() then 
		    changeSelectedNotesToScaleNotes(noteValue)
		  else
		    insertScaleNote(noteValue, false)
		  end

		endUndoBlock(actionDescription)
  end

	playScaleNote(noteValue)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

SelectedNote = {}
SelectedNote.__index = SelectedNote

function SelectedNote:new(endPosition, velocity, channel, muteState, pitch)
  local self = {}
  setmetatable(self, SelectedNote)

  self.endPosition = endPosition
  self.velocity = velocity
  self.channel = channel
  self.muteState = muteState
  self.pitch = pitch

  return self
end

SelectedChord = {}
SelectedChord.__index = SelectedChord

function SelectedChord:new(startPosition, endPosition, velocity, channel, muteState, pitch)
  local self = {}
  setmetatable(self, SelectedChord)

  self.startPosition = startPosition
  self.longestEndPosition = endPosition

  self.selectedNotes = {}
  table.insert(self.selectedNotes, SelectedNote:new(endPosition, velocity, channel, muteState, pitch))

  return self
end

local function noteStartPositionDoesNotExist(selectedChords, startPositionArg)

  for _, selectedChord in pairs(selectedChords) do

    if selectedChord.startPosition == startPositionArg then
      return false
    end
  end

  return true
end

local function updateSelectedChord(selectedChords, startPositionArg, endPositionArg, velocityArg, channelArg, muteStateArg, pitchArg)

  for _, selectedChord in pairs(selectedChords) do

    if selectedChord.startPosition == startPositionArg then

      table.insert(selectedChord.selectedNotes, SelectedNote:new(endPositionArg, velocityArg, channelArg, muteStateArg, pitchArg))

      if endPositionArg > selectedChord.longestEndPosition then
        selectedChord.longestEndPosition = endPositionArg
      end
    end
  end
end

local function getSelectedChords()

  local numberOfNotes = getNumberOfNotes()
  local selectedChords = {}

  for noteIndex = 0, numberOfNotes-1 do

    local _, noteIsSelected, muteState, noteStartPositionPPQ, noteEndPositionPPQ, channel, pitch, velocity = reaper.MIDI_GetNote(activeTake(), noteIndex)

    if noteIsSelected then

      if noteStartPositionDoesNotExist(selectedChords, noteStartPositionPPQ) then
        table.insert(selectedChords, SelectedChord:new(noteStartPositionPPQ, noteEndPositionPPQ, velocity, channel, muteState, pitch))
      else
        updateSelectedChord(selectedChords, noteStartPositionPPQ, noteEndPositionPPQ, velocity, channel, muteState, pitch)
      end
    end
  end

  table.sort(selectedChords, function(a, b) return a.startPosition < b.startPosition end)

  for selectedChordIndex = 1, #selectedChords do
    table.sort(selectedChords[selectedChordIndex].selectedNotes, function(a,b) return a.pitch < b.pitch end)
  end

  return selectedChords
end

local function getSelectedChordPitches(selectedChord)
  local pitches = {}

  for i = 1, #selectedChord.selectedNotes do
    pitches[#pitches + 1] = selectedChord.selectedNotes[i].pitch
  end

  return pitches
end

local function deleteSelectedNotes()

  local numberOfNotes = getNumberOfNotes()

  for noteIndex = numberOfNotes-1, 0, -1 do

    local _, noteIsSelected = reaper.MIDI_GetNote(activeTake(), noteIndex)

    if noteIsSelected then
      deleteNote(noteIndex)
    end
  end
end

local function setEditCursorTo(arg)

  local cursorPosition = reaper.MIDI_GetProjTimeFromPPQPos(activeTake(), arg)
  setEditCursorPosition(cursorPosition)
end

function changeSelectedNotesToScaleChords(chordNotesArray, rootNote)

  local selectedChords = getSelectedChords()
  deleteSelectedNotes()

  local finalChordNotesArray = nil

  for i = 1, #selectedChords do
    local referenceNotes = getSelectedChordPitches(selectedChords[i])
    local voiceLedChord = applyVoiceLeading(chordNotesArray, referenceNotes)
    voiceLedChord = applyChordVoicing(voiceLedChord, rootNote)

    setEditCursorTo(selectedChords[i].startPosition)
    insertScaleChord(voiceLedChord, true, selectedChords[i])
    finalChordNotesArray = voiceLedChord
  end

  return finalChordNotesArray
end

function changeSelectedNotesToScaleNotes(noteValue)

  local selectedChords = getSelectedChords()
  deleteSelectedNotes()

  for i = 1, #selectedChords do
    setEditCursorTo(selectedChords[i].startPosition)
    insertScaleNote(noteValue, true, selectedChords[i])
  end
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

scaleNotes = {}
scaleChords = {}
scalePattern = nil
chordButtons = {}

function getNotesString(chordNotesArray)
  local notesString = ''
  for i, note in ipairs(chordNotesArray) do
    local noteName = getNoteName(note+1)
    if i ~= #chordNotesArray then
      notesString = notesString .. noteName .. ','
    else
      notesString = notesString .. noteName
    end
  end
  return notesString
end

function updateScaleNotes()
  scaleNotes = {}
  local tonic = getScaleTonicNote()
  for offset = 0, 11 do
    scaleNotes[offset + 1] = tonic + offset
  end
end

function updateScaleChords()
  scaleChords = {}
  for i, note in ipairs(scaleNotes) do
    scaleChords[i] = getScaleChordsForRootNote(note)
  end
end

function updateScaleNoteNames()
  for i, note in ipairs(scaleNotes) do
    setScaleNoteName(i, getNoteName(note))
  end
end

function updateScaleNotesText()
  local scaleNotesText = ''
  for i = 1, #scaleNotes do
    if scaleNotesText ~= '' then
      scaleNotesText = scaleNotesText .. ', '
    end
    scaleNotesText = scaleNotesText .. getScaleNoteName(i)
  end
  setScaleNotesText(scaleNotesText)
end

function getChordInversionText(chordNotesArray)
  local selectedScaleNote = getSelectedScaleNote()
  local inversionValue = getChordInversionState(selectedScaleNote)

  if inversionValue == 0 or math.fmod(inversionValue, #chordNotesArray) == 0 then
    return ''
  end

  return '/' .. getNoteName(chordNotesArray[1]+1)
end

function getChordInversionOctaveIndicator(numberOfChordNotes)
  local selectedScaleNote = getSelectedScaleNote()
  local inversionValue = getChordInversionState(selectedScaleNote)

  if inversionValue > 0 then
    local offsetValue = math.floor(inversionValue / numberOfChordNotes)
    return offsetValue > 0 and ('+' .. offsetValue) or '+'
  elseif inversionValue < 0 then
    local offsetValue = math.abs(math.ceil(inversionValue / numberOfChordNotes))
    return offsetValue > 0 and ('-' .. offsetValue) or '-'
  end

  return ''
end

function updateChordText(root, chord, chordNotesArray)
  local rootNoteName = getNoteName(root)
  local chordInversionText = getChordInversionText(chordNotesArray)
  local chordInversionOctaveIndicator = getChordInversionOctaveIndicator(#chordNotesArray)
  local chordString = rootNoteName .. chord["display"]
  local notesString = getNotesString(chordNotesArray)

  local chordTextValue = ''
  if string.match(chordInversionOctaveIndicator, "-") then
    chordTextValue = ("%s%12s%s%12s"):format(chordInversionOctaveIndicator, chordString, chordInversionText, notesString)
  elseif string.match(chordInversionOctaveIndicator, "+") then
    chordTextValue = ("%s%12s%s%12s%12s"):format('', chordString, chordInversionText, notesString, chordInversionOctaveIndicator)
  else
    chordTextValue = ("%s%12s%s%12s"):format('', chordString, chordInversionText, notesString)
  end

  setChordText(chordTextValue)
  showChordText()
end

function showChordText()
  reaper.Help_Set(getChordText(), false)
end

function updateScaleData()
  scalePattern = getScalePattern(getScaleTonicNote(), scales[1])
  updateScaleNotes()
  updateScaleNoteNames()
  updateScaleNotesText()
  updateScaleChords()
  updateScaleDegreeHeaders()
end

function showScaleStatus()
  reaper.Help_Set(("%s Chromatic: %s"):format(getScaleTonicName(), getScaleNotesText()), false)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local function transposeSelectedNotes(numberOfSemitones)

  local numberOfNotes = getNumberOfNotes()

  for noteIndex = numberOfNotes-1, 0, -1 do

    local _, noteIsSelected, muteState, noteStartPositionPPQ, noteEndPositionPPQ, channel, pitch, velocity = reaper.MIDI_GetNote(activeTake(), noteIndex)
  
    if noteIsSelected then
      deleteNote(noteIndex)
      local noSort = false
      reaper.MIDI_InsertNote(activeTake(), noteIsSelected, muteState, noteStartPositionPPQ, noteEndPositionPPQ, channel, pitch+numberOfSemitones, velocity, noSort)
    end
  end
end

function transposeSelectedNotesUpOneOctave()
  transposeSelectedNotes(12)
end

function transposeSelectedNotesDownOneOctave()
  transposeSelectedNotes(-12)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local function decrementChordInversion()

  if getVoiceLeadingMode() ~= 1 then
    return
  end

	local selectedScaleNote = getSelectedScaleNote()

  local chordInversionMin = getChordInversionMin()
  local chordInversion = getChordInversionState(selectedScaleNote)

  if chordInversion <= chordInversionMin then
    return
  end

  setChordInversionState(selectedScaleNote, chordInversion-1)
end

function decrementChordInversionAction()

	local actionDescription = "decrement chord inversion"
	decrementChordInversion()

	if thereAreNotesSelected() then
		playOrInsertScaleChord(actionDescription)
	else
		previewScaleChord()
	end
end

--

local function incrementChordInversion()

  if getVoiceLeadingMode() ~= 1 then
    return
  end

	local selectedScaleNote = getSelectedScaleNote()

  local chordInversionMax = getChordInversionMax()
  local chordInversion = getChordInversionState(selectedScaleNote)

  if chordInversion >= chordInversionMax then
    return
  end


  setChordInversionState(selectedScaleNote, chordInversion+1)
end

function incrementChordInversionAction()

	local actionDescription = "increment chord inversion"
	incrementChordInversion()

	if thereAreNotesSelected() then
		playOrInsertScaleChord(actionDescription)
	else
		previewScaleChord()
	end
end

--

local function decrementChordType()

	local selectedScaleNote = getSelectedScaleNote()
	local selectedChordType = getSelectedChordType(selectedScaleNote)

  if selectedChordType <= 1 then
    return
  end

  setSelectedChordType(selectedScaleNote, selectedChordType-1)
end

function decrementChordTypeAction()

	local actionDescription = "decrement chord type"
	decrementChordType()

	if thereAreNotesSelected() then
		playOrInsertScaleChord(actionDescription)
	else
		previewScaleChord()
	end
end

--

local function incrementChordType()

	local selectedScaleNote = getSelectedScaleNote()
	local selectedChordType = getSelectedChordType(selectedScaleNote)

  if selectedChordType >= #chords then
    return
  end

  setSelectedChordType(selectedScaleNote, selectedChordType+1)
end

function incrementChordTypeAction()

	local actionDescription = "increment chord type"
	incrementChordType()

	if thereAreNotesSelected() then
		playOrInsertScaleChord(actionDescription)
	else
		previewScaleChord()
	end
end

--

function playTonicNote()

  local root = scaleNotes[1]
  local octave = getOctave()
  local noteValue = root + ((octave+1) * 12) - 1

  stopNotesFromPlaying()
  playMidiNote(noteValue)
  setNotesThatArePlaying({noteValue})
end

local function decrementOctave()

  local octave = getOctave()

  if octave <= getOctaveMin() then
    return
  end

  setOctave(octave-1)
end

function decrementOctaveAction()

	decrementOctave()

	if thereAreNotesSelected() then
		startUndoBlock()
		transposeSelectedNotesDownOneOctave()
		endUndoBlock("decrement octave")
	else
		playTonicNote()
	end
end

--

local function incrementOctave()

  local octave = getOctave()

  if octave >= getOctaveMax() then
    return
  end

  setOctave(octave+1)
end

function incrementOctaveAction()

	incrementOctave()

	if thereAreNotesSelected() then
		startUndoBlock()
		transposeSelectedNotesUpOneOctave()
		endUndoBlock("increment octave")
	else
		playTonicNote()
	end
end

--

local function decrementScaleTonicNote()

  local tonicOption = getScaleTonicOption()

  if tonicOption <= 1 then
    return
  end

  setScaleTonicOption(tonicOption - 1)
end

function decrementScaleTonicNoteAction()

  decrementScaleTonicNote()

  setSelectedScaleNote(1)
  setChordText("")
  resetSelectedChordTypes()
  resetChordInversionStates()
  updateScaleData()
  showScaleStatus()
end

--

local function incrementScaleTonicNote()

  local tonicOption = getScaleTonicOption()

  if tonicOption >= getNumberOfTonicOptions() then
    return
  end

  setScaleTonicOption(tonicOption + 1)
end

function incrementScaleTonicNoteAction()

  incrementScaleTonicNote()

  setSelectedScaleNote(1)
  setChordText("")
  resetSelectedChordTypes()
  resetChordInversionStates()
  updateScaleData()
  showScaleStatus()
end

--

-- The scale selector is intentionally retained as a one-entry Chromatic
-- control.  These legacy actions therefore become harmless no-ops.
function decrementScaleTypeAction()
  setScaleType(1)
  showScaleStatus()
end

function incrementScaleTypeAction()
  setScaleType(1)
  showScaleStatus()
end

----


function scaleChordAction(scaleNoteIndex)

	setSelectedScaleNote(scaleNoteIndex)

	local selectedChordType = getSelectedChordType(scaleNoteIndex)
	local chord = scaleChords[scaleNoteIndex][selectedChordType]
	local actionDescription = "scale chord " .. scaleNoteIndex .. "  (" .. chord.code .. ")"

	playOrInsertScaleChord(actionDescription)
end

function previewScaleChordAction(scaleNoteIndex)

	setSelectedScaleNote(scaleNoteIndex)
	previewScaleChord()
end

--

function scaleNoteAction(scaleNoteIndex)

	setSelectedScaleNote(scaleNoteIndex)
	local actionDescription = "scale note " .. scaleNoteIndex
	playOrInsertScaleNote(0, actionDescription)
end

--

function lowerScaleNoteAction(scaleNoteIndex)

  if getOctave() <= getOctaveMin() then
    return
  end

	setSelectedScaleNote(scaleNoteIndex)
	local actionDescription = "lower scale note " .. scaleNoteIndex
	playOrInsertScaleNote(-1, actionDescription)
end

--

function higherScaleNoteAction(scaleNoteIndex)

  if getOctave() >= getOctaveMax() then
    return
  end

	setSelectedScaleNote(scaleNoteIndex)
	local actionDescription = "higher scale note " .. scaleNoteIndex
	playOrInsertScaleNote(1, actionDescription)
end


--

function previewScaleNoteAction(scaleNoteIndex)

	setSelectedScaleNote(scaleNoteIndex)
	previewScaleNote(0)
end

function previewLowerScaleNoteAction(scaleNoteIndex)

	if getOctave() <= getOctaveMin() then
		return
	end

	setSelectedScaleNote(scaleNoteIndex)
	previewScaleNote(-1)
end

function previewHigherScaleNoteAction(scaleNoteIndex)

	if getOctave() >= getOctaveMax() then
		return
	end

	setSelectedScaleNote(scaleNoteIndex)
	previewScaleNote(1)
end


--

function cycleVoiceLeadingModeAction()

  cycleVoiceLeadingMode()
  previewScaleChord()
end

--

function cycleVoicingModeAction()

  cycleVoicingMode()
  previewScaleChord()
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"


updateScaleData()
higherScaleNoteAction(10)
reaper.defer(emptyFunctionToPreventAutomaticCreationOfUndoPoint)
