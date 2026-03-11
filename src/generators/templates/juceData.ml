(*
   The MIT License (MIT)

   Copyright (c) 2014 Leonardo Laguna Ruiz

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*)

(** Pure-string helpers for the JUCE template.
    This file is excluded from pla.ppx to avoid tokenizer issues with ocamldep. *)

let q = String.make 1 '"'
let a s = q ^ s ^ q
let nl = "\n"
let cat = String.concat nl

let make_id (seed:string) (prefix:string) : string =
  let h = Hashtbl.hash (seed ^ prefix) in
  Printf.sprintf "%06x" (h land 0xFFFFFF)
;;

let make_plugin_code (seed:string) : string =
  let h = Hashtbl.hash seed in
  let c1 = 65 + (h mod 26) in
  let c2 = 97 + ((h / 26) mod 26) in
  let c3 = 97 + ((h / 676) mod 26) in
  let c4 = 97 + ((h / 17576) mod 26) in
  Printf.sprintf "0x%02x%02x%02x%02x" c1 c2 c3 c4
;;

let jucerFileStr (output : string) : string =
   let p_id = make_id output "proj" in
   let mg_id = make_id output "maingroup" in
   let g_id = "{" ^ make_id output "g1" ^ "-" ^ make_id output "g2" ^ "-" ^ make_id output "g3" ^ "-0000-000000000000}" in
   let f1_id = make_id output "f1" in
   let f2_id = make_id output "f2" in
   let f5_id = make_id output "f5" in
   let f6_id = make_id output "f6" in
   let f7_id = make_id output "f7" in
   let f8_id = make_id output "f8" in
   let f9_id = make_id output "f9" in
   let module_ids =
     [ "juce_audio_basics"
     ; "juce_audio_devices"
     ; "juce_audio_formats"
     ; "juce_audio_plugin_client"
     ; "juce_audio_processors"
     ; "juce_audio_processors_headless"  (* Required by juce_audio_processors in JUCE 8 *)
     ; "juce_audio_utils"
     ; "juce_core"
     ; "juce_data_structures"
     ; "juce_events"
     ; "juce_graphics"
     ; "juce_gui_basics"
     ; "juce_gui_extra"
     ]
   in
   (* Use global path for modules - let user configure in Projucer *)
   let module_paths =
     List.map (fun id -> "        <MODULEPATH id=" ^ a id ^ " path=" ^ a "" ^ " useGlobalPath=" ^ a "1" ^ "/>") module_ids
     |> cat
   in
   let module_elems =
     List.map (fun id -> "    <MODULE id=" ^ a id ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>") module_ids
     |> cat
   in
   cat
      [ "<?xml version=" ^ a "1.0" ^ " encoding=" ^ a "UTF-8" ^ "?>"
      ; "<JUCERPROJECT id=" ^ a p_id ^ " name=" ^ a output ^ " projectType=" ^ a "audioplug" ^ " useAppConfig=" ^ a "0" ^ ""
      ; "              addUsingNamespaceToJuceHeader=" ^ a "0" ^ " jucerFormatVersion=" ^ a "1" ^ " buildVST3=" ^ a "1" ^ ""
      ; "              buildAU=" ^ a "1" ^ " buildStandalone=" ^ a "1" ^ " pluginName=" ^ a output ^ " pluginDesc=" ^ a output ^ ""
      ; "              pluginManufacturer=" ^ a "yourcompany" ^ " pluginManufacturerCode=" ^ a "Vult" ^ ""
      ; "              pluginCode=" ^ a (make_plugin_code output) ^ " pluginChannelConfigs=" ^ a "" ^ ""
      ; "              pluginIsSynth=" ^ a "1" ^ " pluginWantsMidiIn=" ^ a "1" ^ " pluginProducesMidiOut=" ^ a "0" ^ ""
      ; "              pluginIsMidiEffectPlugin=" ^ a "0" ^ " pluginEditorRequiresKeys=" ^ a "0" ^ ""
      ; "              pluginAUExportPrefix=" ^ a (output ^ "AU") ^ " pluginRTASCategory=" ^ a "" ^ ""
      ; "              pluginAAXCategory=" ^ a "2" ^ " pluginVSTCategory=" ^ a "kPlugCategSynth" ^ ""
      ; "              pluginVST3Category=" ^ a "Instrument|Synth" ^ " jucerCoreVersion=" ^ a "1" ^ " companyName=" ^ a "yourcompany" ^ ">"
      ; "  <MAINGROUP id=" ^ a mg_id ^ " name=" ^ a output ^ ">"
      ; "    <GROUP id=" ^ a g_id ^ " name=" ^ a "Source" ^ ">"
      ; "      <FILE id=" ^ a f1_id ^ " name=" ^ a "PluginProcessor.cpp" ^ " compile=" ^ a "1" ^ " resource=" ^ a "0" ^ ""
      ; "            file=" ^ a "Source/PluginProcessor.cpp" ^ "/>"
      ; "      <FILE id=" ^ a f2_id ^ " name=" ^ a "PluginProcessor.h" ^ " compile=" ^ a "0" ^ " resource=" ^ a "0" ^ ""
      ; "            file=" ^ a "Source/PluginProcessor.h" ^ "/>"
      ; "      <FILE id=" ^ a f5_id ^ " name=" ^ a (output ^ ".cpp") ^ " compile=" ^ a "1" ^ " resource=" ^ a "0" ^ " file=" ^ a (output ^ ".cpp") ^ "/>"
      ; "      <FILE id=" ^ a f6_id ^ " name=" ^ a (output ^ ".h") ^ " compile=" ^ a "0" ^ " resource=" ^ a "0" ^ " file=" ^ a (output ^ ".h") ^ "/>"
      ; "      <FILE id=" ^ a f7_id ^ " name=" ^ a (output ^ ".tables.h") ^ " compile=" ^ a "0" ^ " resource=" ^ a "0" ^ ""
      ; "            file=" ^ a (output ^ ".tables.h") ^ "/>"
      ; "      <FILE id=" ^ a f8_id ^ " name=" ^ a "vultin.cpp" ^ " compile=" ^ a "1" ^ " resource=" ^ a "0" ^ " file=" ^ a "vultin.cpp" ^ "/>"
      ; "      <FILE id=" ^ a f9_id ^ " name=" ^ a "vultin.h" ^ " compile=" ^ a "0" ^ " resource=" ^ a "0" ^ " file=" ^ a "vultin.h" ^ "/>"
      ; "    </GROUP>"
      ; "  </MAINGROUP>"
      ; "  <MODULES>"
      ; module_elems
      ; "  </MODULES>"
      ; "  <JUCEOPTIONS JUCE_STRICT_REFCOUNTEDPOINTER=" ^ a "1" ^ " JUCE_VST3_CAN_REPLACE_VST2=" ^ a "0" ^ "/>"
      ; "  <EXPORTFORMATS>"
      ; "    <XCODE_MAC targetFolder=" ^ a "Builds/MacOSX" ^ ">"
      ; "      <CONFIGURATIONS>"
      ; "        <CONFIGURATION isDebug=" ^ a "1" ^ " name=" ^ a "Debug" ^ " targetName=" ^ a output ^ "/>"
      ; "        <CONFIGURATION isDebug=" ^ a "0" ^ " name=" ^ a "Release" ^ " targetName=" ^ a output ^ "/>"
      ; "      </CONFIGURATIONS>"
      ; "      <MODULEPATHS>"
      ; module_paths
      ; "      </MODULEPATHS>"
      ; "    </XCODE_MAC>"
      ; "    <VS2022 targetFolder=" ^ a "Builds/VisualStudio2022" ^ ">"
      ; "      <CONFIGURATIONS>"
      ; "        <CONFIGURATION isDebug=" ^ a "1" ^ " name=" ^ a "Debug" ^ "/>"
      ; "        <CONFIGURATION isDebug=" ^ a "0" ^ " name=" ^ a "Release" ^ "/>"
      ; "      </CONFIGURATIONS>"
      ; "      <MODULEPATHS>"
      ; module_paths
      ; "      </MODULEPATHS>"
      ; "    </VS2022>"
      ; "    <LINUX_MAKE targetFolder=" ^ a "Builds/LinuxMakefile" ^ ">"
      ; "      <CONFIGURATIONS>"
      ; "        <CONFIGURATION isDebug=" ^ a "1" ^ " name=" ^ a "Debug" ^ "/>"
      ; "        <CONFIGURATION isDebug=" ^ a "0" ^ " name=" ^ a "Release" ^ "/>"
      ; "      </CONFIGURATIONS>"
      ; "      <MODULEPATHS>"
      ; module_paths
      ; "      </MODULEPATHS>"
      ; "    </LINUX_MAKE>"
      ; "  </EXPORTFORMATS>"
      ; "</JUCERPROJECT>"
      ]
;;

let jucerHeaderStr (output : string) : string =
   cat
      [ "/*"
      ; "    IMPORTANT! This file is auto-generated."
      ; "*/"
      ; ""
      ; "#pragma once"
      ; "#include " ^ a "JucePluginDefines.h"
      ; "#include <juce_audio_basics/juce_audio_basics.h>"
      ; "#include <juce_audio_devices/juce_audio_devices.h>"
      ; "#include <juce_audio_formats/juce_audio_formats.h>"
      ; "#include <juce_audio_plugin_client/juce_audio_plugin_client.h>"
      ; "#include <juce_audio_processors/juce_audio_processors.h>"
      ; "#include <juce_audio_utils/juce_audio_utils.h>"
      ; "#include <juce_core/juce_core.h>"
      ; "#include <juce_data_structures/juce_data_structures.h>"
      ; "#include <juce_events/juce_events.h>"
      ; "#include <juce_graphics/juce_graphics.h>"
      ; "#include <juce_gui_basics/juce_gui_basics.h>"
      ; "#include <juce_gui_extra/juce_gui_extra.h>"
      ; ""
      ; "#if ! JUCE_DONT_DECLARE_PROJECTINFO"
      ; "namespace ProjectInfo"
      ; "{"
      ; "    const char* const  projectName    = " ^ a output ^ ";"
      ; "    const char* const  companyName    = " ^ a "" ^ ";"
      ; "    const char* const  versionString  = " ^ a "1.0.0" ^ ";"
      ; "    const int          versionNumber  = 0x10000;"
      ; "}"
      ; "#endif"
      ]
;;

let jucerPluginDefinesStr (output : string) : string =
   cat
      [ "/* IMPORTANT! This file is auto-generated. */"
      ; "#pragma once"
      ; ""
      ; "#ifndef  JucePlugin_Build_VST3"
      ; " #define JucePlugin_Build_VST3             1"
      ; "#endif"
      ; "#ifndef  JucePlugin_Build_AU"
      ; " #define JucePlugin_Build_AU               1"
      ; "#endif"
      ; "#ifndef  JucePlugin_Build_Standalone"
      ; " #define JucePlugin_Build_Standalone       1"
      ; "#endif"
      ; "#ifndef  JucePlugin_Name"
      ; " #define JucePlugin_Name                   " ^ a output
      ; "#endif"
      ; "#ifndef  JucePlugin_Desc"
      ; " #define JucePlugin_Desc                   " ^ a output
      ; "#endif"
      ; "#ifndef  JucePlugin_Manufacturer"
      ; " #define JucePlugin_Manufacturer           " ^ a "yourcompany"
      ; "#endif"
      ; "#ifndef  JucePlugin_ManufacturerCode"
      ; " #define JucePlugin_ManufacturerCode       0x56756c74"
      ; "#endif"
      ; "#ifndef  JucePlugin_PluginCode"
      ; " #define JucePlugin_PluginCode             " ^ make_plugin_code output
      ; "#endif"
      ; "#ifndef  JucePlugin_IsSynth"
      ; " #define JucePlugin_IsSynth                1"
      ; "#endif"
      ; "#ifndef  JucePlugin_WantsMidiInput"
      ; " #define JucePlugin_WantsMidiInput         1"
      ; "#endif"
      ; "#ifndef  JucePlugin_ProducesMidiOutput"
      ; " #define JucePlugin_ProducesMidiOutput     0"
      ; "#endif"
      ; "#ifndef  JucePlugin_IsMidiEffect"
      ; " #define JucePlugin_IsMidiEffect           0"
      ; "#endif"
      ; "#ifndef  JucePlugin_Version"
      ; " #define JucePlugin_Version                1.0.0"
      ; "#endif"
      ; "#ifndef  JucePlugin_VersionCode"
      ; " #define JucePlugin_VersionCode            0x10000"
      ; "#endif"
      ; "#ifndef  JucePlugin_VersionString"
      ; " #define JucePlugin_VersionString          " ^ a "1.0.0"
      ; "#endif"
      ; "#ifndef  JucePlugin_Vst3Category"
      ; " #define JucePlugin_Vst3Category           " ^ a "Instrument|Synth"
      ; "#endif"
      ; "#ifndef  JucePlugin_AUMainType"
      ; " #define JucePlugin_AUMainType             'aumu'"
      ; "#endif"
      ; "#ifndef  JucePlugin_AUSubType"
      ; " #define JucePlugin_AUSubType              JucePlugin_PluginCode"
      ; "#endif"
      ; "#ifndef  JucePlugin_AUExportPrefix"
      ; " #define JucePlugin_AUExportPrefix         " ^ output ^ "AU"
      ; "#endif"
      ; "#ifndef  JucePlugin_AUExportPrefixQuoted"
      ; " #define JucePlugin_AUExportPrefixQuoted   " ^ a (output ^ "AU")
      ; "#endif"
      ; "#ifndef  JucePlugin_CFBundleIdentifier"
      ; " #define JucePlugin_CFBundleIdentifier     com.yourcompany." ^ output
      ; "#endif"
      ; "#ifndef  JucePlugin_VSTNumMidiInputs"
      ; " #define JucePlugin_VSTNumMidiInputs       16"
      ; "#endif"
      ; "#ifndef  JucePlugin_VSTNumMidiOutputs"
      ; " #define JucePlugin_VSTNumMidiOutputs      16"
      ; "#endif"
      ]
;;

(* --- PluginProcessor.h --- *)
let processorHeaderStr (output : string) (cc_params : (int * string) list) (module_name : string) (has_ctx : bool) : string =
   (* Use {} to value-initialize the context struct to zero *)
   let ctx_decl = if has_ctx then "    " ^ module_name ^ "_process_type process_ctx{};" else "" in
   (* Generate APVTS if we have CC params *)
   let has_params = List.length cc_params > 0 in
   let apvts_decl = if has_params then
      cat [
         "    juce::AudioProcessorValueTreeState parameters;"
         ; "    juce::AudioProcessorValueTreeState::ParameterLayout createParameterLayout();"
      ]
   else "" in
   cat
      [ "#pragma once"
      ; ""
      ; "#include <juce_audio_processors/juce_audio_processors.h>"
      ; "#include " ^ a ("../" ^ output ^ ".h")
      ; ""
      ; "class " ^ output ^ "AudioProcessor : public juce::AudioProcessor"
      ; "{"
      ; "public:"
      ; "    " ^ output ^ "AudioProcessor();"
      ; "    ~" ^ output ^ "AudioProcessor() override;"
      ; ""
      ; "    void prepareToPlay (double sampleRate, int samplesPerBlock) override;"
      ; "    void releaseResources() override;"
      ; ""
      ; "    bool isBusesLayoutSupported (const juce::AudioProcessor::BusesLayout& layouts) const override;"
      ; ""
      ; "    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;"
      ; ""
      ; "    juce::AudioProcessorEditor* createEditor() override;"
      ; "    bool hasEditor() const override;"
      ; ""
      ; "    const juce::String getName() const override;"
      ; ""
      ; "    bool acceptsMidi() const override;"
      ; "    bool producesMidi() const override;"
      ; "    bool isMidiEffect() const override;"
      ; "    double getTailLengthSeconds() const override;"
      ; ""
      ; "    int getNumPrograms() override;"
      ; "    int getCurrentProgram() override;"
      ; "    void setCurrentProgram (int index) override;"
      ; "    const juce::String getProgramName (int index) override;"
      ; "    void changeProgramName (int index, const juce::String& newName) override;"
      ; ""
      ; "    void getStateInformation (juce::MemoryBlock& destData) override;"
      ; "    void setStateInformation (const void* data, int sizeInBytes) override;"
      ; ""
      ; "private:"
      ; "    void initDsp();"
      ; "    void prewarmDsp(int numSamples);"
      ; ctx_decl
      ; "    bool dspInitialized = false;"
      ; apvts_decl
      ; ""
      ; "    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (" ^ output ^ "AudioProcessor)"
      ; "};"
      ]
;;

(* --- PluginProcessor.cpp --- *)
let processorImplStr (output : string) (cc_params : (int * string) list) (num_inputs : int) (num_outputs : int)
   (module_name : string) (process_call : string) (_input_gets : string) (_output_sets : string)
   (_impl_code_str : string) (has_ctx : bool) : string =
   let has_params = List.length cc_params > 0 in
   
   (* Generate parameter layout function if we have CC params *)
   let param_layout_func = if has_params then
      let param_adds = List.map (fun (cc, name) ->
         "        layout.add(std::make_unique<juce::AudioParameterFloat>(" ^
         a ("cc" ^ string_of_int cc) ^ ", " ^ a name ^ ", 0.0f, 1.0f, 0.5f));"
      ) cc_params |> cat in
      cat [
         "juce::AudioProcessorValueTreeState::ParameterLayout " ^ output ^ "AudioProcessor::createParameterLayout()"
         ; "{"
         ; "    juce::AudioProcessorValueTreeState::ParameterLayout layout;"
         ; param_adds
         ; "    return layout;"
         ; "}"
      ]
   else ""
   in
   
   (* Generate parameter sync code - read APVTS params and send as CC *)
   let param_sync = if has_params && has_ctx then
      let sync_lines = List.map (fun (cc, _name) ->
         "        { float v = *parameters.getRawParameterValue(" ^ a ("cc" ^ string_of_int cc) ^ "); " ^
         module_name ^ "_controlChange(process_ctx, " ^ string_of_int cc ^ ", (int)(v * 127.0f), 0); }"
      ) cc_params |> cat in
      cat [
         "    // Sync APVTS parameters to DSP via controlChange"
         ; sync_lines
      ]
   else ""
   in
   
   (* DSP init helper function - called from prepareToPlay *)
   let init_dsp_func = if has_ctx then
      cat [
         "void " ^ output ^ "AudioProcessor::initDsp()"
         ; "{"
         ; "    DBG(\"[VULT] initDsp called, sample rate = \" << vult_sample_rate);"
         ; "    // Zero the entire context first - Vult init doesn't clear delay buffers"
         ; "    std::memset(&process_ctx, 0, sizeof(process_ctx));"
         ; "    " ^ module_name ^ "_process_init(process_ctx);"
         ; "    " ^ module_name ^ "_default(process_ctx);"
         ; "    // Prewarm DSP to stabilize filters"
         ; "    prewarmDsp(256);"
         ; "    dspInitialized = true;"
         ; "    DBG(\"[VULT] initDsp complete\");"
         ; "}"
      ]
   else
      cat [
         "void " ^ output ^ "AudioProcessor::initDsp()"
         ; "{"
         ; "    dspInitialized = true;"
         ; "}"
      ]
   in
   
   (* Prewarm function - run DSP with silence to stabilize filters *)
   let prewarm_func = if has_ctx then
      cat [
         "void " ^ output ^ "AudioProcessor::prewarmDsp(int numSamples)"
         ; "{"
         ; "    for (int i = 0; i < numSamples; i++)"
         ; "    {"
         ; "        " ^ module_name ^ "_process(process_ctx, 0.0f);"
         ; "    }"
         ; "}"
      ]
   else
      cat [
         "void " ^ output ^ "AudioProcessor::prewarmDsp(int) {}"
      ]
   in
   
   let midi_handler = if has_ctx then
      cat [
         "    // Process MIDI messages"
         ; "    for (const auto metadata : midiMessages)"
         ; "    {"
         ; "        auto message = metadata.getMessage();"
         ; "        if (message.isNoteOn())"
         ; "        {"
         ; "            " ^ module_name ^ "_noteOn(process_ctx, message.getNoteNumber(), message.getVelocity(), message.getChannel());"
         ; "        }"
         ; "        else if (message.isNoteOff())"
         ; "        {"
         ; "            " ^ module_name ^ "_noteOff(process_ctx, message.getNoteNumber(), message.getChannel());"
         ; "        }"
         ; "        else if (message.isController())"
         ; "        {"
         ; "            " ^ module_name ^ "_controlChange(process_ctx, message.getControllerNumber(), message.getControllerValue(), message.getChannel());"
         ; "        }"
         ; "    }"
      ]
   else "    (void)midiMessages;"
   in
   (* For stereo output, we need to handle L/R channels properly *)
   let stereo_output = num_outputs >= 2 in
   let process_loop = if stereo_output then
      cat [
         "    auto* leftChannel = buffer.getWritePointer(0);"
         ; "    auto* rightChannel = buffer.getNumChannels() > 1 ? buffer.getWritePointer(1) : leftChannel;"
         ; "    auto* inputChannel = buffer.getReadPointer(0);"
         ; ""
         ; "    for (int j = 0; j < buffer.getNumSamples(); j++)"
         ; "    {"
         ; "        " ^ process_call
         ; "        leftChannel[j] = " ^ module_name ^ "_process_ret_0(process_ctx);"
         ; "        rightChannel[j] = " ^ module_name ^ "_process_ret_1(process_ctx);"
         ; "    }"
      ]
   else
      cat [
         "    auto* outChannel = buffer.getWritePointer(0);"
         ; "    auto* inputChannel = buffer.getReadPointer(0);"
         ; ""
         ; "    for (int j = 0; j < buffer.getNumSamples(); j++)"
         ; "    {"
         ; "        outChannel[j] = " ^ process_call
         ; "    }"
      ]
   in
   
   (* Constructor - with or without APVTS *)
   let constructor_body = if has_params then
      cat [
         output ^ "AudioProcessor::" ^ output ^ "AudioProcessor()"
         ; "    : juce::AudioProcessor (BusesProperties()"
         ; "                            .withInput  (" ^ a "Input" ^ ",  juce::AudioChannelSet::stereo(), true)"
         ; "                            .withOutput (" ^ a "Output" ^ ", juce::AudioChannelSet::stereo(), true))"
         ; "    , parameters(*this, nullptr, juce::Identifier(" ^ a output ^ "), createParameterLayout())"
         ; "{"
         ; "}"
      ]
   else
      cat [
         output ^ "AudioProcessor::" ^ output ^ "AudioProcessor()"
         ; "    : juce::AudioProcessor (BusesProperties()"
         ; "                            .withInput  (" ^ a "Input" ^ ",  juce::AudioChannelSet::stereo(), true)"
         ; "                            .withOutput (" ^ a "Output" ^ ", juce::AudioChannelSet::stereo(), true))"
         ; "{"
         ; "}"
      ]
   in
   
   (* State save/restore - use APVTS if available *)
   let state_funcs = if has_params then
      cat [
         "void " ^ output ^ "AudioProcessor::getStateInformation (juce::MemoryBlock& destData)"
         ; "{"
         ; "    auto state = parameters.copyState();"
         ; "    std::unique_ptr<juce::XmlElement> xml(state.createXml());"
         ; "    copyXmlToBinary(*xml, destData);"
         ; "}"
         ; ""
         ; "void " ^ output ^ "AudioProcessor::setStateInformation (const void* data, int sizeInBytes)"
         ; "{"
         ; "    std::unique_ptr<juce::XmlElement> xml(getXmlFromBinary(data, sizeInBytes));"
         ; "    if (xml != nullptr && xml->hasTagName(parameters.state.getType()))"
         ; "        parameters.replaceState(juce::ValueTree::fromXml(*xml));"
         ; "}"
      ]
   else
      cat [
         "void " ^ output ^ "AudioProcessor::getStateInformation (juce::MemoryBlock&) {}"
         ; "void " ^ output ^ "AudioProcessor::setStateInformation (const void*, int) {}"
      ]
   in
   
   cat
      [ "#include " ^ a "PluginProcessor.h"
      ; ""
      ; "#include <cstring>"
      ; "#include " ^ a ("../" ^ output ^ ".h")
      ; "#include " ^ a ("../" ^ output ^ ".tables.h")
      ; ""
      ; "static double vult_sample_rate = 44100.0;"
      ; "extern " ^ a "C" ^ " {"
      ; "    float float_samplerate() { return (float)vult_sample_rate; }"
      ; "    int32_t fix_samplerate() { return (int32_t)(vult_sample_rate * 65536.0); }"
      ; "}"
      ; ""
      ; param_layout_func
      ; ""
      ; init_dsp_func
      ; ""
      ; prewarm_func
      ; ""
      ; constructor_body
      ; ""
      ; output ^ "AudioProcessor::~" ^ output ^ "AudioProcessor() {}"
      ; ""
      ; "const juce::String " ^ output ^ "AudioProcessor::getName() const { return JucePlugin_Name; }"
      ; "bool " ^ output ^ "AudioProcessor::acceptsMidi() const { return true; }"
      ; "bool " ^ output ^ "AudioProcessor::producesMidi() const { return false; }"
      ; "bool " ^ output ^ "AudioProcessor::isMidiEffect() const { return false; }"
      ; "double " ^ output ^ "AudioProcessor::getTailLengthSeconds() const { return 0.0; }"
      ; "int " ^ output ^ "AudioProcessor::getNumPrograms() { return 1; }"
      ; "int " ^ output ^ "AudioProcessor::getCurrentProgram() { return 0; }"
      ; "void " ^ output ^ "AudioProcessor::setCurrentProgram (int) {}"
      ; "const juce::String " ^ output ^ "AudioProcessor::getProgramName (int) { return {}; }"
      ; "void " ^ output ^ "AudioProcessor::changeProgramName (int, const juce::String&) {}"
      ; ""
      ; "void " ^ output ^ "AudioProcessor::prepareToPlay (double sampleRate, int)"
      ; "{"
      ; "    vult_sample_rate = sampleRate;"
      ; "    initDsp();"
      ; "}"
      ; ""
      ; "void " ^ output ^ "AudioProcessor::releaseResources() {}"
      ; ""
      ; "bool " ^ output ^ "AudioProcessor::isBusesLayoutSupported (const juce::AudioProcessor::BusesLayout& layouts) const"
      ; "{"
      ; "    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()"
      ; "     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())"
      ; "        return false;"
      ; "    return true;"
      ; "}"
      ; ""
      ; "void " ^ output ^ "AudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)"
      ; "{"
      ; "    juce::ScopedNoDenormals noDenormals;"
      ; ""
      ; "    // Ensure DSP is initialized before processing"
      ; "    if (!dspInitialized)"
      ; "    {"
      ; "        buffer.clear();"
      ; "        return;"
      ; "    }"
      ; ""
      ; "    auto totalNumInputChannels  = getTotalNumInputChannels();"
      ; "    auto totalNumOutputChannels = getTotalNumOutputChannels();"
      ; ""
      ; "    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)"
      ; "        buffer.clear (i, 0, buffer.getNumSamples());"
      ; ""
      ; param_sync
      ; ""
      ; midi_handler
      ; ""
      ; process_loop
      ; "}"
      ; ""
      ; "bool " ^ output ^ "AudioProcessor::hasEditor() const { return false; }"
      ; "juce::AudioProcessorEditor* " ^ output ^ "AudioProcessor::createEditor() { return nullptr; }"
      ; ""
      ; state_funcs
      ; ""
      ; "juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()"
      ; "{"
      ; "    return new " ^ output ^ "AudioProcessor();"
      ; "}"
      ]
;;

(* --- PluginEditor.h --- GUI-less mode, not used *)
let editorHeaderStr (_output : string) (_cc_param_names : string list) : string = ""
;;

(* --- PluginEditor.cpp --- GUI-less mode, not used *)
let editorImplStr (_output : string) (_cc_param_names : string list) : string = ""
;;

(* --- Embedded vultin.h runtime header --- *)
let vultinHeaderStr : string = {|/*

The MIT License (MIT)

Copyright (c) 2015 Leonardo Laguna Ruiz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


NOTE: The code for the fixed-point operations is based on the project:
      https://code.google.com/p/libfixmath/

*/

#ifndef VULTIN_H
#define VULTIN_H

#include <math.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef _MSC_VER
#define static_inline static __inline
#else
#define static_inline static inline
#endif

typedef int32_t fix16_t;

extern "C" float float_samplerate();
extern "C" fix16_t fix_samplerate();

// Type conversion
static_inline float fix_to_float(fix16_t a) { return (float)a / 0x00010000; }
static_inline fix16_t float_to_fix(float a) {
   float temp = a * 0x00010000;
   return (fix16_t)temp;
}

static_inline fix16_t short_to_fix(int16_t x) {
   return 0x8000 & x ? 0xFFFF0000 | x : x;
}

static_inline int16_t fix_to_short(fix16_t x) {
   return (x >= 0x00010000 ? 0x00010000 - 1 : x) / 2;
}

static_inline float short_to_float(int16_t x) { return (float)x / 0x00010000; }

static_inline float int_to_float(int a) { return (float)a; }

static_inline int float_to_int(float a) { return (int)a; }

static_inline fix16_t int_to_fix(int a) { return a * 0x00010000; }

static_inline int fix_to_int(fix16_t a) { return (a >> 16); }

static_inline int int_clip(int v, int minv, int maxv) {
   return v > maxv ? maxv : (v < minv ? minv : v);
}

// Basic operations for fixed point numbers
static_inline fix16_t fix_add(fix16_t x, fix16_t y) { return x + y; }

static_inline fix16_t fix_sub(fix16_t x, fix16_t y) { return x - y; }

static_inline fix16_t fix_mul(fix16_t x, fix16_t y) {
   int64_t res = (int64_t)x * y;
   return (fix16_t)((res) >> 16);
}

static_inline fix16_t fix_div(fix16_t a, fix16_t b) {
   if (b == 0)
      return 0;
   fix16_t result = (((int64_t)a) << 16) / ((int64_t)b);
   return result;
}

static_inline fix16_t fix_mac(fix16_t x, fix16_t y, fix16_t z) {
   return x + fix_mul(y, z);
}

static_inline fix16_t fix_msu(fix16_t x, fix16_t y, fix16_t z) {
   return -x + fix_mul(y, z);
}

static_inline fix16_t fix_minus(fix16_t x) { return -x; }

static_inline fix16_t fix_abs(fix16_t x) { return x < 0 ? (-x) : x; }

static_inline fix16_t fix_min(fix16_t a, fix16_t b) { return a < b ? a : b; }

static_inline fix16_t fix_max(fix16_t a, fix16_t b) { return a > b ? a : b; }

static_inline fix16_t fix_clip(fix16_t v, fix16_t minv, fix16_t maxv) {
   return v > maxv ? maxv : (v < minv ? minv : v);
}

static_inline fix16_t fix_floor(fix16_t x) { return (x & 0xFFFF0000); }

static_inline fix16_t fix_not(fix16_t x) { return ~x; }

static_inline float float_eps() { return 1e-18f; }

static_inline fix16_t fix_eps() { return 1; }

static_inline float float_pi() { return 3.1415926535897932384f; }

static_inline fix16_t fix_pi() { return 205887; }

static_inline float float_mac(float x, float y, float z) {
   return x + (y * z);
}

static_inline float float_msu(float x, float y, float z) {
   return -x + (y * z);
}

fix16_t fix_exp(fix16_t inValue);

fix16_t fix_sin(fix16_t inAngle);

fix16_t fix_cos(fix16_t inAngle);

fix16_t fix_tan(fix16_t inAngle);

fix16_t fix_sinh(fix16_t inAngle);

fix16_t fix_cosh(fix16_t inAngle);

fix16_t fix_tanh(fix16_t inAngle);

fix16_t fix_sqrt(fix16_t inValue);

/* Floating point operations */

static_inline float float_clip(float value, float low, float high) {
   return value < low ? low : (value > high ? high : value);
}

/* Array get and set */
static_inline void float_set(float a[], int i, float value) { a[i] = value; }
static_inline float float_get(float a[], int i) { return a[i]; }
static_inline void fix_set(fix16_t a[], int i, fix16_t value) { a[i] = value; }
static_inline fix16_t fix_get(fix16_t a[], int i) { return a[i]; }
static_inline void int_set(int a[], int i, int value) { a[i] = value; }
static_inline int int_get(int a[], int i) { return a[i]; }
static_inline void bool_set(uint8_t a[], int i, uint8_t value) { a[i] = value; }
static_inline uint8_t bool_get(uint8_t a[], int i) { return a[i]; }

/* Array initialization */
void float_init_array(size_t size, float value, float data[]);
void int_init_array(size_t size, int value, int data[]);
void bool_init_array(size_t size, uint8_t value, uint8_t data[]);
void fix_init_array(size_t size, fix16_t value, fix16_t data[]);

/* Array copy */
void float_copy_array(size_t size, float *dest, float *src);
void int_copy_array(size_t size, int *dest, int *src);
void bool_copy_array(size_t size, uint8_t *dest, uint8_t *src);
void fix_copy_array(size_t size, fix16_t *dest, fix16_t *src);

static_inline uint8_t bool_not(uint8_t x) { return !x; }

/* Tables */
static_inline fix16_t *fix_wrap_array(const fix16_t x[]) {
   return (fix16_t *)x;
};
static_inline float *float_wrap_array(const float x[]) { return (float *)x; };

/* Random numbers */
float float_random();
fix16_t fix_random();
int irandom();

/* Print values */
void float_print(float value);
void fix_print(fix16_t value);
void int_print(int value);
void string_print(char *value);
void bool_print(uint8_t value);

#endif // VULTIN_H
|}
;;

(* --- Embedded vultin.cpp runtime implementation --- *)
let vultinImplStr : string = {|/*

The MIT License (MIT)

Copyright (c) 2015 Leonardo Laguna Ruiz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


NOTE: The code for the fixed-point operations is based on the project:
      https://code.google.com/p/libfixmath/

*/
#include "vultin.h"
#include "stdio.h"

fix16_t fix_exp(fix16_t inValue) {
   if (inValue == 0)
      return 0x00010000;
   if (inValue == 0x00010000)
      return 178145;
   if (inValue >= 681391)
      return 0x7FFFFFFF;
   if (inValue <= -772243)
      return 0;
   // The power-series converges much faster on positive values
   // and exp(-x) = 1/exp(x).
   int neg = (inValue < 0);
   if (neg)
      inValue = -inValue;
   fix16_t result = inValue + 0x00010000;
   fix16_t term = inValue;
   uint_fast8_t i;
   for (i = 2; i < 30; i++) {
      term = fix_mul(term, fix_div(inValue, int_to_fix(i)));
      result += term;
      if ((term < 500) && ((i > 15) || (term < 20)))
         break;
   }
   if (neg)
      result = fix_div(0x00010000, result);
   return result;
}

fix16_t fix_sin(fix16_t x0) {
   fix16_t x1 = (x0 % 0x6487e /* 6.283185 */);
   uint8_t sign = (x1 > 0x3243f /* 3.141593 */);
   fix16_t x2 = (x1 % 0x3243f /* 3.141593 */);
   fix16_t x3;
   if (x2 > 0x1921f /* 1.570796 */)
      x3 = fix_add(0x3243f /* 3.141593 */, (-x2));
   else
      x3 = x2;
   fix16_t xp2 = fix_mul(x3, x3);
   fix16_t acc =
       fix_mul(x3, fix_add(0x10000 /* 1.000000 */,
                           fix_mul(fix_add((0xffffd556 /* -0.166667 */),
                                           fix_mul(0x222 /* 0.008333 */, xp2)),
                                   xp2)));
   return (sign ? (-acc) : acc);
}

fix16_t fix_cos(fix16_t inAngle) { return fix_sin(inAngle + (fix_pi() >> 1)); }

fix16_t fix_tan(fix16_t inAngle) {
   return fix_div(fix_sin(inAngle), fix_cos(inAngle));
}

fix16_t fix_sinh(fix16_t inAngle) {
   return fix_mul(fix_exp(inAngle) - fix_exp(-inAngle), 0x8000);
}

fix16_t fix_cosh(fix16_t inAngle) {
   return fix_mul(fix_exp(inAngle) + fix_exp(-inAngle), 0x8000);
}

fix16_t fix_tanh(fix16_t inAngle) {
   fix16_t e_x = fix_exp(inAngle);
   fix16_t m_e_x = fix_exp(-inAngle);
   return fix_div(e_x - m_e_x, e_x + m_e_x);
}

fix16_t fix_sqrt(fix16_t inValue) {
   uint8_t neg = (inValue < 0);
   uint32_t num = (neg ? -inValue : inValue);
   uint32_t result = 0;
   uint32_t bit;
   uint8_t n;

   // Many numbers will be less than 15, so
   // this gives a good balance between time spent
   // in if vs. time spent in the while loop
   // when searching for the starting value.
   if (num & 0xFFF00000)
      bit = (uint32_t)1 << 30;
   else
      bit = (uint32_t)1 << 18;

   while (bit > num)
      bit >>= 2;

   // The main part is executed twice, in order to avoid
   // using 64 bit values in computations.
   for (n = 0; n < 2; n++) {
      // First we get the top 24 bits of the answer.
      while (bit) {
         if (num >= result + bit) {
            num -= result + bit;
            result = (result >> 1) + bit;
         } else {
            result = (result >> 1);
         }
         bit >>= 2;
      }

      if (n == 0) {
         // Then process it again to get the lowest 8 bits.
         if (num > 65535) {
            // The remainder 'num' is too large to be shifted left
            // by 16, so we have to add 1 to result manually and
            // adjust 'num' accordingly.
            // num = a - (result + 0.5)^2
            //   = num + result^2 - (result + 0.5)^2
            //   = num - result - 0.5
            num -= result;
            num = (num << 16) - 0x8000;
            result = (result << 16) + 0x8000;
         } else {
            num <<= 16;
            result <<= 16;
         }

         bit = 1 << 14;
      }
   }
   return (neg ? -(int32_t)result : (int32_t)result);
}

/* Array initialization */
void float_init_array(size_t size, float value, float data[]) {
   size_t i;
   for (i = 0; i < size; i++)
      data[i] = value;
}

void int_init_array(size_t size, int value, int data[]) {
   size_t i;
   for (i = 0; i < size; i++)
      data[i] = value;
}

void bool_init_array(size_t size, uint8_t value, uint8_t data[]) {
   size_t i;
   for (i = 0; i < size; i++)
      data[i] = value;
}

void fix_init_array(size_t size, fix16_t value, fix16_t data[]) {
   size_t i;
   for (i = 0; i < size; i++)
      data[i] = value;
}

void float_copy_array(size_t size, float *dest, float *src) {
   size_t i;
   for (i = 0; i < size; i++)
      dest[i] = src[i];
}

void int_copy_array(size_t size, int *dest, int *src) {
   size_t i;
   for (i = 0; i < size; i++)
      dest[i] = src[i];
}

void bool_copy_array(size_t size, uint8_t *dest, uint8_t *src) {
   size_t i;
   for (i = 0; i < size; i++)
      dest[i] = src[i];
}

void fix_copy_array(size_t size, fix16_t *dest, fix16_t *src) {
   size_t i;
   for (i = 0; i < size; i++)
      dest[i] = src[i];
}

float float_random() { return (float)rand() / RAND_MAX; }

fix16_t fix_random() {
   float temp = ((float)rand() / RAND_MAX) * 0x00010000;
   return (fix16_t)temp;
}

int irandom() { return (int)rand(); }

void float_print(float value) { printf("%f\n", value); }
void fix_print(fix16_t value) { printf("%f\n", fix_to_float(value)); }
void int_print(int value) { printf("%i\n", value); }
void string_print(char *value) { printf("%s\n", value); }
void bool_print(uint8_t value) { printf("%s\n", value ? "true" : "false"); }
|}
;;
