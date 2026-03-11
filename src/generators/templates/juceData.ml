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
   let f3_id = make_id output "f3" in
   let f4_id = make_id output "f4" in
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
     ; "juce_audio_utils"
     ; "juce_core"
     ; "juce_data_structures"
     ; "juce_events"
     ; "juce_graphics"
     ; "juce_gui_basics"
     ; "juce_gui_extra"
     ]
   in
   let module_paths =
     List.map (fun id -> "        <MODULEPATH id=" ^ a id ^ " path=" ^ a "../../../Downloads/JUCE 2/modules" ^ "/>") module_ids
     |> cat
   in
   cat
      [ "<?xml version=" ^ a "1.0" ^ " encoding=" ^ a "UTF-8" ^ "?>"
      ; ""
      ; "<JUCERPROJECT id=" ^ a p_id ^ " name=" ^ a output ^ " projectType=" ^ a "audioplug"
        ^ " useAppConfig=" ^ a "0"
      ; "              addUsingNamespaceToJuceHeader=" ^ a "0" ^ " jucerFormatVersion=" ^ a "1"
      ; "              buildVST3=" ^ a "1" ^ " buildAU=" ^ a "1" ^ " buildStandalone=" ^ a "1"
      ; "              pluginName=" ^ a output ^ " pluginDesc=" ^ a output ^ " pluginManufacturer=" ^ a "yourcompany"
      ; "              pluginManufacturerCode=" ^ a "Vult" ^ " pluginCode=" ^ a (make_plugin_code output)
      ; "              pluginChannelConfigs=" ^ a "" ^ " pluginIsSynth=" ^ a "0"
      ; "              pluginWantsMidiIn=" ^ a "0" ^ " pluginProducesMidiOut=" ^ a "0"
      ; "              pluginIsMidiEffectPlugin=" ^ a "0" ^ " pluginEditorRequiresKeys=" ^ a "0"
      ; "              pluginAUExportPrefix=" ^ a (output ^ "AU") ^ " pluginRTASCategory=" ^ a ""
      ; "              pluginAAXCategory=" ^ a "2" ^ " pluginVSTCategory=" ^ a "kPlugCategEffect"
      ; "              pluginVST3Category=" ^ a "Fx" ^ " jucerCoreVersion=" ^ a "1" ^ " companyName=" ^ a "yourcompany" ^ ">"
      ; "  <MAINGROUP id=" ^ a mg_id ^ " name=" ^ a output ^ ">"
      ; "    <GROUP id=" ^ a g_id ^ " name=" ^ a "Source" ^ ">"
      ; "      <FILE id=" ^ a f1_id ^ " name=" ^ a "PluginProcessor.cpp" ^ " compile=" ^ a "1"
        ^ " resource=" ^ a "0"
      ; "            file=" ^ a "Source/PluginProcessor.cpp" ^ "/>"
      ; "      <FILE id=" ^ a f2_id ^ " name=" ^ a "PluginProcessor.h" ^ " compile=" ^ a "0"
        ^ " resource=" ^ a "0"
      ; "            file=" ^ a "Source/PluginProcessor.h" ^ "/>"
      ; "      <FILE id=" ^ a f3_id ^ " name=" ^ a "PluginEditor.cpp" ^ " compile=" ^ a "1"
        ^ " resource=" ^ a "0"
      ; "            file=" ^ a "Source/PluginEditor.cpp" ^ "/>"
      ; "      <FILE id=" ^ a f4_id ^ " name=" ^ a "PluginEditor.h" ^ " compile=" ^ a "0"
        ^ " resource=" ^ a "0" ^ " file=" ^ a "Source/PluginEditor.h" ^ "/>"
      ; "      <FILE id=" ^ a f5_id ^ " name=" ^ a (output ^ ".cpp") ^ " compile=" ^ a "1"
        ^ " resource=" ^ a "0" ^ " file=" ^ a (output ^ ".cpp") ^ "/>"
      ; "      <FILE id=" ^ a f6_id ^ " name=" ^ a (output ^ ".h") ^ " compile=" ^ a "0"
        ^ " resource=" ^ a "0" ^ " file=" ^ a (output ^ ".h") ^ "/>"
      ; "      <FILE id=" ^ a f7_id ^ " name=" ^ a (output ^ ".tables.h") ^ " compile=" ^ a "0"
        ^ " resource=" ^ a "0" ^ " file=" ^ a (output ^ ".tables.h") ^ "/>"
      ; "      <FILE id=" ^ a f8_id ^ " name=" ^ a "vultin.cpp" ^ " compile=" ^ a "1"
        ^ " resource=" ^ a "0" ^ " file=" ^ a "vultin.cpp" ^ "/>"
      ; "      <FILE id=" ^ a f9_id ^ " name=" ^ a "vultin.h" ^ " compile=" ^ a "0"
        ^ " resource=" ^ a "0" ^ " file=" ^ a "vultin.h" ^ "/>"
      ; "    </GROUP>"
      ; "  </MAINGROUP>"
      ; "  <MODULES>"
      ; "    <MODULE id=" ^ a "juce_audio_basics" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_audio_devices" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_audio_formats" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_audio_plugin_client" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_audio_processors" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_audio_utils" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_core" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_data_structures" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_events" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_graphics" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_gui_basics" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
      ; "    <MODULE id=" ^ a "juce_gui_extra" ^ " showAllCode=" ^ a "1" ^ " useLocalCopy=" ^ a "0" ^ " useGlobalPath=" ^ a "0" ^ "/>"
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
      ; ""
      ; "#include " ^ a "JucePluginDefines.h"
      ; ""
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
      ; " #define JucePlugin_IsSynth                0"
      ; "#endif"
      ; "#ifndef  JucePlugin_WantsMidiInput"
      ; " #define JucePlugin_WantsMidiInput         0"
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
      ; " #define JucePlugin_Vst3Category           " ^ a "Fx"
      ; "#endif"
      ; "#ifndef  JucePlugin_AUMainType"
      ; " #define JucePlugin_AUMainType             'aufx'"
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
   let cc_decls = List.map (fun (_, n) -> "    float " ^ n ^ ";") cc_params |> cat in
   let ctx_decl = if has_ctx then "    " ^ module_name ^ "_process_type process_ctx;" else "" in
   cat
      [ "#pragma once"
      ; ""
      ; "#include <JuceHeader.h>"
      ; "#include " ^ a ("../" ^ output ^ ".h")
      ; ""
      ; "class " ^ output ^ "AudioProcessor  : public juce::AudioProcessor"
      ; "{"
      ; "public:"
      ; "    " ^ output ^ "AudioProcessor();"
      ; "    ~" ^ output ^ "AudioProcessor() override;"
      ; ""
      ; "    void prepareToPlay (double sampleRate, int samplesPerBlock) override;"
      ; "    void releaseResources() override;"
      ; ""
      ; "   #ifndef JucePlugin_PreferredChannelConfigurations"
      ; "    bool isBusesLayoutSupported (const BusesLayout& layouts) const override;"
      ; "   #endif"
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
      ; "    // CC parameters"
      ; cc_decls
      ; ctx_decl
      ; ""
      ; "private:"
      ; "    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (" ^ output ^ "AudioProcessor)"
      ; "};"
      ]
;;

(* --- PluginProcessor.cpp --- *)
let processorImplStr (output : string) (cc_params : (int * string) list) (num_inputs : int) (num_outputs : int)
   (module_name : string) (process_call : string) (input_gets : string) (output_sets : string)
   (impl_code_str : string) (has_ctx : bool) : string =
   let cc_init = List.map (fun (_, n) -> "    " ^ n ^ " = 0.0f;") cc_params |> cat in
   let ctx_init = if has_ctx then "    " ^ module_name ^ "_process_init(process_ctx);\n    " ^ module_name ^ "_default(process_ctx);" else "" in
   let cc_bindings = List.map (fun (cc, n) -> "    " ^ module_name ^ "_controlChange(process_ctx, " ^ string_of_int cc ^ ", " ^ n ^ " * 127.0f, 0);") cc_params |> cat in
   cat
      [ "#include " ^ a "PluginProcessor.h"
      ; "#include " ^ a "PluginEditor.h"
      ; ""
      ; "#include " ^ a ("../" ^ output ^ ".h")
      ; "#include " ^ a ("../" ^ output ^ ".tables.h")
      ; ""
      ; "static double vult_sample_rate = 44100.0;"
      ; "extern \"C\" {"
      ; "    float float_samplerate() { return (float)vult_sample_rate; }"
      ; "    int32_t fix_samplerate() { return (int32_t)(vult_sample_rate * 65536.0); }"
      ; "}"
      ; ""
      ; impl_code_str
      ; ""
      ; output ^ "AudioProcessor::" ^ output ^ "AudioProcessor()"
      ; "#ifndef JucePlugin_PreferredChannelConfigurations"
      ; "     : juce::AudioProcessor (BusesProperties()"
      ; "                     #if ! JucePlugin_IsMidiEffect"
      ; "                      #if ! JucePlugin_IsSynth"
      ; "                       .withInput  (" ^ a "Input" ^ ",  juce::AudioChannelSet::stereo(), true)"
      ; "                      #endif"
      ; "                       .withOutput (" ^ a "Output" ^ ", juce::AudioChannelSet::stereo(), true)"
      ; "                     #endif"
      ; "                       )"
      ; "#endif"
      ; "{"
      ; ctx_init
      ; cc_init
      ; "}"
      ; ""
      ; output ^ "AudioProcessor::~" ^ output ^ "AudioProcessor() {}"
      ; ""
      ; "const juce::String " ^ output ^ "AudioProcessor::getName() const { return JucePlugin_Name; }"
      ; ""
      ; "bool " ^ output ^ "AudioProcessor::acceptsMidi() const"
      ; "{"
      ; "   #if JucePlugin_WantsMidiInput"
      ; "    return true;"
      ; "   #else"
      ; "    return false;"
      ; "   #endif"
      ; "}"
      ; ""
      ; "bool " ^ output ^ "AudioProcessor::producesMidi() const"
      ; "{"
      ; "   #if JucePlugin_ProducesMidiOutput"
      ; "    return true;"
      ; "   #else"
      ; "    return false;"
      ; "   #endif"
      ; "}"
      ; ""
      ; "bool " ^ output ^ "AudioProcessor::isMidiEffect() const"
      ; "{"
      ; "   #if JucePlugin_IsMidiEffect"
      ; "    return true;"
      ; "   #else"
      ; "    return false;"
      ; "   #endif"
      ; "}"
      ; ""
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
      ; ctx_init
      ; "}"
      ; "void " ^ output ^ "AudioProcessor::releaseResources() {}"
      ; ""
      ; "#ifndef JucePlugin_PreferredChannelConfigurations"
      ; "bool " ^ output ^ "AudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const"
      ; "{"
      ; "  #if JucePlugin_IsMidiEffect"
      ; "    juce::ignoreUnused (layouts);"
      ; "    return true;"
      ; "  #else"
      ; "    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()"
      ; "     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())"
      ; "        return false;"
      ; "   #if ! JucePlugin_IsSynth"
      ; "    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())"
      ; "        return false;"
      ; "   #endif"
      ; "    return true;"
      ; "  #endif"
      ; "}"
      ; "#endif"
      ; ""
      ; "void " ^ output ^ "AudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)"
      ; "{"
      ; "    juce::ScopedNoDenormals noDenormals;"
      ; "    auto totalNumInputChannels  = getTotalNumInputChannels();"
      ; "    auto totalNumOutputChannels = getTotalNumOutputChannels();"
      ; ""
      ; "    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)"
      ; "        buffer.clear (i, 0, buffer.getNumSamples());"
      ; ""
      ; cc_bindings
      ; ""
      ; "    float inputs[" ^ string_of_int num_inputs ^ "];"
      ; "    float outputs[" ^ string_of_int num_outputs ^ "];"
      ; ""
      ; "    for (int channel = 0; channel < totalNumInputChannels; ++channel)"
      ; "    {"
      ; "        for (int j = 0; j < buffer.getNumSamples(); j++) {"
      ; "            " ^ input_gets
      ; "            " ^ process_call
      ; "            " ^ output_sets
      ; "        }"
      ; "    }"
      ; "}"
      ; ""
      ; "bool " ^ output ^ "AudioProcessor::hasEditor() const { return true; }"
      ; "juce::AudioProcessorEditor* " ^ output ^ "AudioProcessor::createEditor()"
      ; "{"
      ; "    return new " ^ output ^ "AudioProcessorEditor (*this);"
      ; "}"
      ; ""
      ; "void " ^ output ^ "AudioProcessor::getStateInformation (juce::MemoryBlock&) {}"
      ; "void " ^ output ^ "AudioProcessor::setStateInformation (const void*, int) {}"
      ; ""
      ; "juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()"
      ; "{"
      ; "    return new " ^ output ^ "AudioProcessor();"
      ; "}"
      ]
;;

(* --- PluginEditor.h --- *)
let editorHeaderStr (output : string) (cc_param_names : string list) : string =
   let sliders = List.map (fun n -> "    juce::Slider " ^ n ^ "_slider;") cc_param_names |> cat in
   let labels = List.map (fun n -> "    juce::Label " ^ n ^ "_label;") cc_param_names |> cat in
   cat
      [ "#pragma once"
      ; ""
      ; "#include <JuceHeader.h>"
      ; "#include " ^ a "PluginProcessor.h"
      ; ""
      ; "class " ^ output ^ "AudioProcessorEditor  : public juce::AudioProcessorEditor"
      ; "{"
      ; "public:"
      ; "    " ^ output ^ "AudioProcessorEditor (" ^ output ^ "AudioProcessor&);"
      ; "    ~" ^ output ^ "AudioProcessorEditor() override;"
      ; ""
      ; "    void paint (juce::Graphics&) override;"
      ; "    void resized() override;"
      ; ""
      ; "private:"
      ; "    " ^ output ^ "AudioProcessor& audioProcessor;"
      ; ""
      ; sliders
      ; labels
      ; ""
      ; "    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (" ^ output ^ "AudioProcessorEditor)"
      ; "};"
      ]
;;

(* --- PluginEditor.cpp --- *)
let editorImplStr (output : string) (cc_param_names : string list) : string =
   let num_ctrls = List.length cc_param_names in
   let slider_inits =
      List.map (fun n ->
            cat
               [ "    " ^ n ^ "_slider.setSliderStyle(juce::Slider::Rotary);"
               ; "    " ^ n ^ "_slider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);"
               ; "    addAndMakeVisible(" ^ n ^ "_slider);"
               ])
         cc_param_names
      |> String.concat "\n"
   in
   let label_inits =
      List.map (fun n ->
            cat
               [ "    " ^ n ^ "_label.setText(" ^ a n ^ ", juce::dontSendNotification);"
               ; "    " ^ n ^ "_label.attachToComponent(&" ^ n ^ "_slider, false);"
               ; "    addAndMakeVisible(" ^ n ^ "_label);"
               ])
         cc_param_names
      |> String.concat "\n"
   in
   let slider_bindings =
      List.map (fun n ->
            cat
               [ "    " ^ n ^ "_slider.onValueChange = [this] {"
               ; "        audioProcessor." ^ n ^ " = " ^ n ^ "_slider.getValue();"
               ; "    };"
               ])
         cc_param_names
      |> String.concat "\n"
   in
   let slider_init_values =
      List.map (fun n ->
            "    " ^ n ^ "_slider.setValue(audioProcessor." ^ n ^ ", juce::dontSendNotification);")
         cc_param_names
      |> cat
   in
   let layout_code =
      if num_ctrls = 0
      then
         cat
            [ "    g.setColour (juce::Colours::white);"
            ; "    g.setFont (juce::FontOptions (15.0f));"
            ; "    g.drawFittedText (" ^ a output ^ ", getLocalBounds(), juce::Justification::centred, 1);"
            ]
      else
         let rows = max 1 ((num_ctrls + 3) / 4) in
         let cols = min 4 num_ctrls in
         let w_cell = 400 / cols in
         let h_cell = if rows > 0 then 300 / rows else 100 in
         List.mapi
            (fun i n ->
               let col = i mod cols in
               let row = i / cols in
               let x = (col * w_cell) + 20 in
               let y = (row * h_cell) + 30 in
               let w = w_cell - 40 in
               let h = h_cell - 50 in
               "    " ^ n ^ "_slider.setBounds("
               ^ string_of_int x ^ ", "
               ^ string_of_int y ^ ", "
               ^ string_of_int w ^ ", "
               ^ string_of_int h ^ ");")
            cc_param_names
         |> cat
   in
   cat
      [ "#include " ^ a "PluginProcessor.h"
      ; "#include " ^ a "PluginEditor.h"
      ; ""
      ; output ^ "AudioProcessorEditor::" ^ output ^ "AudioProcessorEditor (" ^ output ^ "AudioProcessor& p)"
      ; "    : juce::AudioProcessorEditor (&p), audioProcessor (p)"
      ; "{"
      ; "    setSize (400, " ^ string_of_int (max 300 (((num_ctrls + 3) / 4) * 100 + 40)) ^ ");"
      ; slider_inits
      ; label_inits
      ; slider_bindings
      ; slider_init_values
      ; "}"
      ; ""
      ; output ^ "AudioProcessorEditor::~" ^ output ^ "AudioProcessorEditor() {}"
      ; ""
      ; "void " ^ output ^ "AudioProcessorEditor::paint (juce::Graphics& g)"
      ; "{"
      ; "    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));"
      ; layout_code
      ; "}"
      ; ""
      ; "void " ^ output ^ "AudioProcessorEditor::resized() {}"
      ]
;;
