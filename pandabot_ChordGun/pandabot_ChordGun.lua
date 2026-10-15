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
function drawDropdownIcon()

    local xOffset = gfx.x
    local yOffset = gfx.y
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.36078431372549, 0.39607843137255, 0.3843137254902)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = xOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 1 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 2 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 2 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.3843137254902, 0.4156862745098, 0.40392156862745)
    gfx.x = 2 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 2 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 2 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 2 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 3 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 3 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.35294117647059, 0.3843137254902, 0.37254901960784)
    gfx.x = 3 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.41176470588235, 0.43921568627451, 0.42745098039216)
    gfx.x = 3 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.67843137254902, 0.69411764705882, 0.69019607843137)
    gfx.x = 3 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.50196078431373, 0.52549019607843, 0.51764705882353)
    gfx.x = 3 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36078431372549, 0.39607843137255, 0.38039215686275)
    gfx.x = 3 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 3 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 3 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 4 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 4 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 4 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.34509803921569, 0.37647058823529, 0.36470588235294)
    gfx.x = 4 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.43529411764706, 0.46274509803922, 0.45098039215686)
    gfx.x = 4 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.92156862745098, 0.92549019607843, 0.92549019607843)
    gfx.x = 4 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.85882352941176, 0.86274509803922, 0.86274509803922)
    gfx.x = 4 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.53725490196078, 0.56078431372549, 0.55294117647059)
    gfx.x = 4 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.4, 0.38823529411765)
    gfx.x = 4 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36078431372549, 0.3921568627451, 0.38039215686275)
    gfx.x = 4 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 4 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 4 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 4 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 4 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 5 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 5 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 5 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.34509803921569, 0.38039215686275, 0.36470588235294)
    gfx.x = 5 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.43529411764706, 0.46274509803922, 0.45098039215686)
    gfx.x = 5 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.94901960784314, 0.95294117647059, 0.95294117647059)
    gfx.x = 5 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(1.0, 1.0, 1.0)
    gfx.x = 5 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.90196078431373, 0.90588235294118, 0.90196078431373)
    gfx.x = 5 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.6, 0.6156862745098, 0.61176470588235)
    gfx.x = 5 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.3921568627451, 0.42352941176471, 0.41176470588235)
    gfx.x = 5 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 5 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 5 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 5 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 5 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 6 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 6 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 6 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.34509803921569, 0.38039215686275, 0.36862745098039)
    gfx.x = 6 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.43529411764706, 0.46274509803922, 0.45098039215686)
    gfx.x = 6 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.94509803921569, 0.94509803921569, 0.94509803921569)
    gfx.x = 6 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(1.0, 1.0, 1.0)
    gfx.x = 6 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(1.0, 1.0, 1.0)
    gfx.x = 6 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.87058823529412, 0.87843137254902, 0.87843137254902)
    gfx.x = 6 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.52156862745098, 0.54509803921569, 0.53725490196078)
    gfx.x = 6 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.38823529411765)
    gfx.x = 6 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 6 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 6 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 6 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 7 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 7 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 7 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.34509803921569, 0.38039215686275, 0.36470588235294)
    gfx.x = 7 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.43529411764706, 0.46274509803922, 0.45098039215686)
    gfx.x = 7 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.94901960784314, 0.95294117647059, 0.95294117647059)
    gfx.x = 7 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(1.0, 1.0, 1.0)
    gfx.x = 7 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.90196078431373, 0.90588235294118, 0.90196078431373)
    gfx.x = 7 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.6, 0.6156862745098, 0.61176470588235)
    gfx.x = 7 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.3921568627451, 0.42352941176471, 0.41176470588235)
    gfx.x = 7 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 7 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 7 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 7 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 7 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 8 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 8 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 8 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.34509803921569, 0.37647058823529, 0.36470588235294)
    gfx.x = 8 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.43529411764706, 0.46274509803922, 0.45490196078431)
    gfx.x = 8 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.92156862745098, 0.92549019607843, 0.92549019607843)
    gfx.x = 8 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.85490196078431, 0.86274509803922, 0.85882352941176)
    gfx.x = 8 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.53725490196078, 0.56078431372549, 0.55294117647059)
    gfx.x = 8 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.4, 0.38823529411765)
    gfx.x = 8 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36078431372549, 0.3921568627451, 0.38039215686275)
    gfx.x = 8 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 8 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 8 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 8 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 8 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 9 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.39607843137255, 0.3843137254902)
    gfx.x = 9 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.35294117647059, 0.3843137254902, 0.37254901960784)
    gfx.x = 9 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.41176470588235, 0.43921568627451, 0.42745098039216)
    gfx.x = 9 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.67843137254902, 0.69411764705882, 0.69019607843137)
    gfx.x = 9 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.49803921568627, 0.52549019607843, 0.51764705882353)
    gfx.x = 9 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 9 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 9 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 9 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 9 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 9 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 9 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 9 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 10 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 10 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 10 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.3843137254902, 0.4156862745098, 0.40392156862745)
    gfx.x = 10 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 10 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 10 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 10 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 11 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.36078431372549, 0.3921568627451, 0.38039215686275)
    gfx.x = 11 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.39607843137255, 0.3843137254902)
    gfx.x = 11 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36470588235294, 0.4, 0.38823529411765)
    gfx.x = 11 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34509803921569, 0.37647058823529, 0.36470588235294)
    gfx.x = 11 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 12 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.36470588235294, 0.4, 0.38823529411765)
    gfx.x = 12 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.36862745098039, 0.40392156862745, 0.3921568627451)
    gfx.x = 12 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.34901960784314, 0.38039215686275, 0.36862745098039)
    gfx.x = 12 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 13 + xOffset
    gfx.y = yOffset
    gfx.setpixel(0.36862745098039, 0.4, 0.38823529411765)
    gfx.y = 1 + yOffset
    gfx.setpixel(0.34901960784314, 0.38039215686275, 0.36862745098039)
    gfx.x = 13 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.34509803921569, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.34901960784314, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.34509803921569, 0.37647058823529, 0.36470588235294)
    gfx.x = 13 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.34901960784314, 0.38039215686275, 0.36862745098039)
    gfx.x = 13 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.32549019607843, 0.35294117647059, 0.34117647058824)
    gfx.x = 13 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 10 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 11 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 12 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 13 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 14 + xOffset
    gfx.y = 14 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
end
function drawLeftArrow()

    local xOffset = gfx.x
    local yOffset = gfx.y
    gfx.x = 1 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 1 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 1 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.10196078431373, 0.10196078431373, 0.10196078431373)
    gfx.x = 1 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.18823529411765, 0.1921568627451, 0.1921568627451)
    gfx.x = 1 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.10196078431373, 0.10196078431373, 0.10196078431373)
    gfx.x = 1 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 1 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 1 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 1 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 2 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 2 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.074509803921569)
    gfx.x = 2 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.24313725490196, 0.25882352941176, 0.25882352941176)
    gfx.x = 2 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.45490196078431, 0.48627450980392, 0.49019607843137)
    gfx.x = 2 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.24313725490196, 0.25882352941176, 0.25882352941176)
    gfx.x = 2 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.074509803921569)
    gfx.x = 2 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 2 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 2 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 3 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.07843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 3 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.47450980392157, 0.51372549019608, 0.51372549019608)
    gfx.x = 3 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.56078431372549, 0.61176470588235, 0.61176470588235)
    gfx.x = 3 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.47450980392157, 0.51372549019608, 0.51372549019608)
    gfx.x = 3 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 3 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.07843137254902)
    gfx.x = 3 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 3 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 4 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 4 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.44313725490196, 0.47843137254902, 0.47843137254902)
    gfx.x = 4 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.56862745098039, 0.6156862745098, 0.61176470588235)
    gfx.x = 4 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.57647058823529, 0.62352941176471, 0.62352941176471)
    gfx.x = 4 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.56862745098039, 0.6156862745098, 0.61176470588235)
    gfx.x = 4 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.44313725490196, 0.47843137254902, 0.47843137254902)
    gfx.x = 4 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 4 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 4 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 5 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.30196078431373, 0.32156862745098, 0.32156862745098)
    gfx.x = 5 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.49411764705882, 0.53725490196078, 0.53725490196078)
    gfx.x = 5 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.51764705882353, 0.56470588235294, 0.56470588235294)
    gfx.x = 5 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.51372549019608, 0.55686274509804, 0.55686274509804)
    gfx.x = 5 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.51764705882353, 0.56470588235294, 0.56470588235294)
    gfx.x = 5 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.49411764705882, 0.53725490196078, 0.53725490196078)
    gfx.x = 5 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.30196078431373, 0.32156862745098, 0.32156862745098)
    gfx.x = 5 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.098039215686275, 0.098039215686275, 0.098039215686275)
    gfx.x = 5 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 6 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.11764705882353, 0.12156862745098, 0.12156862745098)
    gfx.x = 6 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.13725490196078, 0.14117647058824, 0.14117647058824)
    gfx.x = 6 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.13333333333333, 0.13725490196078, 0.13725490196078)
    gfx.x = 6 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.13333333333333, 0.13725490196078, 0.13725490196078)
    gfx.x = 6 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.13333333333333, 0.13725490196078, 0.13725490196078)
    gfx.x = 6 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.13725490196078, 0.14117647058824, 0.14117647058824)
    gfx.x = 6 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.11764705882353, 0.12156862745098, 0.12156862745098)
    gfx.x = 6 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 6 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 7 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.07843137254902, 0.074509803921569, 0.074509803921569)
    gfx.x = 7 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 7 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 7 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.070588235294118, 0.070588235294118, 0.070588235294118)
    gfx.x = 7 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 7 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 7 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.07843137254902, 0.074509803921569, 0.074509803921569)
    gfx.x = 7 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 7 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 8 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.086274509803922, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.086274509803922, 0.090196078431373, 0.090196078431373)
    gfx.x = 8 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
end
function drawRightArrow()

    local xOffset = gfx.x
    local yOffset = gfx.y
    gfx.x = 1 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.07843137254902, 0.074509803921569, 0.074509803921569)
    gfx.x = 1 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 1 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 1 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.070588235294118, 0.070588235294118, 0.070588235294118)
    gfx.x = 1 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 1 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.070588235294118, 0.066666666666667, 0.066666666666667)
    gfx.x = 1 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.07843137254902, 0.074509803921569, 0.074509803921569)
    gfx.x = 1 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 1 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 2 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.11764705882353, 0.12156862745098, 0.12156862745098)
    gfx.x = 2 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.13725490196078, 0.14117647058824, 0.14117647058824)
    gfx.x = 2 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.13333333333333, 0.13725490196078, 0.13725490196078)
    gfx.x = 2 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.13333333333333, 0.13725490196078, 0.13725490196078)
    gfx.x = 2 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.13333333333333, 0.13725490196078, 0.13725490196078)
    gfx.x = 2 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.13725490196078, 0.14117647058824, 0.14117647058824)
    gfx.x = 2 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.11764705882353, 0.12156862745098, 0.12156862745098)
    gfx.x = 2 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 2 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 3 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.30196078431373, 0.32156862745098, 0.32156862745098)
    gfx.x = 3 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.49411764705882, 0.53725490196078, 0.53725490196078)
    gfx.x = 3 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.51764705882353, 0.56470588235294, 0.56470588235294)
    gfx.x = 3 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.51372549019608, 0.55686274509804, 0.55686274509804)
    gfx.x = 3 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.51764705882353, 0.56470588235294, 0.56470588235294)
    gfx.x = 3 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.49411764705882, 0.53725490196078, 0.53725490196078)
    gfx.x = 3 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.30196078431373, 0.32156862745098, 0.32156862745098)
    gfx.x = 3 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.098039215686275, 0.098039215686275, 0.098039215686275)
    gfx.x = 3 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 4 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 4 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.44313725490196, 0.47843137254902, 0.47843137254902)
    gfx.x = 4 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.56862745098039, 0.6156862745098, 0.61176470588235)
    gfx.x = 4 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.57647058823529, 0.62352941176471, 0.62352941176471)
    gfx.x = 4 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.56862745098039, 0.6156862745098, 0.61176470588235)
    gfx.x = 4 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.44313725490196, 0.47843137254902, 0.47843137254902)
    gfx.x = 4 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 4 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 4 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 5 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.07843137254902)
    gfx.x = 5 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 5 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.47450980392157, 0.51372549019608, 0.51372549019608)
    gfx.x = 5 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.56078431372549, 0.61176470588235, 0.61176470588235)
    gfx.x = 5 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.47450980392157, 0.51372549019608, 0.51372549019608)
    gfx.x = 5 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.19607843137255, 0.2078431372549, 0.2078431372549)
    gfx.x = 5 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.07843137254902)
    gfx.x = 5 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.090196078431373, 0.090196078431373, 0.090196078431373)
    gfx.x = 5 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 6 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 6 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.074509803921569)
    gfx.x = 6 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.24313725490196, 0.25882352941176, 0.25882352941176)
    gfx.x = 6 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.45490196078431, 0.48627450980392, 0.49019607843137)
    gfx.x = 6 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.24313725490196, 0.25882352941176, 0.25882352941176)
    gfx.x = 6 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.07843137254902, 0.07843137254902, 0.074509803921569)
    gfx.x = 6 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 6 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 6 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 7 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 7 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 7 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.10196078431373, 0.10196078431373, 0.10196078431373)
    gfx.x = 7 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.18823529411765, 0.1921568627451, 0.1921568627451)
    gfx.x = 7 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.10196078431373, 0.10196078431373, 0.10196078431373)
    gfx.x = 7 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 7 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 7 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 7 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 8 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.086274509803922, 0.082352941176471, 0.082352941176471)
    gfx.x = 8 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.086274509803922, 0.086274509803922, 0.086274509803922)
    gfx.x = 8 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 1 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 2 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 3 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 4 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 5 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 6 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 7 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 8 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
    gfx.x = 9 + xOffset
    gfx.y = 9 + yOffset
    gfx.setpixel(0.0, 0.0, 0.0)
end
local function hex2rgb(arg) 

	local r, g, b = arg:match('(..)(..)(..)')
	r = tonumber(r, 16)/255
	g = tonumber(g, 16)/255
	b = tonumber(b, 16)/255
	return r, g, b
end

local function setColor(hexColor)

	local r, g, b = hex2rgb(hexColor)
	gfx.set(r, g, b, 1)
end

--[[ window ]]--

function setDrawColorToBackground()
	setColor("242424")
end

--[[ buttons ]]--

function setDrawColorToNormalButton()
	setColor("2D2D2D")
end

function setDrawColorToHighlightedButton()
	setColor("474747")
end

--

function setDrawColorToSelectedChordTypeButton()
	setColor("474747")
end

function setDrawColorToHighlightedSelectedChordTypeButton()
	setColor("717171")
end

--

function setDrawColorToSelectedChordTypeAndScaleNoteButton()
	setColor("DCDCDC")
end

function setDrawColorToHighlightedSelectedChordTypeAndScaleNoteButton()
	setColor("FFFFFF")
end

--

function setDrawColorToOutOfScaleButton()
	setColor("121212")
end

function setDrawColorToHighlightedOutOfScaleButton()
	setColor("474747")
end

--

function setDrawColorToButtonOutline()
	setColor("1D1D1D")
end

--[[ button text ]]--

function setDrawColorToNormalButtonText()
	setColor("D7D7D7")
end

function setDrawColorToHighlightedButtonText()
	setColor("EEEEEE")
end

--

function setDrawColorToSelectedChordTypeButtonText()
	setColor("F1F1F1")
end

function setDrawColorToHighlightedSelectedChordTypeButtonText()
	setColor("FDFDFD")
end

--

function setDrawColorToSelectedChordTypeAndScaleNoteButtonText()
	setColor("121212")
end

function setDrawColorToHighlightedSelectedChordTypeAndScaleNoteButtonText()
	setColor("000000")
end

--[[ buttons ]]--

function setDrawColorToHeaderOutline()
	setColor("151515")
end

function setDrawColorToHeaderBackground()
	setColor("242424")
end

function setDrawColorToHeaderText()
	setColor("818181")
end


--[[ frame ]]--
function setDrawColorToFrameOutline()
	setColor("0D0D0D")
end

function setDrawColorToFrameBackground()
	setColor("181818")
end


--[[ dropdown ]]--
function setDrawColorToDropdownOutline()
	setColor("090909")
end

function setDrawColorToDropdownBackground()
	setColor("1D1D1D")
end

function setDrawColorToDropdownText()
	setColor("D7D7D7")
end

--[[ valuebox ]]--
function setDrawColorToValueBoxOutline()
	setColor("090909")
end

function setDrawColorToValueBoxBackground()
	setColor("161616")
end

function setDrawColorToValueBoxText()
	setColor("9F9F9F")
end


--[[ text ]]--
function setDrawColorToText()
	setColor("878787")
end


--[[ debug ]]--

function setDrawColorToRed()
	setColor("FF0000")
end





--[[
function setDrawColorToBackground()

	local r, g, b
	local backgroundColor = {36, 36, 36, 1}		-- #242424
	gfx.set(table.unpack(backgroundColor))
end

function setDrawColorToNormalButton()

	local backgroundColor = {45, 45, 45, 1}		-- #2D2D2D
	gfx.set(table.unpack(backgroundColor))
end

function setDrawColorToHighlightedButton()

	local backgroundColor = {71, 71, 71, 1}		-- #474747
	gfx.set(table.unpack(backgroundColor))
end

function setDrawColorToSelectedButton()

	local backgroundColor = {220, 220, 220, 1}	-- #DCDCDC
	gfx.set(table.unpack(backgroundColor))
end
]]--
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

Docker = {}
Docker.__index = Docker

function Docker:new()

  local self = {}
  setmetatable(self, Docker)

  return self
end

local function dockWindow()

  local dockState = getDockState()
  gfx.dock(dockState)
  setWindowShouldBeDocked(true)

  guiShouldBeUpdated = true
end

function Docker:drawDockWindowContextMenu()

  setPositionAtMouseCursor()
  local selectedIndex = gfx.showmenu("dock window")

  if selectedIndex <= 0 then
    return
  end

  dockWindow()
  gfx.mouse_cap = 0
end

local function undockWindow()

  setWindowShouldBeDocked(false)
  gfx.dock(0)
  guiShouldBeUpdated = true
end

function Docker:drawUndockWindowContextMenu()

  setPositionAtMouseCursor()
  local selectedIndex = gfx.showmenu("undock window")

  if selectedIndex <= 0 then
    return
  end

  undockWindow()
  gfx.mouse_cap = 0
end

function Docker:update()

  if rightMouseButtonIsHeldDown() and windowIsDocked() then
    self:drawUndockWindowContextMenu()
  end

  if rightMouseButtonIsHeldDown() and windowIsNotDocked() then
    self:drawDockWindowContextMenu()
  end
end

HitArea = {}
HitArea.__index = HitArea

function HitArea:new(x, y, width, height)
  local self = {}
  setmetatable(self, HitArea)

  self.x = x
  self.y = y
  self.width = width
  self.height = height

  return self
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

OctaveValueBox = {}
OctaveValueBox.__index = OctaveValueBox

function OctaveValueBox:new(x, y, width, height)

  local self = {}
  setmetatable(self, OctaveValueBox)

  self.x = x
  self.y = y
  self.width = width
  self.height = height

  return self
end

function OctaveValueBox:drawRectangle()

    setDrawColorToValueBoxBackground()
    gfx.rect(self.x, self.y, self.width, self.height)
end

function OctaveValueBox:drawRectangleOutline()

    setDrawColorToValueBoxOutline()
    gfx.rect(self.x-1, self.y-1, self.width+1, self.height+1, false)
end

function OctaveValueBox:drawRectangles()

  self:drawRectangle()
  self:drawRectangleOutline() 
end

function OctaveValueBox:drawLeftArrow()

  gfx.x = self.x + 2
  gfx.y = self.y + 2
  drawLeftArrow()
end

function OctaveValueBox:drawRightArrow()

  local imageWidth = 9
  gfx.x = self.x + self.width - imageWidth - 3
  gfx.y = self.y + 2
  drawRightArrow()
end

function OctaveValueBox:drawImages()
  self:drawLeftArrow()
  self:drawRightArrow()
end

function OctaveValueBox:drawText()

  local octaveText = getOctave()

	setDrawColorToValueBoxText()
	local stringWidth, stringHeight = gfx.measurestr(octaveText)
	gfx.x = self.x + ((self.width - stringWidth) / 2)
	gfx.y = self.y + ((self.height - stringHeight) / 2)
	gfx.drawstr(octaveText)
end

local hitAreaWidth = 18

local function leftButtonHasBeenClicked(valueBox)
  local hitArea = HitArea:new(valueBox.x-1, valueBox.y-1, hitAreaWidth, valueBox.height+1)
  return mouseIsHoveringOver(hitArea) and leftMouseButtonIsHeldDown()
end

local function rightButtonHasBeenClicked(valueBox)
  local hitArea = HitArea:new(valueBox.x+valueBox.width-hitAreaWidth, valueBox.y-1, hitAreaWidth, valueBox.height+1)
  return mouseIsHoveringOver(hitArea) and leftMouseButtonIsHeldDown()
end

function OctaveValueBox:update()

  self:drawRectangles()
  self:drawImages()

  if mouseButtonIsNotPressedDown and leftButtonHasBeenClicked(self) then
    mouseButtonIsNotPressedDown = false
    decrementOctaveAction()
  end

  if mouseButtonIsNotPressedDown and rightButtonHasBeenClicked(self) then
    mouseButtonIsNotPressedDown = false
    incrementOctaveAction()
  end

  self:drawText()
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

Label = {}
Label.__index = Label

function Label:new(x, y, width, height, getTextCallback)

  local self = {}
  setmetatable(self, Label)

  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.getTextCallback = getTextCallback

  return self
end

function Label:drawRedOutline()
  setDrawColorToRed()
  gfx.rect(self.x, self.y, self.width, self.height, false)
end

function Label:drawText(text)

	setDrawColorToText()
	local stringWidth, stringHeight = gfx.measurestr(text)
	gfx.x = self.x + ((self.width - stringWidth) / 2)
	gfx.y = self.y + ((self.height - stringHeight) / 2)
  gfx.drawstr(text)
end

function Label:update()
  --self:drawRedOutline()

  local text = self.getTextCallback()
  self:drawText(text)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

Header = {}
Header.__index = Header

local radius = 5

function Header:new(x, y, width, height, getTextCallback)

  local self = {}
  setmetatable(self, Header)

  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.getTextCallback = getTextCallback

  return self
end

function Header:drawCorners(offset)
  gfx.circle(self.x + radius + offset, self.y + radius + offset, radius, true)
  gfx.circle(self.x + self.width - radius - offset, self.y + radius + offset, radius, true)
end

function Header:drawEnds(offset)
  gfx.rect(self.x + offset, self.y + radius + offset, radius, self.height - radius * 2 - 2 * offset, true)
  gfx.rect(self.x + self.width - radius - offset, self.y + radius + offset, radius + 1, self.height - radius * 2 - 2 * offset, true)
end

function Header:drawBodyAndSides(offset)
  gfx.rect(self.x + radius + offset, self.y + offset, self.width - radius * 2 - 2 * offset, self.height - radius - 2 * offset, true)
end

function Header:drawHeaderOutline()

  setDrawColorToHeaderOutline()
  self:drawCorners(0)
  self:drawEnds(0)
  self:drawBodyAndSides(0)
end

function Header:drawRoundedRectangle()

  setDrawColorToHeaderBackground()
  self:drawCorners(1)
  self:drawEnds(1)
  self:drawBodyAndSides(1)
end

function Header:drawRoundedRectangles()
  
  self:drawHeaderOutline()
  self:drawRoundedRectangle()
end

function Header:drawText(text)

  setDrawColorToHeaderText()

  local lines = {}
  for line in tostring(text):gmatch("([^\n]+)") do
    lines[#lines + 1] = line
  end

  if #lines == 0 then
    lines[1] = ""
  end

  local _, lineHeight = gfx.measurestr("Ag")
  local totalHeight = lineHeight * #lines
  local y = self.y + (self.height - totalHeight) / 2 - 1

  for _, line in ipairs(lines) do
    local stringWidth = gfx.measurestr(line)
    gfx.x = self.x + (self.width - stringWidth) / 2
    gfx.y = y
    gfx.drawstr(line)
    y = y + lineHeight
  end
end

function Header:update()

    self:drawRoundedRectangles()

    local text = self.getTextCallback()
    self:drawText(text)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

Frame = {}
Frame.__index = Frame

local radius = 10

function Frame:new(x, y, width, height)

  local self = {}
  setmetatable(self, Frame)

  self.x = x
  self.y = y
  self.width = width
  self.height = height

  return self
end

function Frame:drawCorners(offset)
  gfx.circle(self.x + radius + offset, self.y + radius + offset, radius, true)
  gfx.circle(self.x + self.width - radius - offset, self.y + radius + offset, radius, true)
  gfx.circle(self.x + radius + offset, self.y + self.height - radius - offset, radius, true)
  gfx.circle(self.x + self.width - radius - offset, self.y + self.height - radius - offset, radius, true)
end

function Frame:drawEnds(offset)
  gfx.rect(self.x + offset, self.y + radius + offset, radius, self.height - radius * 2, true)
  gfx.rect(self.x + self.width - radius - offset, self.y + radius - offset, radius + 1, self.height - radius * 2, true)
end

function Frame:drawBodyAndSides(offset)
  gfx.rect(self.x + radius + offset, self.y + offset, self.width - radius * 2 - 2 * offset, self.height + 1 - 2 * offset, true)
end

function Frame:drawFrameOutline()

  setDrawColorToFrameOutline()
  self:drawCorners(0)
  self:drawEnds(0)
  self:drawBodyAndSides(0)
end

function Frame:drawRectangle()

  setDrawColorToFrameBackground()
  self:drawCorners(1)
  self:drawEnds(1)
  self:drawBodyAndSides(1)
end

function Frame:drawRectangles()
  
  self:drawFrameOutline()
  self:drawRectangle()
end

function Frame:update()

    self:drawRectangles()
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown:new(x, y, width, height, options, defaultOptionIndex, onSelectionCallback)

  local self = {}
  setmetatable(self, Dropdown)

  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.options = options
  self.selectedIndex = defaultOptionIndex
  self.onSelectionCallback = onSelectionCallback
  self.dropdownList = {}
  self:updateDropdownList()
  return self
end

function Dropdown:drawRectangle()

		setDrawColorToDropdownBackground()
		gfx.rect(self.x, self.y, self.width, self.height)
end

function Dropdown:drawRectangleOutline()

		setDrawColorToDropdownOutline()
		gfx.rect(self.x-1, self.y-1, self.width+1, self.height+1, false)
end

function Dropdown:drawRectangles()

	self:drawRectangle()
	self:drawRectangleOutline()	
end

function Dropdown:drawText()

	local text = self.options[self.selectedIndex]

	setDrawColorToDropdownText()
	local stringWidth, stringHeight = gfx.measurestr(text)
	gfx.x = self.x + 7
	gfx.y = self.y + ((self.height - stringHeight) / 2)
	gfx.drawstr(text)
end

function Dropdown:drawImage()

	local imageWidth = 14
	gfx.x = self.x + self.width - imageWidth - 1
	gfx.y = self.y
	drawDropdownIcon()
end

local function dropdownHasBeenClicked(dropdown)
	return mouseIsHoveringOver(dropdown) and leftMouseButtonIsHeldDown()
end

function Dropdown:updateDropdownList()

	self.dropdownList = {}

	for index, option in pairs(self.options) do

		if (self.selectedIndex == index) then
			table.insert(self.dropdownList, "!" .. option)
		else
			table.insert(self.dropdownList, option)
		end
	end
end

function Dropdown:openMenu()

	setPositionAtMouseCursor()
	local selectedIndex = gfx.showmenu(table.concat(self.dropdownList,"|"))

	if selectedIndex <= 0 then
		return
	end

	self.selectedIndex = selectedIndex
	self.onSelectionCallback(selectedIndex)
	self:updateDropdownList()
end

function Dropdown:update()

		self:drawRectangles()
		self:drawText()
		self:drawImage()
		
		if mouseButtonIsNotPressedDown and dropdownHasBeenClicked(self) then
			mouseButtonIsNotPressedDown = false
			self:openMenu()
		end
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

ChordInversionValueBox = {}
ChordInversionValueBox.__index = ChordInversionValueBox

function ChordInversionValueBox:new(x, y, width, height)

  local self = {}
  setmetatable(self, ChordInversionValueBox)

  self.x = x
  self.y = y
  self.width = width
  self.height = height

  return self
end

function ChordInversionValueBox:drawRectangle()

    setDrawColorToValueBoxBackground()
    gfx.rect(self.x, self.y, self.width, self.height)
end

function ChordInversionValueBox:drawRectangleOutline()

    setDrawColorToValueBoxOutline()
    gfx.rect(self.x-1, self.y-1, self.width+1, self.height+1, false)
end

function ChordInversionValueBox:drawRectangles()

  self:drawRectangle()
  self:drawRectangleOutline() 
end

function ChordInversionValueBox:drawLeftArrow()

  gfx.x = self.x + 2
  gfx.y = self.y + 2
  drawLeftArrow()
end

function ChordInversionValueBox:drawRightArrow()

  local imageWidth = 9
  gfx.x = self.x + self.width - imageWidth - 3
  gfx.y = self.y + 2
  drawRightArrow()
end

function ChordInversionValueBox:drawImages()

  if getVoiceLeadingMode() == 1 then
    self:drawLeftArrow()
    self:drawRightArrow()
  end
end

function ChordInversionValueBox:drawText()

  local chordInversionText = "AUTO"

  if getVoiceLeadingMode() == 1 then
    local selectedScaleNote = getSelectedScaleNote()
    chordInversionText = getChordInversionState(selectedScaleNote)

    if chordInversionText > -1 then
      chordInversionText = "0" .. chordInversionText
    end
  end

  setDrawColorToValueBoxText()
  local stringWidth, stringHeight = gfx.measurestr(chordInversionText)
  gfx.x = self.x + ((self.width - stringWidth) / 2)
  gfx.y = self.y + ((self.height - stringHeight) / 2)
  gfx.drawstr(chordInversionText)
end

local hitAreaWidth = 18

local function leftButtonHasBeenClicked(valueBox)
  local hitArea = HitArea:new(valueBox.x-1, valueBox.y-1, hitAreaWidth, valueBox.height+1)
  return mouseIsHoveringOver(hitArea) and leftMouseButtonIsHeldDown()
end

local function rightButtonHasBeenClicked(valueBox)
  local hitArea = HitArea:new(valueBox.x+valueBox.width-hitAreaWidth, valueBox.y-1, hitAreaWidth, valueBox.height+1)
  return mouseIsHoveringOver(hitArea) and leftMouseButtonIsHeldDown()
end

local function shiftModifierIsHeldDown()
  return gfx.mouse_cap & 8 == 8
end

function ChordInversionValueBox:onLeftButtonPress()
  decrementChordInversion()
  previewScaleChord()
end

function ChordInversionValueBox:onLeftButtonShiftPress()
  decrementChordInversionAction()
end

function ChordInversionValueBox:onRightButtonPress()
  incrementChordInversion()
  previewScaleChord()
end

function ChordInversionValueBox:onRightButtonShiftPress()
  incrementChordInversionAction()
end

function ChordInversionValueBox:update()

  self:drawRectangles()
  self:drawImages()

  if getVoiceLeadingMode() == 1 then

    if mouseButtonIsNotPressedDown and leftButtonHasBeenClicked(self) then
      mouseButtonIsNotPressedDown = false

      if shiftModifierIsHeldDown() then
        self:onLeftButtonShiftPress()
      else
        self:onLeftButtonPress()
      end
    end

    if mouseButtonIsNotPressedDown and rightButtonHasBeenClicked(self) then
      mouseButtonIsNotPressedDown = false

      if shiftModifierIsHeldDown() then
        self:onRightButtonShiftPress()
      else
        self:onRightButtonPress()
      end
    end
  end

  self:drawText()
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

ChordButton = {}
ChordButton.__index = ChordButton

function ChordButton:new(text, x, y, width, height, scaleNoteIndex, chordTypeIndex, chordIsInScale)

  local self = {}
  setmetatable(self, ChordButton)

  self.text = text
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.scaleNoteIndex = scaleNoteIndex
  self.chordTypeIndex = chordTypeIndex
  self.chordIsInScale = chordIsInScale

  return self
end

function ChordButton:isSelectedChordType()

	local selectedScaleNote = getSelectedScaleNote()
	local selectedChordType = getSelectedChordType(self.scaleNoteIndex)

	local chordTypeIsSelected = (tonumber(self.chordTypeIndex) == tonumber(selectedChordType))
	local scaleNoteIsNotSelected = (tonumber(self.scaleNoteIndex) ~= tonumber(selectedScaleNote))

	return chordTypeIsSelected and scaleNoteIsNotSelected
end

function ChordButton:isSelectedChordTypeAndSelectedScaleNote()

	local selectedScaleNote = getSelectedScaleNote()
	local selectedChordType = getSelectedChordType(self.scaleNoteIndex)

	local chordTypeIsSelected = (tonumber(self.chordTypeIndex) == tonumber(selectedChordType))
	local scaleNoteIsSelected = (tonumber(self.scaleNoteIndex) == tonumber(selectedScaleNote))

	return chordTypeIsSelected and scaleNoteIsSelected
end


function ChordButton:drawButtonRectangle()

		if self:isSelectedChordTypeAndSelectedScaleNote() then

			if mouseIsHoveringOver(self) then
				setDrawColorToHighlightedSelectedChordTypeAndScaleNoteButton()
			else
				setDrawColorToSelectedChordTypeAndScaleNoteButton()
			end

		elseif self:isSelectedChordType() then

			if mouseIsHoveringOver(self) then
				setDrawColorToHighlightedSelectedChordTypeButton()
			else
				setDrawColorToSelectedChordTypeButton()
			end

		else

			if mouseIsHoveringOver(self) then
				setDrawColorToHighlightedButton()
			else

				if self.chordIsInScale then
					setDrawColorToNormalButton()
				else
					setDrawColorToOutOfScaleButton()
				end			
			end
		end

		gfx.rect(self.x, self.y, self.width, self.height)
end

function ChordButton:drawButtonOutline()

		setDrawColorToButtonOutline()
		gfx.rect(self.x-1, self.y-1, self.width+1, self.height+1, false)
end

function ChordButton:drawRectangles()

	self:drawButtonRectangle()
	self:drawButtonOutline()	
end

function ChordButton:drawText()

	if self:isSelectedChordTypeAndSelectedScaleNote() then

		if mouseIsHoveringOver(self) then
			setDrawColorToHighlightedSelectedChordTypeAndScaleNoteButtonText()
		else
			setDrawColorToSelectedChordTypeAndScaleNoteButtonText()
		end

	elseif self:isSelectedChordType() then

		if mouseIsHoveringOver(self) then
			setDrawColorToHighlightedSelectedChordTypeButtonText()
		else
			setDrawColorToSelectedChordTypeButtonText()
		end

	else

		if mouseIsHoveringOver(self) then
			setDrawColorToHighlightedButtonText()
		else
			setDrawColorToNormalButtonText()
		end
	end

	local stringWidth, stringHeight = gfx.measurestr(self.text)
	gfx.x = self.x + ((self.width - stringWidth) / 2)
	gfx.y = self.y + ((self.height - stringHeight) / 2)
	gfx.drawstr(self.text)
end

local function buttonHasBeenClicked(button)
	return mouseIsHoveringOver(button) and leftMouseButtonIsHeldDown()
end

local function shiftModifierIsHeldDown()
	return gfx.mouse_cap & 8 == 8
end

function ChordButton:onPress()

	previewScaleChord()
end

function ChordButton:onShiftPress()

	local chord = scaleChords[self.scaleNoteIndex][self.chordTypeIndex]
	local actionDescription = "scale chord " .. self.scaleNoteIndex .. "  (" .. chord.code .. ")"
	playOrInsertScaleChord(actionDescription)
end

function ChordButton:update()

	self:drawRectangles()
	self:drawText()

	if mouseButtonIsNotPressedDown and buttonHasBeenClicked(self) then

		mouseButtonIsNotPressedDown = false

		setSelectedScaleNote(self.scaleNoteIndex)
		setSelectedChordType(self.scaleNoteIndex, self.chordTypeIndex)

		if shiftModifierIsHeldDown() then
			self:onShiftPress()
		else
			self:onPress()
		end		
	end
end

inputCharacters = {}

inputCharacters["0"] = 48
inputCharacters["1"] = 49
inputCharacters["2"] = 50
inputCharacters["3"] = 51
inputCharacters["4"] = 52
inputCharacters["5"] = 53
inputCharacters["6"] = 54
inputCharacters["7"] = 55
inputCharacters["8"] = 56
inputCharacters["9"] = 57
inputCharacters["-"] = 45
inputCharacters["="] = 61
inputCharacters["`"] = 96

inputCharacters["a"] = 97
inputCharacters["b"] = 98
inputCharacters["c"] = 99
inputCharacters["d"] = 100
inputCharacters["e"] = 101
inputCharacters["f"] = 102
inputCharacters["g"] = 103
inputCharacters["h"] = 104
inputCharacters["i"] = 105
inputCharacters["j"] = 106
inputCharacters["k"] = 107
inputCharacters["l"] = 108
inputCharacters["m"] = 109
inputCharacters["n"] = 110
inputCharacters["o"] = 111
inputCharacters["p"] = 112
inputCharacters["q"] = 113
inputCharacters["r"] = 114
inputCharacters["s"] = 115
inputCharacters["t"] = 116
inputCharacters["u"] = 117
inputCharacters["v"] = 118
inputCharacters["w"] = 119
inputCharacters["x"] = 120
inputCharacters["y"] = 121
inputCharacters["z"] = 122


inputCharacters["!"] = 33
inputCharacters["@"] = 64
inputCharacters["#"] = 35
inputCharacters["$"] = 36
inputCharacters["%"] = 37
inputCharacters["^"] = 94
inputCharacters["&"] = 38
inputCharacters["*"] = 42
inputCharacters["("] = 40
inputCharacters[")"] = 41
inputCharacters["_"] = 95
inputCharacters["+"] = 43

inputCharacters["A"] = 65
inputCharacters["B"] = 66
inputCharacters["C"] = 67
inputCharacters["D"] = 68
inputCharacters["E"] = 69
inputCharacters["F"] = 70
inputCharacters["G"] = 71
inputCharacters["H"] = 72
inputCharacters["I"] = 73
inputCharacters["J"] = 74
inputCharacters["K"] = 75
inputCharacters["L"] = 76
inputCharacters["M"] = 77
inputCharacters["N"] = 78
inputCharacters["O"] = 79
inputCharacters["P"] = 80
inputCharacters["Q"] = 81
inputCharacters["R"] = 82
inputCharacters["S"] = 83
inputCharacters["T"] = 84
inputCharacters["U"] = 85
inputCharacters["V"] = 86
inputCharacters["W"] = 87
inputCharacters["X"] = 88
inputCharacters["Y"] = 89
inputCharacters["Z"] = 90

inputCharacters[","] = 44
inputCharacters["."] = 46
inputCharacters["<"] = 60
inputCharacters[">"] = 62

inputCharacters["ESC"] = 27

inputCharacters["LEFTARROW"] = 1818584692
inputCharacters["RIGHTARROW"] = 1919379572
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"


local function moveEditCursorLeftByGrid()
	local commandId = 40047
	reaper.MIDIEditor_OnCommand(activeMidiEditor(), commandId)
end

local function moveEditCursorRightByGrid()
	local commandId = 40048
	reaper.MIDIEditor_OnCommand(activeMidiEditor(), commandId)
end

function handleInput()

	local operatingSystem = string.lower(reaper.GetOS())

	inputCharacter = gfx.getchar()
	
	if inputCharacter == inputCharacters["ESC"] then
		gfx.quit()
	end

	if inputCharacter == inputCharacters["LEFTARROW"] then
		moveEditCursorLeftByGrid()
	end

	if inputCharacter == inputCharacters["RIGHTARROW"] then
		moveEditCursorRightByGrid()
	end


	local function middleMouseButtonIsHeldDown()
		return gfx.mouse_cap & 64 == 64
	end

	if inputCharacter == inputCharacters["`"] or middleMouseButtonIsHeldDown() then
		stopAllNotesFromPlaying()
	end

	--

	if inputCharacter == inputCharacters["1"] then
		previewScaleChordAction(1)
	end

	if inputCharacter == inputCharacters["2"] then
		previewScaleChordAction(2)
	end

	if inputCharacter == inputCharacters["3"] then
		previewScaleChordAction(3)
	end

	if inputCharacter == inputCharacters["4"] then
		previewScaleChordAction(4)
	end

	if inputCharacter == inputCharacters["5"] then
		previewScaleChordAction(5)
	end

	if inputCharacter == inputCharacters["6"] then
		previewScaleChordAction(6)
	end

	if inputCharacter == inputCharacters["7"] then
		previewScaleChordAction(7)
	end

	if inputCharacter == inputCharacters["8"] then
		previewScaleChordAction(8)
	end

	if inputCharacter == inputCharacters["9"] then
		previewScaleChordAction(9)
	end

	if inputCharacter == inputCharacters["0"] then
		previewScaleChordAction(10)
	end

	if inputCharacter == inputCharacters["-"] then
		previewScaleChordAction(11)
	end

	if inputCharacter == inputCharacters["="] then
		previewScaleChordAction(12)
	end

	--


	if inputCharacter == inputCharacters["!"] then
		scaleChordAction(1)
	end

	if inputCharacter == inputCharacters["@"] then
		scaleChordAction(2)
	end

	if inputCharacter == inputCharacters["#"] then
		scaleChordAction(3)
	end

	if inputCharacter == inputCharacters["$"] then
		scaleChordAction(4)
	end

	if inputCharacter == inputCharacters["%"] then
		scaleChordAction(5)
	end

	if inputCharacter == inputCharacters["^"] then
		scaleChordAction(6)
	end

	if inputCharacter == inputCharacters["&"] then
		scaleChordAction(7)
	end

	if inputCharacter == inputCharacters["*"] then
		scaleChordAction(8)
	end

	if inputCharacter == inputCharacters["("] then
		scaleChordAction(9)
	end

	if inputCharacter == inputCharacters[")"] then
		scaleChordAction(10)
	end

	if inputCharacter == inputCharacters["_"] then
		scaleChordAction(11)
	end

	if inputCharacter == inputCharacters["+"] then
		scaleChordAction(12)
	end

	--


	if inputCharacter == inputCharacters["q"] then
		previewHigherScaleNoteAction(1)
	end

	if inputCharacter == inputCharacters["w"] then
		previewHigherScaleNoteAction(2)
	end

	if inputCharacter == inputCharacters["e"] then
		previewHigherScaleNoteAction(3)
	end

	if inputCharacter == inputCharacters["r"] then
		previewHigherScaleNoteAction(4)
	end

	if inputCharacter == inputCharacters["t"] then
		previewHigherScaleNoteAction(5)
	end

	if inputCharacter == inputCharacters["y"] then
		previewHigherScaleNoteAction(6)
	end

	if inputCharacter == inputCharacters["u"] then
		previewHigherScaleNoteAction(7)
	end

	--

	if inputCharacter == inputCharacters["a"] then
		previewScaleNoteAction(1)
	end

	if inputCharacter == inputCharacters["s"] then
		previewScaleNoteAction(2)
	end

	if inputCharacter == inputCharacters["d"] then
		previewScaleNoteAction(3)
	end

	if inputCharacter == inputCharacters["f"] then
		previewScaleNoteAction(4)
	end

	if inputCharacter == inputCharacters["g"] then
		previewScaleNoteAction(5)
	end

	if inputCharacter == inputCharacters["h"] then
		previewScaleNoteAction(6)
	end

	if inputCharacter == inputCharacters["j"] then
		previewScaleNoteAction(7)
	end

	--

	if inputCharacter == inputCharacters["z"] then
		previewLowerScaleNoteAction(1)
	end

	if inputCharacter == inputCharacters["x"] then
		previewLowerScaleNoteAction(2)
	end

	if inputCharacter == inputCharacters["c"] then
		previewLowerScaleNoteAction(3)
	end

	if inputCharacter == inputCharacters["v"] then
		previewLowerScaleNoteAction(4)
	end

	if inputCharacter == inputCharacters["b"] then
		previewLowerScaleNoteAction(5)
	end

	if inputCharacter == inputCharacters["n"] then
		previewLowerScaleNoteAction(6)
	end

	if inputCharacter == inputCharacters["m"] then
		previewLowerScaleNoteAction(7)
	end



	--


	if inputCharacter == inputCharacters["Q"] then
		higherScaleNoteAction(1)
	end

	if inputCharacter == inputCharacters["W"] then
		higherScaleNoteAction(2)
	end

	if inputCharacter == inputCharacters["E"] then
		higherScaleNoteAction(3)
	end

	if inputCharacter == inputCharacters["R"] then
		higherScaleNoteAction(4)
	end

	if inputCharacter == inputCharacters["T"] then
		higherScaleNoteAction(5)
	end

	if inputCharacter == inputCharacters["Y"] then
		higherScaleNoteAction(6)
	end

	if inputCharacter == inputCharacters["U"] then
		higherScaleNoteAction(7)
	end

	--

	if inputCharacter == inputCharacters["A"] then
		scaleNoteAction(1)
	end

	if inputCharacter == inputCharacters["S"] then
		scaleNoteAction(2)
	end

	if inputCharacter == inputCharacters["D"] then
		scaleNoteAction(3)
	end

	if inputCharacter == inputCharacters["F"] then
		scaleNoteAction(4)
	end

	if inputCharacter == inputCharacters["G"] then
		scaleNoteAction(5)
	end

	if inputCharacter == inputCharacters["H"] then
		scaleNoteAction(6)
	end

	if inputCharacter == inputCharacters["J"] then
		scaleNoteAction(7)
	end

	--

	if inputCharacter == inputCharacters["Z"] then
		lowerScaleNoteAction(1)
	end

	if inputCharacter == inputCharacters["X"] then
		lowerScaleNoteAction(2)
	end

	if inputCharacter == inputCharacters["C"] then
		lowerScaleNoteAction(3)
	end

	if inputCharacter == inputCharacters["V"] then
		lowerScaleNoteAction(4)
	end

	if inputCharacter == inputCharacters["B"] then
		lowerScaleNoteAction(5)
	end

	if inputCharacter == inputCharacters["N"] then
		lowerScaleNoteAction(6)
	end

	if inputCharacter == inputCharacters["M"] then
		lowerScaleNoteAction(7)
	end

-----------------


	local function shiftKeyIsHeldDown()
		return gfx.mouse_cap & 8 == 8
	end

	local function controlKeyIsHeldDown()
		return gfx.mouse_cap & 32 == 32 
	end

	local function optionKeyIsHeldDown()
		return gfx.mouse_cap & 16 == 16
	end

	local function commandKeyIsHeldDown()
		return gfx.mouse_cap & 4 == 4
	end

	--

	local function shiftKeyIsNotHeldDown()
		return gfx.mouse_cap & 8 ~= 8
	end

	local function controlKeyIsNotHeldDown()
		return gfx.mouse_cap & 32 ~= 32
	end

	local function optionKeyIsNotHeldDown()
		return gfx.mouse_cap & 16 ~= 16
	end

	local function commandKeyIsNotHeldDown()
		return gfx.mouse_cap & 4 ~= 4
	end

	--

	local function controlModifierIsActive()
		return controlKeyIsHeldDown() and optionKeyIsNotHeldDown() and commandKeyIsNotHeldDown()
	end

	local function optionModifierIsActive()
		return optionKeyIsHeldDown() and controlKeyIsNotHeldDown() and commandKeyIsNotHeldDown()
	end

	local function commandModifierIsActive()
		return commandKeyIsHeldDown() and optionKeyIsNotHeldDown() and controlKeyIsNotHeldDown()
	end

---

	if inputCharacter == inputCharacters[","] and controlModifierIsActive() then
		decrementScaleTonicNoteAction()
	end

	if inputCharacter == inputCharacters["."] and controlModifierIsActive() then
		incrementScaleTonicNoteAction()
	end


	if operatingSystem == "win64" or operatingSystem == "win32" then

		if inputCharacter == inputCharacters[","] and shiftKeyIsNotHeldDown() and optionModifierIsActive() then
			halveGridSize()
		end

		if inputCharacter == inputCharacters["."] and shiftKeyIsNotHeldDown() and optionModifierIsActive() then
			doubleGridSize()
		end

		if inputCharacter == inputCharacters[","] and shiftKeyIsHeldDown() and optionModifierIsActive() then
			decrementOctaveAction()
		end

		if inputCharacter == inputCharacters["."] and shiftKeyIsHeldDown() and optionModifierIsActive() then
			incrementOctaveAction()
		end

		--

		if inputCharacter == inputCharacters[","] and shiftKeyIsNotHeldDown() and commandModifierIsActive() then
			decrementChordTypeAction()
		end

		if inputCharacter == inputCharacters["."] and shiftKeyIsNotHeldDown() and commandModifierIsActive() then
			incrementChordTypeAction()
		end

		if inputCharacter == inputCharacters[","] and shiftKeyIsHeldDown() and commandModifierIsActive() then
			decrementChordInversionAction()
		end

		if inputCharacter == inputCharacters["."] and shiftKeyIsHeldDown() and commandModifierIsActive() then
			incrementChordInversionAction()
		end

	else

		if inputCharacter == inputCharacters[","] and optionModifierIsActive() then
			halveGridSize()
		end

		if inputCharacter == inputCharacters["."] and optionModifierIsActive() then
			doubleGridSize()
		end

		if inputCharacter == inputCharacters["<"] and optionModifierIsActive() then
			decrementOctaveAction()
		end

		if inputCharacter == inputCharacters[">"] and optionModifierIsActive() then
			incrementOctaveAction()
		end

		--

		if inputCharacter == inputCharacters[","] and commandModifierIsActive() then
			decrementChordTypeAction()
		end

		if inputCharacter == inputCharacters["."] and commandModifierIsActive() then
			incrementChordTypeAction()
		end

		if inputCharacter == inputCharacters["<"] and commandModifierIsActive() then
			decrementChordInversionAction()
		end

		if inputCharacter == inputCharacters[">"] and commandModifierIsActive() then
			incrementChordInversionAction()
		end
	end
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

Interface = {}
Interface.__index = Interface

local dockerXPadding = 0
local dockerYPadding = 0

function Interface:init(name)

  local self = {}
  setmetatable(self, Interface)

  self.name = name
  self.x = getInterfaceXPosition()
  self.y = getInterfaceYPosition()
  self.width = interfaceWidth
  self.height = interfaceHeight

  self.elements = {}

  return self
end

function Interface:restartGui()
	self.elements = {}
	self:startGui()
end

local function getDockerXPadding()

	if gfx.w <= interfaceWidth then
		return 0
	end

	return (gfx.w - interfaceWidth) / 2
end

function Interface:startGui()

  if not self.guiInitialized then
    self:addMainWindow()
    self.guiInitialized = true
  end

  -- Use the complete current window or docker area.  Do not call gfx.init()
  -- again while rebuilding elements after a resize: doing so would snap the
  -- window back to its previous dimensions.
  self.width = gfx.w
  self.height = gfx.h
  currentWidth = gfx.w
  currentHeight = gfx.h
  dockerXPadding = 0

  self:addDocker()
  self:addTopFrame()
  self:addBottomFrame()
end

function Interface:addMainWindow()

	gfx.clear = reaper.ColorToNative(36, 36, 36)

	local dockState = 0

  if windowShouldBeDocked() then
    dockState = getDockState()
  end
  
	gfx.init(self.name, self.width, self.height, dockState, self.x, self.y)
end

function Interface:addDocker()

	local docker = Docker:new()
	table.insert(self.elements, docker)
end

function Interface:addChordButton(buttonText, x, y, width, height, scaleNoteIndex, chordTypeIndex, chordIsInScale)

	local chordButton = ChordButton:new(buttonText, x, y, width, height, scaleNoteIndex, chordTypeIndex, chordIsInScale)
	table.insert(self.elements, chordButton)
end

function Interface:addHeader(headerText, x, y, width, height, getTextCallback)

  -- Header:new() accepts geometry plus a text callback.  The original wrapper
  -- accidentally forwarded the unused headerText placeholder as the x value.
  local header = Header:new(x, y, width, height, getTextCallback)
  table.insert(self.elements, header)
end

function Interface:addFrame(x, y, width, height)

	local frame = Frame:new(x, y, width, height)
	table.insert(self.elements, frame)
end

function Interface:addLabel(x, y, width, height, getTextCallback)

	local label = Label:new(x, y, width, height, getTextCallback)
	table.insert(self.elements, label)
end

function Interface:addDropdown(x, y, width, height, options, defaultOptionIndex, onSelectionCallback)

	local dropdown = Dropdown:new(x, y, width, height, options, defaultOptionIndex, onSelectionCallback)
	table.insert(self.elements, dropdown)
end

function Interface:addChordInversionValueBox(x, y, width, height)

	local valueBox = ChordInversionValueBox:new(x, y, width, height)
	table.insert(self.elements, valueBox)
end

function Interface:addOctaveValueBox(x, y, width, height)

	local valueBox = OctaveValueBox:new(x, y, width, height)
	table.insert(self.elements, valueBox)
end

function Interface:updateElements()

	for _, element in pairs(self.elements) do
		element:update()
	end
end

function Interface:update()

	self:updateElements()
	gfx.update()

	if not mouseButtonIsNotPressedDown and leftMouseButtonIsNotHeldDown() then
		mouseButtonIsNotPressedDown = true
	end

  if scaleTonicOption ~= getScaleTonicOption() then
    scaleTonicOption = getScaleTonicOption()
    updateScaleData()
    self:restartGui()
  end

	if scaleType ~= getScaleType() then
		scaleType = getScaleType()
		updateScaleData()
		self:restartGui()
	end

  if voiceLeadingMode ~= getVoiceLeadingMode() then
    voiceLeadingMode = getVoiceLeadingMode()
    self:restartGui()
  end

  if voicingMode ~= getVoicingMode() then
    voicingMode = getVoicingMode()
    self:restartGui()
  end

  if currentWidth ~= gfx.w or currentHeight ~= gfx.h then
    self:restartGui()
  end

	if guiShouldBeUpdated then
		
		self:restartGui()
		guiShouldBeUpdated = false
	end

  if windowIsDocked() and (getDockState() ~= gfx.dock(-1)) then
    setDockState(gfx.dock(-1))
  end

	local _, xpos, ypos, _, _ = gfx.dock(-1,0,0,0,0)
	setInterfaceXPosition(xpos)
	setInterfaceYPosition(ypos)

end

local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

scaleNames = {"Chromatic"}

local xMargin = 8
local yMargin = 8
local xPadding = 10
local horizontalMargin = 7

local rootLabelWidth = 34
local rootDropdownWidth = 52
local scaleLabelWidth = 38
local scaleTypeWidth = 90
local octaveLabelWidth = 48
local octaveValueBoxWidth = 48

keySelectionFrameHeight = 48

function Interface:addTopFrame()
  self:addFrame(xMargin, yMargin, self.width - 2 * xMargin, keySelectionFrameHeight)
  self:addScaleLabel()
  self:addScaleTonicNoteDropdown()
  self:addScaleTypeDropdown()
  self:addOctaveLabel()
  self:addOctaveSelectorValueBox()
  self:addScaleNotesTextLabel()
end

function Interface:addScaleLabel()
  local labelX = xMargin + xPadding
  local labelY = yMargin + 5
  self:addLabel(labelX, labelY, rootLabelWidth, 17, function() return "Root:" end)
end

function Interface:addScaleTonicNoteDropdown()
  local x = xMargin + xPadding + rootLabelWidth
  local y = yMargin + 6

  local onSelection = function(index)
    setScaleTonicOption(index)
    setSelectedScaleNote(1)
    setChordText("")
    resetSelectedChordTypes()
    resetChordInversionStates()
    updateScaleData()
  end

  self:addDropdown(x, y, rootDropdownWidth, 15, getTonicOptionNames(), getScaleTonicOption(), onSelection)
end

function Interface:addScaleTypeDropdown()
  local labelX = xMargin + xPadding + rootLabelWidth + rootDropdownWidth + horizontalMargin
  local y = yMargin + 5
  self:addLabel(labelX, y, scaleLabelWidth, 17, function() return "Scale:" end)

  local x = labelX + scaleLabelWidth
  self:addDropdown(x, y + 1, scaleTypeWidth, 15, scaleNames, 1, function() setScaleType(1) end)
end

function Interface:addScaleNotesTextLabel()
  local x = xMargin + xPadding
  local y = yMargin + 27
  local width = self.width - 2 * xMargin - 2 * xPadding
  self:addLabel(x, y, width, 15, function() return getScaleNotesText() end)
end

function Interface:addOctaveLabel()
  local x = self.width - xMargin - xPadding - octaveValueBoxWidth - octaveLabelWidth
  local y = yMargin + 5
  self:addLabel(x, y, octaveLabelWidth, 17, function() return "Octave:" end)
end

function Interface:addOctaveSelectorValueBox()
  local x = self.width - xMargin - xPadding - octaveValueBoxWidth
  local y = yMargin + 6
  self:addOctaveValueBox(x, y, octaveValueBoxWidth, 15)
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"

local xMargin = 8
local yMargin = 8 + keySelectionFrameHeight + 6
local xPadding = 7
local controlRowHeight = 28
local headerHeight = 34
local innerSpacing = 2

local voiceLeadingLabelWidth = 22
local voiceLeadingDropdownWidth = 104
local voicingLabelWidth = 48
local voicingDropdownWidth = 104
local inversionLabelWidth = 30
local inversionValueBoxWidth = 48
local controlsSpacing = 5
local chordTextWidth = nil

local function clamp(value, minimum, maximum)
  if value < minimum then return minimum end
  if value > maximum then return maximum end
  return value
end

local function getGridGeometry(interface)
  local numberOfColumns = 12
  local contentX = xMargin + xPadding
  local contentWidth = interface.width - 2 * xMargin - 2 * xPadding
  local columnWidth = (contentWidth - innerSpacing * (numberOfColumns - 1)) / numberOfColumns
  local headerY = yMargin + controlRowHeight + 2
  local buttonsY = headerY + headerHeight + innerSpacing
  local availableHeight = interface.height - buttonsY - 8
  local rowHeight = math.floor((availableHeight - innerSpacing * (#chords - 1)) / #chords)
  rowHeight = clamp(rowHeight, 16, 32)

  return contentX, columnWidth, headerY, buttonsY, rowHeight
end

function Interface:addBottomFrame()
  local frameHeight = self.height - yMargin - 6
  self:addFrame(xMargin, yMargin, self.width - 2 * xMargin, frameHeight)

  self:addChordTextLabel()
  self:addVoiceLeadingLabel()
  self:addVoiceLeadingDropdown()
  self:addVoicingLabel()
  self:addVoicingDropdown()
  self:addInversionLabel()
  self:addInversionValueBox()

  self:addHeaders()
  self:addChordButtons()
end

local function fixedControlsWidth()
  return voiceLeadingLabelWidth
    + voiceLeadingDropdownWidth
    + voicingLabelWidth
    + voicingDropdownWidth
    + inversionLabelWidth
    + inversionValueBoxWidth
    + controlsSpacing * 5
end

function Interface:addChordTextLabel()
  local x = xMargin + xPadding
  local y = yMargin + 2
  chordTextWidth = math.max(70, self.width - 2 * xMargin - 2 * xPadding - fixedControlsWidth())
  self:addLabel(x, y, chordTextWidth, 24, function() return getChordText() end)
end

function Interface:addVoiceLeadingLabel()
  local x = xMargin + xPadding + chordTextWidth
  self:addLabel(x, yMargin + 2, voiceLeadingLabelWidth, 24, function() return "VL:" end)
end

function Interface:addVoiceLeadingDropdown()
  local x = xMargin + xPadding + chordTextWidth + voiceLeadingLabelWidth
  local onSelection = function(index)
    setVoiceLeadingMode(index)
    previewScaleChord()
  end
  self:addDropdown(x, yMargin + 7, voiceLeadingDropdownWidth, 15, getVoiceLeadingModeOptions(), getVoiceLeadingMode(), onSelection)
end

function Interface:addVoicingLabel()
  local x = xMargin + xPadding + chordTextWidth + voiceLeadingLabelWidth + voiceLeadingDropdownWidth + controlsSpacing
  self:addLabel(x, yMargin + 2, voicingLabelWidth, 24, function() return "Voicing:" end)
end

function Interface:addVoicingDropdown()
  local x = xMargin + xPadding + chordTextWidth + voiceLeadingLabelWidth + voiceLeadingDropdownWidth
    + controlsSpacing + voicingLabelWidth
  local onSelection = function(index)
    setVoicingMode(index)
    previewScaleChord()
  end
  self:addDropdown(x, yMargin + 7, voicingDropdownWidth, 15, getVoicingModeOptions(), getVoicingMode(), onSelection)
end

function Interface:addInversionLabel()
  local x = xMargin + xPadding + chordTextWidth + voiceLeadingLabelWidth + voiceLeadingDropdownWidth
    + voicingLabelWidth + voicingDropdownWidth + controlsSpacing * 2
  self:addLabel(x, yMargin + 2, inversionLabelWidth, 24, function() return "Inv:" end)
end

function Interface:addInversionValueBox()
  local x = xMargin + xPadding + chordTextWidth + voiceLeadingLabelWidth + voiceLeadingDropdownWidth
    + voicingLabelWidth + voicingDropdownWidth + inversionLabelWidth + controlsSpacing * 2
  self:addChordInversionValueBox(x, yMargin + 7, inversionValueBoxWidth, 15)
end

function Interface:addHeaders()
  local contentX, columnWidth, headerY = getGridGeometry(self)

  for i = 1, #scaleNotes do
    local index = i
    local x = contentX + (columnWidth + innerSpacing) * (i - 1)
    self:addHeader("", x, headerY, columnWidth, headerHeight, function()
      return getScaleDegreeHeader(index) .. "\n" .. getScaleNoteName(index)
    end)
  end
end

local function getCompactChordLabel(chord)
  if chord.display == "" then
    return "maj"
  end
  return chord.display
end

function Interface:addChordButtons()
  local contentX, columnWidth, _, buttonsY, rowHeight = getGridGeometry(self)

  for scaleNoteIndex = 1, #scaleNotes do
    for chordTypeIndex, chord in ipairs(scaleChords[scaleNoteIndex]) do
      local x = contentX + (columnWidth + innerSpacing) * (scaleNoteIndex - 1)
      local y = buttonsY + (rowHeight + innerSpacing) * (chordTypeIndex - 1)
      self:addChordButton(
        getCompactChordLabel(chord),
        x,
        y,
        columnWidth,
        rowHeight,
        scaleNoteIndex,
        chordTypeIndex,
        true
      )
    end
  end
end
local workingDirectory = reaper.GetResourcePath() .. "/Scripts/ChordGun/src"


--clearConsoleWindow()
updateScaleData()

local interface = Interface:init("ChordGun")
interface:startGui()

local function windowHasNotBeenClosed()
	return inputCharacter ~= -1
end

local function main()

	handleInput()

	if windowHasNotBeenClosed() then
		reaper.runloop(main)
	end
	
	interface:update()
end

main()


-- If you want the ChordGun window to always be on top then do the following things:
--
-- 1. install julian sader extension https://forum.cockos.com/showthread.php?t=212174
--
-- 2. uncomment the following code:
--
-- 		if (reaper.JS_Window_Find) then
-- 			local hwnd = reaper.JS_Window_Find("ChordGun", true)
-- 			reaper.JS_Window_SetZOrder(hwnd, "TOPMOST", hwnd)
-- 		end
--
--
--
-- Note that this only works on Windows machines
